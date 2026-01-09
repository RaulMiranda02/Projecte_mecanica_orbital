function data =  stateVector2orbitalElements(data)

    N = length(data.PRN);

    for k = 1:N
        % Distance
        r_vec = [data.eci.position.x(k),data.eci.position.y(k),data.eci.position.z(k)];
        r = sqrt(dot(r_vec,r_vec));
        r_unit = r_vec./r;
    
        % Velocity
        v_vec = [data.eci.velocity.x(k), data.eci.velocity.y(k), data.eci.velocity.z(k)];
        v = sqrt(dot(v_vec, v_vec));
    
        % Radial velocity
        vr = dot(r_vec, v_vec)/r;
    
        % Specific angular momentum
        h_vec = cross(r_vec, v_vec);    h = sqrt(dot(h_vec,h_vec));
    
        % Orbit excentricity
        mu = 3.9860050e-14; % m^3/s^2, taken from World Geodetic System 1984 (WGS 84)
        mu = mu/1e9;        % km^3/s^2
    
        e_vec = (1/mu)*((v^2 - mu/r)*r_vec - r*vr*v_vec);
        e = sqrt(1 + (h^2 / mu^2)*(v^2 - 2*mu/r));
        e_unit = e_vec./e;
    
        % Orbital parameter p
        p = h^2/mu;
    
        % Semi-major axis
        a = p / (1 - e^2);
        
        % Orbit  inclination
        i = acos(h_vec(3)/h);

        % Line of Nodes
        N_vec = cross([0,0,1], h_vec);  N = sqrt(dot(N_vec,N_vec));
        N_unit = N_vec./N;

        % Right ascension of the ascending node
        if N_vec(2) >= 0
            Omega = acos(N_vec(1)/N);
        else
            Omega = 2*pi - acos(N_vec(1)/N);
        end
            
        % Argument of periapsis
        if e_vec(3) >= 0
            omega = acos(dot(N_unit,e_unit));
        else
            omega = 2*pi - acos(dot(N_unit,e_unit));
        end
      
        % True anomaly
        if vr >= 0
            theta = acos(dot(e_unit, r_unit));
        else
            theta = 2*pi - acos(dot(e_unit, r_unit));
        end
        
        data.orb_params.a(k,1) = a;
        data.orb_params.e(k,:) = e_vec;
        data.orb_params.Omega(k,1) = Omega;
        data.orb_params.i(k,1) = i;
        data.orb_params.omega(k,1) = omega;
        data.orb_params.theta(k,1) = theta;

    end

end