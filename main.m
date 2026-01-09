clc; clear; close all;


%% Projecte Mec Orbital

% Data reading
[leapseconds, data] = readGlonassData("brdc2320.09g");
data.EarthData.mu_E = 3.986E14;         % m^3/s^2
data.EarthData.R_E  = 6378.1363E3;      % m
data.EarthData.J2   = 1.0826257E-3;     % -
PRN=11;

% Question 1
[data, err] = cart2elip(data);

plot(err);

orbit_vis(data);

%Question 2
data = TRF2CRF(data);

[data.eci, err] = cart2elip(data.eci);

orbit_vis(data);

orbit_vis_compare_tracks_vel(data,PRN);

%Question 3
data = stateVector2orbitalElements(data);

%Question 4
results=RungeKutta(data,PRN,true);

figure()
hold on
plot(results.acceleration.x)
plot(results.acceleration.y)
plot(results.acceleration.z)
plot(results.acceleration.total)
xlabel("UTC (s)")
ylabel("Acceleration (m/s^2)")
legend("x axis","y axis","z axis","total")
hold off

figure()
plot(results.acceleration.total)
ylim([0.61,0.62])
xlabel("UTC (s)")
ylabel("Acceleration (m/s^2)")

results_NP=RungeKutta(data,PRN,false);

figure()
plot(results_NP.acceleration.total)
ylim([0.61,0.62])
xlabel("UTC (s)")
ylabel("Acceleration (m/s^2)")
