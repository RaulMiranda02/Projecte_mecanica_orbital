clc; clear; close all;


%% Projecte Mec Orbital

% Data reading
[leapseconds, data] = readGlonassData("brdc2320.09g");

[data, err] = cart2elip(data);

plot(err);

orbit_vis(data);

data = TRF2CRF(data);

[data.eci, err] = cart2elip(data.eci);

orbit_vis(data);

orbit_vis_compare_tracks_vel(data,11);

data = stateVector2orbitalElements(data);