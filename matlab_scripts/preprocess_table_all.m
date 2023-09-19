function y=preprocess_table_all(subject_data, log_table)
    
    subject_data(isnan(subject_data.subject_id), :)=[];
    
    %disp(log_table.bad_log_cell1);
    issue_rows=log_table(find(~strcmp(log_table.bad_log_cell1,'file not found')),:);
    sub_bad_rows={};
    for i=1:height(issue_rows)
        issue_row=issue_rows(i,:);
        sub_id=issue_row.bad_log_cell2;
        center=cell2mat(issue_row.bad_log_cell3);
        dataset=cell2mat(issue_row.bad_log_cell4);
        sub_bad_rows{i}=find(subject_data.subject_id==sub_id...
            & strcmp(subject_data.site_id, center) & strcmp(subject_data.dataset, dataset));
    end
    
    for i=1:length(sub_bad_rows)
        subject_data(sub_bad_rows{i}, :)=[];
    end
    
    y=subject_data;
end

