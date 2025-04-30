% clear; 
% close all;

%% 

% 144
% tranges = [261 291];
% 145
tranges = [470 580];

%%
fs = 500;

datarange = [];
for i = 1:size(tranges,1)
    trange = tranges(i,:);
    idx = ac_data.SERIAL_ACT_T4_IN.timestamp >= trange(1) & ...
          ac_data.SERIAL_ACT_T4_IN.timestamp <= trange(2);
    datarange = [datarange idx];
end
datarange = logical(datarange);

%%
t = ac_data.SERIAL_ACT_T4_IN.timestamp;

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

%% Ax = b, x = [Va; Vwn; Vwe]
% b = [groundspeed(datarange,1);
%      groundspeed(datarange,2)];
% A = [cos(psi(datarange)) ones(length(t(datarange)),1) zeros(length(t(datarange)),1);
%      sin(psi(datarange)) zeros(length(t(datarange)),1) ones(length(t(datarange)),1)];
% 
% x = A \ b;

%% Ax = b, x = [k; Vwn; Vwe], Va_real = k*Va
b = [groundspeed(datarange,1);
     groundspeed(datarange,2)];
A = [airspeed(datarange).*cos(psi(datarange)) ones(length(t(datarange)),1) zeros(length(t(datarange)),1);
     airspeed(datarange).*sin(psi(datarange)) zeros(length(t(datarange)),1) ones(length(t(datarange)),1)];

x = A \ b;

figure("Name","Airspeed calib correction"); hold on;
plot(t(datarange), airspeed(datarange), 'DisplayName', 'Measured Airspeed');
plot(t(datarange), x(1)* airspeed(datarange), 'DisplayName', 'Corrected Airspeed');
legend show;

%% Ax = b BUT This logic does not work!
% N = 10;
% 
% idx = find(datarange);
% r = floor(numel(idx)/N);
% 
% xall = zeros(3, N);
% 
% for i = 1:N
%     fprintf("i = %d datarange_local = [%d,%d] -> %d\n", i, datarange_local(1), datarange_local(end), datarange_local(end)-datarange_local(1));
%     datarange_local = idx(1+(i-1)*r):idx(r+(i-1)*r);
%     b = [groundspeed(datarange_local,1);
%          groundspeed(datarange_local,2)];
%     A = [cos(psi(datarange_local)) ones(length(t(datarange_local)),1) zeros(length(t(datarange_local)),1);
%          sin(psi(datarange_local)) zeros(length(t(datarange_local)),1) ones(length(t(datarange_local)),1)];
%     x = A \ b;
%     xall(:, i) = x;
% end
% xall = xall';