daqreset;

dq = daq('ni');
AQDuration = 5;
LickPort = 'ctr0';   % PFI8

addinput(dq, 'Dev1', 'ai0', 'Voltage'); % creates a useless channel to initialze the clock
addinput(dq, 'Dev1', LickPort, 'EdgeCount'); % actual lickometer input channel

dq.ScansAvailableFcn = @(src,evt) showdata(src, evt);   % sends the raw capture data onto another function
start(dq, "Duration",(AQDuration));

function licks = showdata(src, ~)
    
    data = read(src,src.ScansAvailableFcnCount, "OutputFormat","Matrix");
    licks = data(:,2);
    disp(licks);
    
end