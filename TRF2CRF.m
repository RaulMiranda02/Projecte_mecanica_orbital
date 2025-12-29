function [data,GMST]=TRF2CRF(data)

t=data.time;

%1) Compute GMST
UT1_UTC=0.2; % Obtingut de https://datacenter.iers.org/data/6/bulletina-xxii-033.txt
t.UTC=t.seconds+t.minute*60+t.hour*3600;
t.UT1=t.UTC+UT1_UTC;
t.JD_UT1=round(365.25*t.year)+round(30.6001*(t.month+1))+(t.UT1/24)+1720981.5;
TJC=(t.JD_UT1-2451545.0)/36525;
GMST0=24110.54841+8640184.812866*TJC+0.093104*TJC.^2+6.2E-6*TJC.^3;
t.GMST=1.02737909350795*(t.UT1)+t.day+GMST0;

%Conversió a deg a la diapo 25, comentari verd

%2) 

data.time=t;
end