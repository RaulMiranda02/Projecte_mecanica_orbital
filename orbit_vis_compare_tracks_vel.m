function orbit_vis_compare_tracks_vel(data, prnTarget)
%ORBIT_VIS_COMPARE_TRACKS_VEL
% Plot ECEF ground track and ECI ground track together
% for ONE PRN, colored by instantaneous velocity magnitude.
%
% REQUIRED fields:
%   data.position.elip.lat / long        [rad]
%   data.velocity.x / y / z              [km/s]
%   data.eci.position.elip.lat / long    [rad]
%   data.eci.velocity.x / y / z          [km/s]

% ---------------- select PRN ----------------
prn = data.PRN(:);
I = (prn == prnTarget);
if ~any(I)
    error('PRN %d not found in data.PRN.', prnTarget);
end

% ---------------- ECEF lat/lon ----------------
latE = data.position.elip.lat(:)*180/pi;   latE = latE(I);
lonE = data.position.elip.long(:)*180/pi;  lonE = lonE(I);
lonE = wrapTo180(lonE);

% ---------------- ECEF speed (m/s) ----------------
vE = sqrt(data.velocity.x(:).^2 + ...
                 data.velocity.y(:).^2 + ...
                 data.velocity.z(:).^2);
vE = vE(I) * 1000;   % km/s → m/s

% ---------------- ECI lat/lon ----------------
latI = data.eci.position.elip.lat(:)*180/pi;   latI = latI(I);
lonI = data.eci.position.elip.long(:)*180/pi;  lonI = lonI(I);
lonI = wrapTo180(lonI);

% ---------------- ECI speed (m/s) ----------------
vI = sqrt(data.eci.velocity.x(:).^2 + ...
                 data.eci.velocity.y(:).^2 + ...
                 data.eci.velocity.z(:).^2);
vI = vI(I) * 1000;   % km/s → m/s

% ---------------- antimeridian breaks ----------------
[lonE2, latE2, vE2] = break_antimeridian_with_value(lonE, latE, vE);
[lonI2, latI2, vI2] = break_antimeridian_with_value(lonI, latI, vI);

% ---------------- shared color limits ----------------
vAll = [vE2; vI2];
clim = [min(vAll) max(vAll)];
if clim(1) == clim(2)
    clim = clim + [-1 1]*0.5;
end

% ======================================================================
% Plot
% ======================================================================
figure('Name', sprintf('PRN %02d – Ground Tracks (velocity-colored)', prnTarget), ...
       'NumberTitle','off');
ax = axes;
hold(ax,'on'); box(ax,'on'); grid(ax,'on');
xlabel(ax,'Longitude [deg]');
ylabel(ax,'Latitude [deg]');
title(ax, sprintf('PRN %02d: ECEF vs ECI (colored by |v|)', prnTarget));

% Coastlines
try
    S = load('coastlines.mat');
    plot(ax, S.coastlon, S.coastlat, 'k-', 'HandleVisibility','off');
catch
    rectangle(ax,'Position',[-180 -90 360 180],'EdgeColor','k');
end

xlim(ax,[-180 180]);
ylim(ax,[-90 90]);

colormap(ax, turbo);
set(ax,'CLim',clim);

% ECEF track

plot(ax, lonE2, latE2, '-', ...
    'Color',[0.2 0.2 0.2], ...      
    'LineWidth',1.2, ...
    'HandleVisibility','off');      

scatter(ax, lonE2, latE2, 30, vE2, 'filled', ...
    'DisplayName','ECEF track');

% ECI track (different marker)

plot(ax, lonI2, latI2, '-', ...
    'Color',[0.2 0.2 0.2], ...
    'LineWidth',1.2, ...
    'LineStyle','--', ...          
    'HandleVisibility','off');

scatter(ax, lonI2, latI2, 30, vI2, 'filled', ...
    'Marker','s', ...
    'DisplayName','ECI track');

cb = colorbar(ax);
cb.Label.String = '|v| [m/s]';

legend(ax,'Location','best');

end

function [lonOut, latOut, valOut] = break_antimeridian_with_value(lon, lat, val)
lon = lon(:); lat = lat(:); val = val(:);
d = abs(diff(lon));
breaks = find(d > 180);

lonOut = lon; latOut = lat; valOut = val;
for k = numel(breaks):-1:1
    b = breaks(k);
    lonOut = [lonOut(1:b); NaN; lonOut(b+1:end)];
    latOut = [latOut(1:b); NaN; latOut(b+1:end)];
    valOut = [valOut(1:b); NaN; valOut(b+1:end)];
end
end
