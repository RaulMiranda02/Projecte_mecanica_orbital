function [lonOut, latOut] = break_antimeridian(lon, lat)
% Function to add a NaN value between the latitudes and longitudes where
% 180º lies so that in the plots there are no lines going across the map.
lon = lon(:); lat = lat(:);
d = abs(diff(lon));
breaks = find(d > 180);
lonOut = lon; latOut = lat;
for k = numel(breaks):-1:1
    b = breaks(k);
    lonOut = [lonOut(1:b); NaN; lonOut(b+1:end)];
    latOut = [latOut(1:b); NaN; latOut(b+1:end)];
end
end

