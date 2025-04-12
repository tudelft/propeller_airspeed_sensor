function merge_mat(ac_data1,ac_data2)

    mat1 = load('post_data/0061.mat');
    mat2 = load('post_data/0062.mat');

    ac_data1 = mat1.ac_data;
    ac_data2 = mat2.ac_data;

    time_shift = ac_data1.AIR_DATA.timestamp(end) - ac_data2.AIR_DATA.timestamp(1) + 1;
    ac_data2.AIR_DATA.timestamp = ac_data2.AIR_DATA.timestamp + time_shift;

    time_shift = ac_data1.SERIAL_ACT_T4_IN.timestamp(end) - ac_data2.SERIAL_ACT_T4_IN.timestamp(1) + 1;
    ac_data2.SERIAL_ACT_T4_IN.timestamp = ac_data2.SERIAL_ACT_T4_IN.timestamp + time_shift;

    time_shift = ac_data1.SERIAL_ACT_T4_OUT.timestamp(end) - ac_data2.SERIAL_ACT_T4_OUT.timestamp(1) + 1;
    ac_data2.SERIAL_ACT_T4_OUT.timestamp = ac_data2.SERIAL_ACT_T4_OUT.timestamp + time_shift;

    fields = fieldnames(ac_data1.AIR_DATA);
    for i = 1:length(fields)
        field = fields{i};
        ac_data1.AIR_DATA.(field) = [ac_data1.AIR_DATA.(field); ac_data2.AIR_DATA.(field)];
    end

    fields = fieldnames(ac_data1.SERIAL_ACT_T4_IN);
    for i = 1:length(fields)
        field = fields{i};
        ac_data1.SERIAL_ACT_T4_IN.(field) = [ac_data1.SERIAL_ACT_T4_IN.(field); ac_data2.SERIAL_ACT_T4_IN.(field)];
    end

    fields = fieldnames(ac_data1.SERIAL_ACT_T4_OUT);
    for i = 1:length(fields)
        field = fields{i};
        ac_data1.SERIAL_ACT_T4_OUT.(field) = [ac_data1.SERIAL_ACT_T4_OUT.(field); ac_data2.SERIAL_ACT_T4_OUT.(field)];
    end
    

end

%% save as "ac_data" for consistency
% ac_data = ac_data1;
% save(fullfile("post_data", "whole"), 'ac_data');