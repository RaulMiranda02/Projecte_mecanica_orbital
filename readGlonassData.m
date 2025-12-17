function [leapSeconds, data] = readGlonassData(fileName)

    fid = fopen(fileName);      % Object related to the file reader

    for i = 1:7                 % Skip the four
        a = fgetl(fid);

        if i==6
            leapSeconds = str2double(a(5:6));
        end
    end



    nFloat = [19,               % Number of characters for positions, velocities and accelerations 
        12];                    % Number of characters after the 

    k = 0;
    while ~feof(fid)
        k = k+1;                % Line read (each 4), corresponding to a satellite in some time

        % Línia de PRN, temps ...
        a = fgetl(fid);
        data.PRN(k) = str2double(a(1:2));
        data.time(k).year = str2double(a(4:5));
        data.time(k).month = str2double(a(7:8));
        data.time(k).day = str2double(a(10:11));
        data.time(k).hour = str2double(a(13:14));
        data.time(k).minute = str2double(a(16:17));
        data.time(k).seconds = str2double(a(20:22));

        x = fgetl(fid);
        data.position(k).x = str2double(x(4:22));
        data.velocity(k).x = str2double(x(23:41));
        data.acceleration(k).x = str2double(x(42:60));

        y = fgetl(fid);
        data.position(k).y = str2double(y(4:22));
        data.velocity(k).y = str2double(y(23:41));     
        data.acceleration(k).y = str2double(y(42:60));

        z = fgetl(fid);
        data.position(k).z = str2double(z(4:22));      
        data.velocity(k).z = str2double(z(23:41));
        data.acceleration(k).z = str2double(z(42:60));

    end

end