% This script sets up the NI BNC2090 for experimental setup

daqreset;   % starts on a blank slate

% recording parameters
user_settings.frec = 1000;  % DAQ frequency
user_settings.fsound = 192000;  % sound sampling rate frequency
user_settings.Bin = 0.5;    % bin size in seconds

% Ports IN
user_settings.TTLtrig2ph = 2;       % channel to trigger 2photon microscope
user_settings.TTLtrigcamera = 1;    % channel to trigger camera acquisition (if we want to record the mice during behavior)
user_settings.TTLtrigsounds = 0;    % channel to trigger sounds to play on speakers
user_settings.Lick;                 % lick channel port input (logs the licks)
user_settings.TTLReward = 'Port0/Line6';    % Lick reward valve channel
user_settings.TTLPuff = 'Port0/Line5';      % airpuff channel

% Ports OUT
% TTL
user_settings.TTLstartcam = 'Port0/Line1'; % camera trigger channel
user_settings.TTLstart2ph = 'Port0/Line2'; % 2p trigger

% Analog OUT
user_settings.Amp = 0;  % sends sounds to amplifier
user_settings.TTLSoundOut = 1;  % sends a sound TTL

%% the National Instruments devices itself
user_settings.DeviceName = daqlist().DeviceID(1);   % lists daq devices (useful to not hardcode the device's name)

% Here we segregate our equipment into multiple sub instruments (SIs) for
% different purposes:

%% First SI: acquires data
sRec = daq('ni');   % creates the SI
sRec.Rate = user_settings.frec; % assigns it a recording frequency (freq)

% Channels to record list:
% Two photon
TwoPhotonChannel = addinput(sRec, user_settings.DeviceName, user_settings.TTLtrig2ph,'Voltage');
TwoPhotonChannel.TerminalConfig = 'SingleEnded';

% Sound
TrigSoundChannel = addinput(sRec, user_settings.DeviceName, user_settings.TTLtrigcamera, 'Voltage');
TrigSoundChannel.TerminalConfig = 'SingleEndedNonReferenced';

% lickometer
LickChannel = addinout(sRec, user_settings.DeviceName, user_settings.Lick, 'Voltage');
LickChannel.TerminalConfig = 'SingleEnded';

% launches the recording of all previous ports
sRec.ScansAvailableFcnCount = user_settings.Bin * sRec.Rate;

%% Second SI: syncrhonizes microscope and camera
sSynchro = daq('ni');

% adds ports to control both devices:
% camera
addoutput(sSynchro,user_settings.DeviceName,user_settings.TTLstartcam,'Digital');
% microscope
addoutput(sSynchro,user_settings.DeviceName,user_settings.TTLstart2ph,'Digital');
% launches the syncrhonization
write(sSyncrho,[0,0]);

%% Third SI: play sounds and TTLs
sSound = daq('ni');
sSound.Rate = user_settings.fsound; % sets sound sampling rate

% sets up outputs:
% Sounds
addoutput(sSound, user_settings.DeviceName, user_settings.Speaker, 'Voltage');

%% Fourth SI: send the reward
sReward = daq('ni');
addoutput(sReward,user_settings.DeviceName,user_settings.TTLReward,'Digital');  % reward valve output
addoutput(sReward,user_settings.DeviceName,user_settings.TTLstartcam, 'Digital');

%% Fifth SI: send the airpuff
sPuff = daq('ni');
addouput(sPuff,user_settings.DeviceName,user_settings.TTLPuff,'Digital');   % airpuff valve output

% exports the SIs to be used later
user_settings.sRec = sRec;
user_settings.sSynchro = sSyncrho;
user_settings.sSound = sSound;
user_settings.sReward = sReward;
user_settings.sPuff = sPuff;


