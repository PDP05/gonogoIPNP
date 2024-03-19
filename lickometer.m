function licks_count = lickometer(duration)
    daqreset(); % resets the counter to 0
    % Define DAQ parameters
    sample_rate = 1000; % Sample rate in Hz
    duration_sec = duration; % Duration of acquisition in seconds

    % Create DAQ session
    s = daq.createSession('ni');
    addAnalogInputChannel(s, 'Dev1', 0, 'Voltage'); % Modify 'Dev1' and channel number accordingly

    % Configure acquisition parameters
    s.Rate = sample_rate;
    s.DurationInSeconds = duration_sec;

    % Start acquisition
    disp('Acquiring licks...');
    data = s.startBackground();

    % Count licks (assuming lick signal is above a certain threshold)
    lick_threshold = 0.5; % Modify threshold value according to your lick sensor
    licks_count = sum(data > lick_threshold);

    % Release DAQ resources
    delete(s);

    disp(['Licks detected: ', num2str(licks_count)]);
end
