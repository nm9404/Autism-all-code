function y=getPathFromAbideData(subject_id, site_id, dataset, pipeline_name, init_path, image_name)
    if strcmp(dataset,'ABIDE-I')
        dataset='ABIDEI';
        y=[init_path, '/', dataset, '/' ,site_id, '_', subject_id, '/', pipeline_name, '/', image_name];
    else
        if strcmp(dataset, 'ABIDE-II')
            dataset='ABIDEII';
            y=[init_path, '/', dataset, '/', dataset, '-', site_id, '/', subject_id, '/', pipeline_name, '/', image_name];
        end
    end
end