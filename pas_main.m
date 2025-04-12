%% Variable List  %%
% ac_data: 
% ac_datalist: Struct of data sets 
% ac_sdata: flight data that has been selected and cut to the required size
% mdl: Current model fitted to the data
% mdl_list: list of models currently under anlysis

clear p ac_data
close all

addpath('tools/');

% Data loading and selection
sel = ["148","145"]; %Put the number code of the flight log you wish to use for analysis.
ac_datalist = data_loader(sel); %You will have to change the path in this function to match where you have the files


%% Data Processing 
v = 10;
ac_s_datalist = data_selector(ac_datalist,v);

%% Model Fitting 
%Variable Entries:
%How many data sets are used for training
%Order of RPM,Power,RPM rate
rpm_order = 2;
power_order = 2;
rpmrate_order = 1;

[mdl,test_data] = linear_model_fitter(ac_s_datalist,1,rpm_order,power_order,rpmrate_order);

%% Model Testing 

model_predict(mdl,test_data,rpm_order,power_order,rpmrate_order)


