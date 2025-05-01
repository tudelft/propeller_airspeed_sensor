function OJF_data_loader(data_folder)
    
    p1 = parselog(data_folder+ "\20250407_OJF\0061\25_04_07__18_32_42_SD_no_GPS.data");
    ac_data1 = p1.aircrafts.data;
    p2 = parselog(data_folder+ "\20250407_OJF\0062\25_04_07__19_28_56_SD_no_GPS.data");
    ac_data2 = p2.aircrafts.data;
    
    
    %rpm_data = double(ac_data.SERIAL_ACT_T4_IN.motor_1_rpm);
    %power_data = double(ac_data.SERIAL_ACT_T4_IN.motor_1_voltage_int.*ac_data.SERIAL_ACT_T4_IN.motor_1_current_int)./10000;
    
    %ac_datalist.OJF_data = ac_data2; %replace soon

end