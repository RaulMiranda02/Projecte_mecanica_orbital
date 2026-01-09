function GMSTrad=ComputeGMST(UTC,year,month,day)

UT1_UTC=0.2/3600; % Obtingut de https://datacenter.iers.org/data/6/bulletina-xxii-033.txt
UT1=UTC+UT1_UTC;

y = year + 2000;
m = month;
I = (m <= 2);
y(I) = y(I) - 1;
m(I) = m(I) + 12;
JD_UT1=floor(365.25*y) + floor(30.6001*(m+1)) + day + (UT1/24) + 1720981.5;

TJC=(JD_UT1-2451545.0)/36525;
GMST0=24110.54841+8640184.812866*TJC+0.093104*TJC.^2-6.2E-6*TJC.^3;
GMST=1.02737909350795*(UT1*3600)+GMST0;

GMSTdeg = (360/86400)*mod(GMST,86400);  % Seconds to deg
GMSTrad = GMSTdeg*pi/180;

end