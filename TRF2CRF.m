function data=TRF2CRF(data)

t=data.time;

%1) Compute GMST
UT1_UTC=0.2/3600; % Obtingut de https://datacenter.iers.org/data/6/bulletina-xxii-033.txt
t.UTC=t.seconds/3600+t.minute/60+t.hour;
t.UT1=t.UTC+UT1_UTC;

y = t.year + 2000;
m = t.month;
I = (m <= 2);
y(I) = y(I) - 1;
m(I) = m(I) + 12;
t.JD_UT1=floor(365.25*y) + floor(30.6001*(m+1)) + t.day + (t.UT1/24) + 1720981.5;

TJC=(t.JD_UT1-2451545.0)/36525;
GMST0=24110.54841+8640184.812866*TJC+0.093104*TJC.^2-6.2E-6*TJC.^3;
t.GMST=1.02737909350795*(t.UT1*3600)+GMST0;

t.GMSTdeg = (360/86400)*mod(t.GMST,86400);  % Seconds to deg
t.GMSTrad = t.GMSTdeg*pi/180;


%2) Terrestrial (TRF) to celestial (ECI) transform

for i = 1:length(t.GMSTdeg)
    
    X = R3Z(t.GMSTrad(i))*[data.position.x(i), data.position.y(i), data.position.z(i)]';
    
    data.eci.position.x(i) = X(1,:);
    data.eci.position.y(i) = X(2,:);
    data.eci.position.z(i) = X(3,:);
    
    r_eci = [data.eci.position.x(i), data.eci.position.y(i), data.eci.position.z(i)];
    omega_dot = [0,0, 2*pi/86400];

    V = cross(omega_dot, r_eci)' + R3Z(t.GMSTrad(i))*[data.velocity.x(i), ...
                                      data.velocity.y(i), data.velocity.z(i)]';
    
    data.eci.velocity.x(i) = V(1,:);
    data.eci.velocity.y(i) = V(2,:);
    data.eci.velocity.z(i) = V(3,:);
end

end