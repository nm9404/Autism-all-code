
function p = get_test_from_csv(subband, feature_idx)
	table = readtable('children_region_50.csv', 'Delimiter', ',');
	features = table(:,9:9+242);
	asd_index = find(table.dx_group==1);
	control_index = find(table.dx_group==2);
	asd_features = features(asd_index, :);
	control_features = features(control_index, :);
	feature = (subband-1)*3 + feature_idx;
	asd_vector = asd_features(:,feature);
	control_vector = control_features(:, feature);
	disp('prueba ranksum');
	disp(ranksum(table2array(asd_vector), table2array(control_vector)));
	disp('prueba signrank');
	disp(signrank(table2array(asd_vector), table2array(control_vector)));
	p = signrank(table2array(asd_vector), table2array(control_vector))

