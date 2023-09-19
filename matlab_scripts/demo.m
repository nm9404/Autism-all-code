%%%DEMO de pipeline, requiere base de datos pre procesada
%%csv de sujetos con diagnostico, edad y detalles sobre rutas
%%En este caso es table_test_subject.csv que tiene solo un sujeto de prueba


addpath('fdct_wrapping_matlab');
addpath('ToolboxWaveletTexture');
addpath('LibreriaNifti');
addpath('collage_utils');

%Con esta funcion obtiene una matriz cell de caracteristicas donde las columnas son las regiones, 
%las filas son los sujeto, la segunda salida es un vector donde esta el id,
%dentro de cada cell estar[ia el vector de 243 caracteristicas.
%de cada sujeto
[features_cell, sub_ids]=getFeaturesFromFiles2019('table_test_subject.csv');

