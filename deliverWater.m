function deliverWater()

    % Create a data acquisition session
    s = daq('ni');

    % Add a digital output channel for the TTL signal
    addinput(s, 'Dev1', 'Port0/Line0', 'OutputOnly');

    % Generate TTL pulse
    outputData = logical([1; 0]);  % High for 1 sample, then low
    addoutput(s, outputData);

    % Clean up
    release(s);
end
