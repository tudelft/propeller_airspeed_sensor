%% Variable List  %%
% ac_data: 
% ac_datalist: Struct of data sets 
% ac_sdata: flight data that has been selected and cut to the required size
% mdl: Current model fitted to the data
% mdl_list: list of models currently under anlysis

clear p ac_data
close all

addpath('tools/');

p = parselog('C:\MavLab\ESC_Feedback_Log\Flight_Data\24_10_30__16_45_37_SD.data');
ac_data = p.aircrafts.data;


%% Data Slicing 
v = 10; % Velocity you want to cut at 
ac_sdata = data_selector(ac_data,v);
%% Basic Curve Fitting 

input_data = [ones(size(ac_sdata.airspeed)) ac_sdata.power (ac_sdata.power).^2 ...
    ac_sdata.rpm (ac_sdata.rpm).^2 ac_sdata.rpmrate ...
    ac_sdata.dshot ac_sdata.dshotrate];
coefs = input_data \ ac_sdata.airspeed;

model = fitlm(input_data,ac_sdata.airspeed,"linear",'Intercept', false);


norm_data = ac_sdata.airspeed - (input_data*coefs);
std_f =sqrt(sum(norm_data.^2)/(length(ac_sdata.airspeed)-3));

figure;
plot(ac_sdata.timestamp, input_data*coefs,".b")
hold on
grid on
plot(ac_sdata.timestamp,ac_sdata.airspeed , ".r")
xlabel("Time (s)")
ylabel("Airspeed (m/s)")

%% Vaidating the fits 

p = parselog("C:\MavLab\ESC_Feedback_Log\Flight_Data\24_10_30__17_27_57_SD.data");
ac_tdata = p.aircrafts.data;

ac_s_tdata = data_selector(ac_tdata,v);

%%
test_data = [ones(size(ac_s_tdata.airspeed)) ac_s_tdata.power (ac_s_tdata.power).^2 ...
    ac_s_tdata.rpm (ac_s_tdata.rpm).^2 ac_s_tdata.rpmrate ac_s_tdata.dshot ];
test_ndata = ac_s_tdata.airspeed - (test_data*coefs);
std_t =sqrt(sum(test_ndata.^2 )/(length(ac_s_tdata.airspeed)-3));


figure;
plot(ac_s_tdata.timestamp, ac_s_tdata.airspeed,".r")
hold on
grid on
plot(ac_s_tdata.timestamp, test_data*coefs, ".b")
xlabel("Time (s)")
ylabel("Airspeed (m/s)")

%% Data loading and selection
clear
sel = ["145","148"]; %Put the number code of the flight log you wish to use for analysis.
ac_datalist = data_loader(sel); %When using on your own computer change the path


%% Data Processing (Cuttting and Combining as needed)
v = 10;
ac_s_datalist = data_selector(ac_datalist,v);

 


%% Model Fitting 
%Variable Entries:
%How many data sets are used for training
%Order of RPM,Power,RPM rate
rpm_order = 2;
power_order = 3;
rpmrate_order = 2;

[mdl,test_data] = linear_model_fitter(ac_s_datalist,1,rpm_order,power_order,rpmrate_order);

%% Model Testing 

model_predict(mdl,test_data,rpm_order,power_order,rpmrate_order)


