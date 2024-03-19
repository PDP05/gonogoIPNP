function deliverPuff()
    % Check if Data Acquisition Toolbox is available
    if ~license('test', 'Data_Acquisition_Toolbox')
        error('Data Acquisition Toolbox is required to run this function.');
    end

    % Create a data acquisition session
    s = daq('ni');

    % Add a digital output channel for the TTL signal
    addinput(s, 'Dev1', 'Port1/Line0', 'OutputOnly');

    % Generate TTL pulse
    outputData = logical([1; 0]);  % High for 1 sample, then low
    addoutput(s, outputData);

    % Clean up
    release(s);
end
