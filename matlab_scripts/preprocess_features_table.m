function y = preprocess_features_table(features_table, num_features, n)
    for i=1:num_features
        column=features_table{:,i};
        if iscell(column)
            new_col=cell(n,1);
            for j=1:n
                data_single=str2double(column{j});
                new_col{j,1}=data_single;
            end
            features_table{:,i}=new_col;
        end
    end
    
    y=features_table;  
end