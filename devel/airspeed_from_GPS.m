% clear; 
    close all;

%% 

% 144
tranges = [260 290; 300 320];
% 145
% tranges = [470 590];

%%
t = ac_data.SERIAL_ACT_T4_IN.timestamp;
% t = ac_data.AIR_DATA.timestamp;

fs = 500;

datarange = zeros(length(t),1);
for i = 1:size(tranges,1)
    trange = tranges(i,:);
    idx = t >= trange(1) & t <= trange(2);
    datarange = datarange | idx;
end
datarange = logical(datarange);

%%
quat = double([ac_data.AHRS_REF_QUAT.body_qi ac_data.AHRS_REF_QUAT.body_qx ac_data.AHRS_REF_QUAT.body_qy ac_data.AHRS_REF_QUAT.body_qz]);
refquat = double([ac_data.AHRS_REF_QUAT.ref_qi ac_data.AHRS_REF_QUAT.ref_qx ac_data.AHRS_REF_QUAT.ref_qy ac_data.AHRS_REF_QUAT.ref_qz]);
[refquat_t,irefquat_t,~] = unique(ac_data.AHRS_REF_QUAT.timestamp);
quat = quat(irefquat_t,:);
refquat = refquat(irefquat_t,:);
[psi, ~, ~] = quat2angle(quat,'ZXY');

airspeed = interp1(ac_data.AIR_DATA.timestamp, ac_data.AIR_DATA.airspeed, t, "linear", "extrap");
groundspeed = [interp1(ac_data.ROTORCRAFT_FP.timestamp, ac_data.ROTORCRAFT_FP.vnorth_alt, t, "linear", "extrap"), ...
               interp1(ac_data.ROTORCRAFT_FP.timestamp, ac_data.ROTORCRAFT_FP.veast_alt, t, "linear", "extrap")];
psi = interp1(ac_data.AHRS_REF_QUAT.timestamp, psi, t, "linear", "extrap");

%% Ax = b, x = [k; Vwn; Vwe], Va_real = k*Va_meas
b = [groundspeed(datarange,1);
     groundspeed(datarange,2)];
A = [airspeed(datarange).*cos(psi(datarange)) ones(length(t(datarange)),1) zeros(length(t(datarange)),1);
     airspeed(datarange).*sin(psi(datarange)) zeros(length(t(datarange)),1) ones(length(t(datarange)),1)];

x = A \ b;

figure("Name","Airspeed calib correction"); hold on;
plot(t(datarange), airspeed(datarange), 'DisplayName', 'Measured Airspeed');
plot(t(datarange), x(1)* airspeed(datarange), 'DisplayName', 'Corrected Airspeed');
legend show;

figure("Name","psi");
plot(t(datarange),psi(datarange));

%% Try LS for Va(t)
% b = [groundspeed(datarange,1);
%      groundspeed(datarange,2)];
% A = [diag(cos(psi(datarange))) ones(length(t(datarange)),1) zeros(length(t(datarange)),1);
%      diag(sin(psi(datarange))) zeros(length(t(datarange)),1) ones(length(t(datarange)),1)];
% 
% x = A \ b;
% 
% figure("Name","Va from Vg"); hold on;
% plot(t(datarange), airspeed(datarange), 'DisplayName', 'Real');
% plot(t(datarange), x(1:end-2), 'DisplayName', 'Estimated');
% legend show;
% 
% figure("Name","psi");
% plot(t(datarange),psi(datarange));