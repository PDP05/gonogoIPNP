function lickometer2(duration)
    dq = daq('ni');

    Lick = 3;
    dq.Rate = 1000;
    Bin = 0.5;

    addinput(dq, "Dev1", Lick, 'Voltage');

    dq.ScansAvailableFCNCount = Bin * dq.Rate;

    % Start the acquisition
    start(dq, "Duration", seconds(duration));
    
    % Read data and timestamps
    [data, timestamps, ~] = read(dq, dq.ScansAvailableFCNCount, "OutputFormat", "Matrix");

    % Do something with the acquired data and timestamps
    disp("Data acquired:");
    disp(data);
    disp("Timestamps:");
    disp(timestamps);
    
    % Stop the acquisition
    stop(dq);
end
