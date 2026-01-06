function [data, err] = cart2elip(data)
% Description: function for transforming TRF (ECEF) (x,y,z) coordinates to
% elipsoidal geodetic coordinates (lambda, phi, h)
%
% Inputs:
%   data       struct
%
% Outputs:
%   data       struct
%   err        [1 x it] vector with the error of each iteration of the
%                       latitude iterative procedure

% Geode parameters from World Geodetic System 1984
a = 6378.137;
e = 0.081819;

% Longitude computation
data.position.elip.long = atan2(data.position.y,data.position.x);

% Latitude iterative computation procedure
p = sqrt(data.position.x.^2 + data.position.y.^2);
lat = atan((data.position.z./(p))./(1-e^2)); % Initial value

thresh = 1e-12;
err = [];
for it = 1:100
    N = a./sqrt(1-(e^2.*sin(lat).^2));
    h = p/(cos(lat)) - N;
    lat_new = atan((data.position.z./p)./(1-e^2.*(N./(N+h))));
    err(it) = max(lat_new - lat);
    lat  = lat_new;
    if err(it) < thresh
        break;
    end
end

data.position.elip.lat = lat;
data.position.elip.h   = h;

end