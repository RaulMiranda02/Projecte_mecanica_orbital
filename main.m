clc; clear; close all;


%% Projecte Mec Orbital

% Data reading
[leapseconds, data] = readGlonassData("brdc2320.09g");

[data, err] = cart2elip(data);

plot(err);

orbit_vis(data);

data = TRF2CRF(data);