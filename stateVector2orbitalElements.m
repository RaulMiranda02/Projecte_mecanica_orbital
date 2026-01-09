function dataOut =  stateVector2orbitalElements(data)

    prnAll = data.PRN(:);
    prnList = unique(prnAll);
    nSats = numel(prnList);
    
    % preallocate outputs
    dataOut = data;
    dataOut.orb_params.PRN        = prnList;
    dataOut.orb_params.a          = nan(nSats,1);
    dataOut.orb_params.e          = nan(nSats,1);
    dataOut.orb_params.e_vec      = nan(nSats,3);
    dataOut.orb_params.i_rad      = nan(nSats,1);
    dataOut.orb_params.Omega_rad  = nan(nSats,1);
    dataOut.orb_params.omega_rad  = nan(nSats,1);
    dataOut.orb_params.theta_rad  = nan(nSats,1);

    for s =1:nSats

        prn = prnList(s);
        I = (prnAll == prn);

        x  = data.position.x(I);
        y  = data.position.y(I);
        z  = data.position.z(I);
        vx = data.velocity.x(I);
        vy = data.velocity.y(I);
        vz = data.velocity.z(I);

        nk = length(data.position.x(I));

        % Per-epoch storage
        a_k   = nan(nk,1);
        e_k   = nan(nk,1);
        evec_k= nan(nk,3);
        i_k   = nan(nk,1);
        Om_k  = nan(nk,1);
        om_k  = nan(nk,1);
        th_k  = nan(nk,1);
    
        for k = 1:nk
            % Distance
            r_vec = [x(k),y(k),z(k)];
            r = sqrt(dot(r_vec,r_vec));
            r_unit = r_vec./r;
        
            % Velocity
            v_vec = [vx(k), vy(k), vz(k)];
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
            
            a_k(k)      = a;
            e_k(k)      = e;
            evec_k(k,:) = e_vec;
            i_k(k)      = i;
            Om_k(k)     = Omega;
            om_k(k)     = omega;
            th_k(k)     = theta;
    
        end

        dataOut.orb_params.a(s)         = mean(a_k);
        dataOut.orb_params.e(s)         = mean(e_k);
        dataOut.orb_params.e_vec(s,:)   = mean(evec_k,1);
        dataOut.orb_params.i_rad(s)     = mean(i_k);
        dataOut.orb_params.Omega_rad(s) = mean(Om_k);
        dataOut.orb_params.omega_rad(s) = mean(om_k);
        dataOut.orb_params.theta_rad(s) = mean(th_k);

    end

end