function [data, err] = cart2elip(data)

a = 6378.137;
e = 0.081819;
p = sqrt(data.position.x.^2 + data.position.y.^2);
data.position.elip.long = atan(data.position.y./data.position.x);
data.position.elip.lat = atan((data.position.z./(p))./(1-e^2));

thresh = 10e-10;
err = 10e9;
it = 1;
while (err > thresh)
    lat = data.position.elip.lat;
    N = a./sqrt(1-(e^2.*sin(lat).^2));
    h = p/(cos(lat)) - N;
    lat_prev = lat;
    data.position.elip.lat = atan((data.position.z./p)./(1-e^2.*(N./(N+h))));
    data.position.elip.h = h;
    err(it) = max(data.position.elip.lat - lat_prev);
    it = it + 1;
end

end