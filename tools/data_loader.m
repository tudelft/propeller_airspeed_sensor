function ac_datalist = data_loader(sel)
    ac_datalist = struct();

    for i = 1:length(sel)
        data_set = sel(i);
        switch data_set 
            case "144"
                p = parselog("C:\MavLab\ESC_Feedback_Log\Flight_Data\24_10_30__16_27_37_SD.data");
                ac_data = p.aircrafts.data;
            case "145"
                p = parselog("C:\MavLab\ESC_Feedback_Log\Flight_Data\24_10_30__16_45_37_SD.data");
                ac_data = p.aircrafts.data;
            case "148"
                p = parselog("C:\MavLab\ESC_Feedback_Log\Flight_Data\24_10_30__17_27_57_SD.data");
                ac_data = p.aircrafts.data;
                
            case "254"
                p = parselog("C:\MavLab\ESC_Feedback_Log\Flight_Data\25_01_17__15_36_58_SD.data");
                ac_data = p.aircrafts.data;
            case "257"
                assert(false,"Try a different dataset this one is not loaded yet")
            case "418"
                p = parselog("C:\MavLab\ESC_Feedback_Log\Flight_Data\22_05_01__01_59_46_SD.data");
                ac_data = p.aircrafts.data;
        end
        ac_datalist.("ac_data"+sel(i)) = ac_data;
    end

    
end