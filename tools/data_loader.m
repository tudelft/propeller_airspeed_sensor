function ac_datalist = data_loader(sel, data_folder)
    ac_datalist = struct();

    for i = 1:length(sel)
        data_set = sel(i);
        switch data_set 
            case "144"
                p = parselog(data_folder + "\20241030_valken_ewoud\144\24_10_30__16_27_37_SD.data");
                ac_data = p.aircrafts.data;
            case "145"
                p = parselog(data_folder + "\20241030_valken_ewoud\145\24_10_30__16_45_37_SD.data");
                ac_data = p.aircrafts.data;
            case "148"
                p = parselog(data_folder + "\20241030_valken_ewoud\148\24_10_30__17_27_57_SD.data");
                ac_data = p.aircrafts.data;
                
            case "254"
                p = parselog(data_folder + "\20250117_valken_first_succ_manual\0254\25_01_17__15_36_58_SD.data");
                ac_data = p.aircrafts.data;
            case "257"
                assert(false,"Try a different dataset this one is not loaded yet")
            case "418"
                p = parselog(data_folder + "\20250307_valken_spiral\0418\22_05_01__01_59_46_SD.data");
                ac_data = p.aircrafts.data;
        end
        ac_datalist.("ac_data"+sel(i)) = ac_data;
    end

    
end