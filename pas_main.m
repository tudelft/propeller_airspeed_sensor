%% Variable List  %%
% ac_data: 
% ac_datalist: Struct of data sets 
% ac_sdata: flight data that has been selected and cut to the required size
% mdl: Current model fitted to the data
% mdl_list: list of models currently under anlysis

clear p ac_datalist ac_s_datalist train_data test_data
close all

addpath('tools/');

% Data loading and selection
sel = ["144","145"]; %Put the number code of the flight log you wish to use for analysis.
ac_datalist = data_loader(sel);
%You will have to change the path in this function to match where you have the files
%% Data Processing 
v = 10;
ac_s_datalist = data_selector(ac_datalist,v);
%% Data Merging 
set_num = 1; %Number of test sets
%t_list = {"ac_data144", "ac_data145"};
[train_data,test_data] = data_merger(ac_s_datalist,set_num); 
% works to combine the training set into one large set
%Currently only leaves one set for testing the rest are combined into a
%training set
%% Model Fitting 
%Variable Entries:
%How many data sets are used for training
%Order of RPM,Power,RPM rate
rpm_order = 2;
power_order = 2;
rpmrate_order = 2;
mdl = linear_model_fitter(train_data,rpm_order,power_order,rpmrate_order);

%% Model Save
%Saves the model to a list 
%Simply generate a new model above then add it by running this breakpoint
i = length(fieldnames(mdl_str))+1;
mdl_str.("mdl" + num2str(i)) = mdl;
order_str.("mdl" + num2str(i)) = [rpm_order power_order rpmrate_order];
%% Model Clear 
%Clears the model list
i = 0;
order_str = struct();
mdl_str = struct();
%% Model Testing 
model_predict(mdl_str,test_data,order_str)


