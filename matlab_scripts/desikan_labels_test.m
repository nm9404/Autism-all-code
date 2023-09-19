seg_path='/mnt/md0/nmunerag/Herramientas/atlas/desikan_labels.csv';
regions_table = readtable(seg_path);
indices = uint16(cell2mat(table2cell(regions_table(:, 1))));