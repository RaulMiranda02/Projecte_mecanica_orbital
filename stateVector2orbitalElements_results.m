function data =  stateVector2orbitalElements_results(data)

    N = 48;

    for k = 1:N
        % Distance
        r_vec = [data.position.x((k*1800)-1799:k*1800);data.position.y((k*1800)-1799:k*1800);data.position.z((k*1800)-1799:k*1800)];
        r = sqrt(dot(r_vec,r_vec));
        r_unit = r_vec./r;
    
        % Velocity
        v_vec = [data.velocity.x((k*1800)-1799:k*1800); data.velocity.y((k*1800)-1799:k*1800); data.velocity.z((k*1800)-1799:k*1800)];
        v = sqrt(dot(v_vec, v_vec));
    
        % Radial velocity
        vr = dot(r_vec, v_vec)./r;
    
        % Specific angular momentum
        for i=1:1800
        h_vec(:,i) = cross(r_vec(:,i), v_vec(:,i));    h(:,i) = sqrt(dot(h_vec(:,i),h_vec(:,i)));
        end
    
        % Orbit excentricity
        mu = 3.9860050e-14; % m^3/s^2, taken from World Geodetic System 1984 (WGS 84)
    
        e_vec = (1/mu)*((v.^2 - mu./r).*r_vec - r.*vr.*v_vec);
        e = sqrt(1 + (h.^2 / mu^2).*(v.^2 - 2*mu./r));
        e_unit = e_vec./e;
    
        % Orbital parameter p
        p = h.^2/mu;
    
        % Semi-major axis
        a = p./(1 - e.^2);
        
        % Orbit  inclination
        I = acos(h_vec(3,:)./h);

        % Line of Nodes
        for i=1:1800
        N_vec(:,i) = cross([0;0;1], h_vec(:,i));  N(:,i) = sqrt(dot(N_vec(:,i),N_vec(:,i)));
        N_unit(:,i) = N_vec(:,i)./N(:,i);
        end

        % Right ascension of the ascending node
        for i=1:1800
        if N_vec(2,i) >= 0
            Omega(:,i) = acos(N_vec(1,i)./N(:,i));
        else
            Omega(:,i) = 2*pi - acos(N_vec(1,i)./N(:,i));
        end
        end
            
        % Argument of periapsis
        for i=1:1800
        if e_vec(3,i) >= 0
            omega(:,i) = acos(dot(N_unit(:,i),e_unit(:,i)));
        else
            omega(:,i) = 2*pi - acos(dot(N_unit(:,i),e_unit(:,i)));
        end
        end
      
        % True anomaly
        for i=1:1800
        if vr(i) >= 0
            theta(:,i) = acos(dot(e_unit(:,i), r_unit(:,i)));
        else
            theta(:,i) = 2*pi - acos(dot(e_unit(:,i), r_unit(:,i)));
        end
        end
        
        data.orb_params.a(k,1) = mean(a);
        data.orb_params.e(k,:) = mean(e_vec,2);
        data.orb_params.Omega(k,1) = mean(Omega);
        data.orb_params.i(k,1) = mean(I);
        data.orb_params.omega(k,1) = mean(omega);
        data.orb_params.theta(k,1) = mean(theta);

    end

end