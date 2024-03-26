function lickometer2(duration)
    dq = daq('ni');

    LickPort = 'Port0/Line3';   % 3rd port on DIO
    dq.Rate = 1000;
    Bin = 0.5;

    mockInput = addinput(dq, 'Dev1', 'ai0', 'Voltage'); % creates a useless channel to initializes the BNC 2090 clock

    LickInput = addinput(dq, 'Dev1', LickPort, 'Digital');
    
    dq.ScansAvailableFcnCount = Bin * dq.Rate;
    
    % send data to failsafe function as well
    dq.ScansAvailableFcn = @(src,evt) failSafe(src,evt);

    % Read data and timestamps
    [data, timestamps, ~] = read(dq, dq.ScansAvailableFcnCount,"OutputFormat", "Matrix");
        
    licks = data(:,2);

    % Do something with the acquired data and timestamps
    disp("Data acquired:");
    disp(data);
    disp("Timestamps:");
    disp(timestamps);
    disp("licks");
    disp(licks);
    
    % Stop the acquisition
    stop(dq);
end

% Failsafe function not to damage anything
function failSafe(src, ~)
    [data, timestamps, ~] = read(src, src.ScansAvailableFcnCount, "OutputFormat","Matrix");

    if any(data >= 1.0)
        disp('Dected voltage exceeding 1V: stopping acquisition')
        % stop conrinuous acquisitions explicitly
        src.stop()
    end
end
