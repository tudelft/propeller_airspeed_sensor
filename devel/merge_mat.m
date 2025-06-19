clear;

mat1 = load('post_data/flight/0254.mat');
mat2 = load('post_data/flight/0257.mat');
ac_data_merged = merge_two_mat2ac_data(mat1, mat2);

%% save as "ac_data" for consistency
ac_data = ac_data_merged;
save(fullfile("post_data/flight", "0254-0257"), 'ac_data');

%%
function ac_data_merged = merge_two_mat2ac_data(mat1, mat2)

    ac_data1 = mat1.ac_data;
    ac_data2 = mat2.ac_data;

    msgs = fieldnames(ac_data1);

    for k = 1:length(msgs)
        msg = msgs{k};

        % Shift time of second dataset
        t1_end = ac_data1.(msg).timestamp(end);
        t2_start = ac_data2.(msg).timestamp(1);
        time_shift = t1_end - t2_start + 1;
        ac_data2.(msg).timestamp = ac_data2.(msg).timestamp + time_shift;

        % Merge all fields
        fields = fieldnames(ac_data1.(msg));
        for i = 1:length(fields)
            field = fields{i};
            ac_data1.(msg).(field) = [ac_data1.(msg).(field); ac_data2.(msg).(field)];
        end
    end

    ac_data_merged = ac_data1;
end
