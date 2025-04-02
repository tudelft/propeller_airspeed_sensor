clear p ac_data
close all

addpath('tools/');

p = parselog('C:\MavLab\ESC_Feedback_Log\Flight_Data\24_10_30__16_45_37_SD.data');
ac_data = p.aircrafts.data;


%% Old Data Loading (temporary may not work with new curve fitter with more variables)

 l_file = load("FL_254_Omega_R_P.mat");
 ac_sdata = l_file.data;

%% Data Slicing 
v = 10; % Velocity you want to cut at 
ac_sdata = data_slicer(ac_data,v);
%% Basic Curve Fitting 

input_data = [ones(size(ac_sdata.airspeed)) ac_sdata.power (ac_sdata.power).^2 ac_sdata.rpm (ac_sdata.rpm).^2 ac_sdata.rpmrate ];
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

ac_s_tdata = data_slicer(ac_tdata,v);

%%
test_data = [ones(size(ac_s_tdata.airspeed)) ac_s_tdata.power (ac_s_tdata.power).^2 ...
    ac_s_tdata.rpm (ac_s_tdata.rpm).^2 ac_s_tdata.rpmrate ];
test_ndata = ac_s_tdata.airspeed - (test_data*coefs);
std_t =sqrt(sum(test_ndata.^2 )/(length(ac_s_tdata.airspeed)-3));


figure;
plot(ac_s_tdata.timestamp, ac_s_tdata.airspeed,".r")
hold on
grid on
plot(ac_s_tdata.timestamp, test_data*coefs, ".b")
xlabel("Time (s)")
ylabel("Airspeed (m/s)")