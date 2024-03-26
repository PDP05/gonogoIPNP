% Load audio file
[audioData, Fs] = audioread('your_audio_file.wav');

% Create NI-DAQmx session
s = daq.createSession('ni');

% Add an analog output channel
addAnalogOutputChannel(s, 'Dev1', 'ao0', 'Voltage');

% Set the sampling rate to match the audio file
s.Rate = Fs;

% Queue the audio data for output
queueOutputData(s, audioData);

% Start the session to play the audio
startForeground(s);
