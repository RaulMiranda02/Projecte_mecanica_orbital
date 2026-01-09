function [results]=RungeKutta(data,prnTarget,perturb)

% ---------------- select PRN ----------------
if perturb
    k=1;
else
    k=0;
end

prn = data.PRN(:);
I = (prn == prnTarget);

X=data.position.x(I)*1000;
Y=data.position.y(I)*1000;
Z=data.position.z(I)*1000;

VX=data.velocity.x(I)*1000;
VY=data.velocity.y(I)*1000;
VZ=data.velocity.z(I)*1000;

AX=data.acceleration.x(I)*1000;
AY=data.acceleration.y(I)*1000;
AZ=data.acceleration.z(I)*1000;

T=data.time.UTC(I)*3600;
YY=data.time.year(I);
MM=data.time.month(I);
DD=data.time.day(I);

% input data

e=data.EarthData;

y=zeros(6,86400);

for i=1:length(T)
    % Ascendent integration
    ti=T(i);
    y(:,ti)=[X(i),Y(i),Z(i),VX(i),VY(i),VZ(i)]';
    a(:,ti)=[VX(i),VY(i),VZ(i),AX(i),AY(i),AZ(i)];
    h=1;

    for m=1:900
        r=sqrt(y(1,ti)^2+y(2,ti)^2+y(3,ti)^2);
        GMSTrad=ComputeGMST(ti/3600,YY(i),MM(i),DD(i));
        a_SM=R3Z(GMSTrad)*[AX(i),AY(i),AZ(i)]';

        f1=[y(4,ti);
            y(5,ti);
            y(6,ti);
            -(e.mu_E/r^2)*(y(1,ti)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y(3,ti)/r)^2)*(y(1,ti)/r)+k*a_SM(1);
            -(e.mu_E/r^2)*(y(2,ti)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y(3,ti)/r)^2)*(y(2,ti)/r)+k*a_SM(2);
            -(e.mu_E/r^2)*(y(3,ti)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y(3,ti)/r)^2)*(y(3,ti)/r)+k*a_SM(3)];

        y1=y(:,ti)+(0.5*h)*f1;

        GMSTrad=ComputeGMST((ti+(0.5*h))/3600,YY(i),MM(i),DD(i));
        a_SM=R3Z(GMSTrad)*[AX(i),AY(i),AZ(i)]';

        f2= [y1(4);
            y1(5);
            y1(6);
            -(e.mu_E/r^2)*(y1(1)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y1(3)/r)^2)*(y1(1)/r)+k*a_SM(1);
            -(e.mu_E/r^2)*(y1(2)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y1(3)/r)^2)*(y1(2)/r)+k*a_SM(2);
            -(e.mu_E/r^2)*(y1(3)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y1(3)/r)^2)*(y1(3)/r)+k*a_SM(3)];

        y2=y(:,ti)+(0.5*h)*f2;

        f3= [y2(4);
            y2(5);
            y2(6);
            -(e.mu_E/r^2)*(y2(1)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y2(3)/r)^2)*(y2(1)/r)+k*a_SM(1);
            -(e.mu_E/r^2)*(y2(2)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y2(3)/r)^2)*(y2(2)/r)+k*a_SM(2);
            -(e.mu_E/r^2)*(y2(3)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y2(3)/r)^2)*(y2(3)/r)+k*a_SM(3)];

        y3=y(:,ti)+h*f3;

        GMSTrad=ComputeGMST((ti+h)/3600,YY(i),MM(i),DD(i));
        a_SM=R3Z(GMSTrad)*[AX(i),AY(i),AZ(i)]';

        f4= [y3(4);
            y3(5);
            y3(6);
            -(e.mu_E/r^2)*(y3(1)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y3(3)/r)^2)*(y3(1)/r)+k*a_SM(1);
            -(e.mu_E/r^2)*(y3(2)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y3(3)/r)^2)*(y3(2)/r)+k*a_SM(2);
            -(e.mu_E/r^2)*(y3(3)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y3(3)/r)^2)*(y3(3)/r)+k*a_SM(3)];

        y(:,ti+h) = y(:,ti)+h*((1/6)*f1+(1/3)*f2+(1/3)*f3+(1/6)*f4);
        a(:,ti+h)=((1/6)*f1+(1/3)*f2+(1/3)*f3+(1/6)*f4);
        ti = ti+h;
        
    end
    % Descendent integration
    ti=T(i);
    y(:,ti)=[X(i),Y(i),Z(i),VX(i),VY(i),VZ(i)]';
    h=-1;

    for m=1:899
        r=sqrt(y(1,ti)^2+y(2,ti)^2+y(3,ti)^2);
        GMSTrad=ComputeGMST(ti/3600,YY(i),MM(i),DD(i));
        a_SM=R3Z(GMSTrad)*[AX(i),AY(i),AZ(i)]';

        f1=[y(4,ti);
            y(5,ti);
            y(6,ti);
            -(e.mu_E/r^2)*(y(1,ti)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y(3,ti)/r)^2)*(y(1,ti)/r)+k*a_SM(1);
            -(e.mu_E/r^2)*(y(2,ti)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y(3,ti)/r)^2)*(y(2,ti)/r)+k*a_SM(2);
            -(e.mu_E/r^2)*(y(3,ti)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y(3,ti)/r)^2)*(y(3,ti)/r)+k*a_SM(3)];

        y1=y(:,ti)+(0.5*h)*f1;

        GMSTrad=ComputeGMST((ti+(0.5*h))/3600,YY(i),MM(i),DD(i));
        a_SM=R3Z(GMSTrad)*[AX(i),AY(i),AZ(i)]';

        f2= [y1(4);
            y1(5);
            y1(6);
            -(e.mu_E/r^2)*(y1(1)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y1(3)/r)^2)*(y1(1)/r)+k*a_SM(1);
            -(e.mu_E/r^2)*(y1(2)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y1(3)/r)^2)*(y1(2)/r)+k*a_SM(2);
            -(e.mu_E/r^2)*(y1(3)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y1(3)/r)^2)*(y1(3)/r)+k*a_SM(3)];

        y2=y(:,ti)+(0.5*h)*f2;

        f3= [y2(4);
            y2(5);
            y2(6);
            -(e.mu_E/r^2)*(y2(1)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y2(3)/r)^2)*(y2(1)/r)+k*a_SM(1);
            -(e.mu_E/r^2)*(y2(2)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y2(3)/r)^2)*(y2(2)/r)+k*a_SM(2);
            -(e.mu_E/r^2)*(y2(3)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y2(3)/r)^2)*(y2(3)/r)+k*a_SM(3)];

        y3=y(:,ti)+h*f3;

        GMSTrad=ComputeGMST((ti+h)/3600,YY(i),MM(i),DD(i));
        a_SM=R3Z(GMSTrad)*[AX(i),AY(i),AZ(i)]';

        f4= [y3(4);
            y3(5);
            y3(6);
            -(e.mu_E/r^2)*(y3(1)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y3(3)/r)^2)*(y3(1)/r)+k*a_SM(1);
            -(e.mu_E/r^2)*(y3(2)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y3(3)/r)^2)*(y3(2)/r)+k*a_SM(2);
            -(e.mu_E/r^2)*(y3(3)/r)-k*(3/2)*e.J2*(e.mu_E/r^2)*(e.R_E^2/r^2)^2*(1-5*(y3(3)/r)^2)*(y3(3)/r)+k*a_SM(3)];

        y(:,ti+h) = y(:,ti)+h*((1/6)*f1+(1/3)*f2+(1/3)*f3+(1/6)*f4);
        a(:,ti+h)=((1/6)*f1+(1/3)*f2+(1/3)*f3+(1/6)*f4);
        ti = ti+h;
        
    end

end

results.position.x=y(1,:);
results.position.y=y(2,:);
results.position.z=y(3,:);
results.position.r=sqrt(y(1,:).^2+y(2,:).^2+y(3,:).^2);
results.velocity.x=y(4,:);
results.velocity.y=y(5,:);
results.velocity.z=y(6,:);
results.velocity.total=sqrt(y(4,:).^2+y(5,:).^2+y(6,:).^2);
results.acceleration.x=a(4,:);
results.acceleration.y=a(5,:);
results.acceleration.z=a(6,:);
results.acceleration.total=sqrt(a(4,:).^2+a(5,:).^2+a(6,:).^2);
end