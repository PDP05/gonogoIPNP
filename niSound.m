function nisound(filename)

% adds the NI card
d = daq('ni');

% add analog output channel
addoutput(d, 'Dev1', 'ao0', 'Voltage');

% gets the audio data and samplerate from the file
data = audioread(filename);

% normalises the data (so it doesn't go over what the NI card can send)
data = data / max(abs(data));

% sends the data to the card
write(d, data);

% starts playback
read(d);
 
end