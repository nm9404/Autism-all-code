import nibabel as nb
import nibabel.processing as nbp
import numpy as np
import cv2
import math
from copy import deepcopy
from scipy.optimize import minimize

class VolumePreprocessing:
    def __init__(self, volume_path, template_path=''):
        # volume subject with bias correction
        # template path corresponds to the path where a volume with angle corrected is stored
        # translation path  corresponds to the path where the volume without angle correction is stored
        self.volume_path = volume_path
        if template_path != '':
            self.set_template_path(template_path)
        self.subject = nb.load(self.volume_path)
    
    def set_template_path(self, template_path):
        self.template_path = template_path
        self.template = nb.load(self.template_path)

    def crop_img(self, img):
        y = np.sum(img, axis=1)
        x = np.sum(img, axis=0)
        return img[np.where(y>0)[0][0]:np.where(y>0)[0][-1], np.where(x>0)[0][0]:np.where(x>0)[0][-1]]

    def resample_subject(self, output, voxel_size=(1.0,1.0,1.0)):
        #Voxel size is a tuple of three elements
        resampled = nbp.resample_to_output(in_img=self.subject, voxel_sizes=voxel_size)
        nb.save(resampled, output)

    def normalize_intensity(self, img):
        zero_idx_row = np.where(img<0)[0]
        zero_idx_col = np.where(img<0)[1]
        img[zero_idx_row, zero_idx_col] = 0
        img = img/np.max(img)
        return img

    def rotate_image(self, image, angle):
        image_center = tuple(np.array(image.shape[1::-1]) / 2)
        rot_mat = cv2.getRotationMatrix2D(image_center, angle, 1.0)
        result = cv2.warpAffine(image, rot_mat, image.shape[1::-1], flags=cv2.INTER_LINEAR)
        return result

    def get_analysis_slice(self, vol, slice_type):
        shape = np.array(vol.shape) // 2
        if slice_type=='coronal':
            return vol[:,shape[1],:]
        if slice_type=='axial':
            return vol[:,:,shape[2]]
        if slice_type=='sagital':
            return vol [shape[0],:,:]

    def opt_ang_process(self, template_slice, subject_slice):
        MI_s = []
        angles = []
        for i in range(90):
            MI_s.append(self.rotate_compare_mutual_information(i+1-45, template_slice, subject_slice))
            angles.append(i+1-45)
        pos_angle = np.where(MI_s==np.min(MI_s))[0][0]
        opt_angle = angles[pos_angle]
        return opt_angle

    def mutual_information(self, hgram):
        # Convert bins counts to probability values
        pxy = hgram / float(np.sum(hgram))
        px = np.sum(pxy, axis=1) # marginal for x over y
        py = np.sum(pxy, axis=0) # marginal for y over x
        px_py = px[:, None] * py[None, :] # Broadcast to multiply marginals
        # Now we can do the calculation using the pxy, px_py 2D arrays
        nzs = pxy > 0 # Only non-zero pxy values contribute to the sum
        return np.sum(pxy[nzs] * np.log(pxy[nzs] / px_py[nzs]))

    def rotate_compare_mutual_information(self, ang, template_slice, subject_slice):
        template_slice = self.crop_img(self.normalize_intensity(template_slice))
        subject_slice = cv2.resize(self.crop_img(self.normalize_intensity(subject_slice)), 
                               dsize=(template_slice.shape[1], template_slice.shape[0]))
        subject_slice_rot = cv2.resize(self.rotate_image(subject_slice, ang), 
                                   dsize=(template_slice.shape[1], template_slice.shape[0]))
        hist2d, x_edge, y_edge = np.histogram2d(subject_slice_rot.ravel(), template_slice.ravel(), bins=35)
        MI = self.mutual_information(hist2d)
        return 1 - MI

    def find_opt_angle(self, template_volume, subject_volume, slice_type):
        template_slice = self.get_analysis_slice(template_volume, slice_type)
        subject_slice = self.get_analysis_slice(subject_volume, slice_type)
        return self.opt_ang_process(template_slice, subject_slice)

    def correct_volume(self, volume, opt_angle, side):
        if 'sagital' in side:
            volume_shape = volume.shape
            out_vol = volume
            new_vol = deepcopy(out_vol)
            for i in range(volume_shape[0]):
                sl_o = out_vol[i,:,:]
                sl_o = self.rotate_image(sl_o, opt_angle)
                new_vol[i,:,:]=sl_o
            return new_vol
        
        if 'coronal' in side:
            volume_shape = volume.shape
            out_vol = volume
            new_vol = deepcopy(out_vol)
            for i in range(volume_shape[1]):
                sl_o = out_vol[:,i,:]
                sl_o = self.rotate_image(sl_o, opt_angle)
                new_vol[:,i,:]=sl_o
            return new_vol
            
        if 'axial' in side:
            volume_shape = volume.shape
            out_vol = volume
            new_vol = deepcopy(out_vol)
            for i in range(volume_shape[2]):
                sl_o = out_vol[:,:,i]
                sl_o = self.rotate_image(sl_o, opt_angle)
                new_vol[:,:,i]=sl_o
            return new_vol

    def correct_rotate_volume(self, ang, args):
    #ang x,y,z
        ang = (ang/np.pi) * 180
        ax,ay,az = ang
        print(ang)
        subject_vol, template_vol = args
        new_vol = self.correct_volume(subject_vol, ax, 'sagital')
        new_vol = self.correct_volume(new_vol, ay, 'coronal')
        new_vol = self.correct_volume(new_vol, az, 'axial')
        hist2d, x_edge, y_edge = np.histogram2d(new_vol.ravel(), template_vol.ravel(), bins=35) 
        print( 1 / self.mutual_information(hist2d))
        return 1 / self.mutual_information(hist2d)

    def correct_vol_3D(self, ang, args):
        ang = (ang/np.pi) * 180
        ax,ay,az = ang
        subject_vol = args
        new_vol = self.correct_volume(subject_vol, ax, 'sagital')
        new_vol = self.correct_volume(new_vol, ay, 'coronal')
        new_vol = self.correct_volume(new_vol, az, 'axial')
        return new_vol

    def correct_subject_rotation(self, in_path, out_path):
        #in path will be the path where sampled volume is stored
        template_volume = self.template.get_fdata().astype(float)

        subject = nb.load(in_path)
        subject_volume = subject.get_fdata().astype(float)

        slices = ['sagital', 'coronal', 'axial']
        opt_object = minimize(self.correct_rotate_volume, [0,0,0], args=([subject_volume, template_volume], ), method='TNC', 
            bounds=[(-np.pi, np.pi), (-np.pi, np.pi), (-np.pi, np.pi)], tol=0.001, options={'eps':0.001})

        angles = opt_object.x
        corrected_volume = self.correct_vol_3D(angles, subject_volume)
        
        new_img = nb.Nifti1Image(corrected_volume, affine=subject.affine, header=subject.header)
        nb.save(new_img, out_path)

        return ((angles/np.pi) * 180).tolist()

