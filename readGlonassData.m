function [leapSeconds, data] = readGlonassData(fileName)

    fid = fopen(fileName);      % Object related to the file reader

    for i = 1:7                 % Read file header (first 7 lines)
        a = fgetl(fid);

        if i==6
            leapSeconds = str2double(a(5:6));   % Get LeapSeconds
        end
    end



    nFloat = [19,               % Number of characters for positions, velocities and accelerations 
        12];                    % Number of characters after the 

    k = 0;
    while ~feof(fid)
        k = k+1;                % Line read (blocks of 4 lines), corresponding to a satellite at some point in time

        % First line of the  block, containing: PRN, time
        a = fgetl(fid);
        data.PRN(k) = str2double(a(1:2));
        data.time.year(k) = str2double(a(4:5));
        data.time.month(k) = str2double(a(7:8));
        data.time.day(k) = str2double(a(10:11));
        data.time.hour(k) = str2double(a(13:14));
        data.time.minute(k) = str2double(a(16:17));
        data.time.seconds(k) = str2double(a(20:22));

        % Second line of the block, containing: x axis position, velocity
        % and acceleration (ECEF)
        x = fgetl(fid);
        data.position.x(k) = str2double(x(4:22));
        data.velocity.x(k) = str2double(x(23:41));
        data.acceleration.x(k) = str2double(x(42:60));

        % Third line of the block, containing: y axis position, velocity
        % and acceleration (ECEF)
        y = fgetl(fid);
        data.position.y(k) = str2double(y(4:22));
        data.velocity.y(k) = str2double(y(23:41));     
        data.acceleration.y(k) = str2double(y(42:60));

        % Fourth line of the block, containing: z axis position, velocity
        % and acceleration (ECEF)
        z = fgetl(fid);
        data.position.z(k) = str2double(z(4:22));      
        data.velocity.z(k) = str2double(z(23:41));
        data.acceleration.z(k) = str2double(z(42:60));

    end

end