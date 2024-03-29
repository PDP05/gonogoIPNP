% Define parameters

% Timings
% ITI (Inter Trial Interval)
min_ITI_duration = 5;       % Minimum ITI duration in seconds
max_ITI_duration = 10;      % Maximum ITI duration in seconds

% NLP (No Lick Period)
min_NLP_duration = 5;       % Minimum NLP duration in seconds
max_NLP_duration = 10;      % Maximum NLP duration in seconds

% FRW (Fixed Response Window)
FRW_duration = 4;           % Maximum FRW duration in seconds

% TO (Time Out)
min_TO_duration = 6;        % Minimum ITI duration in seconds
max_TO_duration = 10;       % Maximum ITI duration in seconds

% Probabilities
go_probability = 0.3;       % Probability of go trial
nogo_probability = 0.3;     % Probability of no-go trial
catch_probability = 0.4;    % Probability of catch trial

% Thresholds
lick_threshold = 2;         % Threshold for detecting licks during go and catch
nogo_threshold = 5;         % lick input threshold during no go task

% Switches
NLP_lick = false;           % Switch value that sets if a lick was detected during NLP.
puff = false;               % Switch value to control if the mice should be punised with an airpuff (true) or by increasing the ITI (false).
increase_ITI = false;       % switch value to increase the ITI
shorten_ITI = false;        % switch value to shorten the ITI
catchCS = false;            % Switch value to deliver a CS+ stim (go sound) during a catch trial.
proto3 = false;             % Switch value to reward the mice if they lick less than nogo_threshold, opposed to rewarding them if they lick once or not at all during no go.

% Misc
prev_ITI = 0;               % stores previous ITI's value.

% Sounds (Note: make sure these sounds are PCM mono:
% (ffmpeg -i sound.wav -ac 1 sound_mono.wav)

go_sound = "go.wav";        % sets the filename for the go sound.
nogo_sound = "nogo.wav";    % sets the filename for the nogo sound.

% Trial Number
num_trials = 10;            % Number of trials to run
NLP_trial_count = 0;            % counter variable for trial interuppted by licking enough during the NLP.
trial_count = 0;                % counter to log trials without any NLP interruptions.

% Main loop
for trial = 1:num_trials
    
    disp(['Trial ', num2str(trial)]);
    
    % Generate random ITI duration (increase it if we wish to punish mice
    % with an increased ITI and shortens it if we need) else, just
    % generates a random ITI.

    if increase_ITI

        ITI_duration = randi([min_ITI_duration, max_ITI_duration]) + TO_duration;

        if ITI_duration <= prev_ITI % generates new ITIs until a new longer one is generated.
            while ITI_duration <= prev_ITI
                        ITI_duration = randi([min_ITI_duration, max_ITI_duration]) + TO_duration;
                        disp('ITI not long enough, new ITI: ',num2str(ITI_duration));
            end
        end

        increase_ITI = false;

    elseif shorten_ITI

        ITI_duration = randi([min_ITI_duration, max_ITI_duration]) - TO_duration;

        if ITI_duration >= prev_ITI % generates new ITIs until a new shorter one is generated.
            while ITI_duration >= prev_ITI
                ITI_duration = randi([min_ITI_duration, max_ITI_duration]) - TO_duration;
                disp('ITI not short enough, new ITI: ',num2str(ITI_duration));

            end
        end
        shorten_ITI = false; 

    else
        ITI_duration = randi([min_ITI_duration, max_ITI_duration]);
    end
    
    % displays the current ITI
    disp(['Random ITI duration: ', num2str(ITI_duration), ' seconds']);
    prev_ITI = ITI_duration;

    % Generates a random NLP
    NLP_duration = randi([min_NLP_duration, max_NLP_duration]);
    disp(['Random NLP duration: ', num2str(ITI_duration), ' seconds']);

    % Generates a random TO
    TO_duration = randi([min_TO_duration, max_TO_duration]);
    disp(['Random TO duration: ', num2str(ITI_duration), ' seconds']);

    % Wait for ITI
    disp('Waiting for ITI...');
    pause(ITI_duration);
    
    % Shines the LED and launches lick acquisition until the program exits
    disp('Shining LED...'); % TODO: implement code to shine the LED
    % countLicks(SamplingRate, lick_threshold); % starts counting licks in the background

    %% Wait for NLP while checking for inputs

    % Scans for licks during NLP. If a enough licks are detected, sets
    % NLP_lick to true, going back to waiting for ITI. (This skips the
    % current trial).
    % Counts the trials where the mice licked during NLP as NLP_trial_count

    disp('Waiting for NP...');
    start_NLP = tic; % starts timer
    while toc(start_NLP) < NLP_duration

        % Check for inputs
        inputs = read(s, s.NumberOfScansAvailable, 'OutputFormat', 'Matrix'); % TODO, fix this using external function
        if max(inputs) > lick_threshold
            disp("lick detected during NP, waiting ITI again!")
            NLP_lick = true;
            NLP_trial_count = NLP_trial_count + 1;
            break;
        end
    end

    if NLP_lick
        NLP_lick = false;
        continue;   % skips the rest of the trials and goes back to waiting for ITI.
    end
    
    %% Launch trial based on chance per type
    trial_type = rand;
    
    trial_count = trial_count + 1;

    
    switch true

    case trial_type <= go_probability + nogo_probability || ~guaranteed_go
        %% NO GO TRIAL
        
        disp('No-go trial');
        % Plays nogo sound
        niSound(nogo_sound);

        start_nogoTrial = tic;
        
        while toc(start_nogoTrial) < FRW_duration
            
            % if mice lick more than a certain amount during no go, they're
            % punished, either with an aifpuff if puff == true or with a
            % longer ITI puff == false
            switch true
                case max(inputs) > nogo_threshold
                    % FA Conditions
                    disp("FALSE ALARM");
            
                    switch puff
                        case true
                            deliverPuff(); % TODO: adapt the actual function to our valves

                        case false
                            % Will increase the next trial's ITI.
                            increase_ITI = true;
                    end
            
                case max(inputs) < nogo_threshold && proto3

                    % Correct Rejection
                    disp("Correct Rejection");
                    shorten_ITI = true;
                    guarantee_go = true;
            
                otherwise
                    
                    % Correct Rejection
                    disp("Correct Rejection");
                    shorten_ITI = true;
            end

        end
    
    %% GO TRIAL
    case trial_type <= go_probability || guarantee_go

        % Run go trial
        disp('Go trial');

        % Plays go sound
        niSound(go_sound);

        start_goTrial = tic;

        while toc(start_goTrial) < FRW_duration
            
            % MISS conditions
            if  max(inputs) < lick_threshold
                disp("MISS");
            
            else
                disp("HIT");
                deliverWater(); % TODO, adapt the actual function to our valves
            end
            
            % resets guaranteed go trial
            guarantee_go = false;

        end

    otherwise
        %% Catch Trial
        % Run catch trial
        disp('Catch trial');

        if catchCS
            niSound(go_sound);
        end

        start_catchTrial = tic;
        
        while toc(start_catchTrial) < FRW_duration
        
            if max(inputs) < lick_threshold
                disp("CORRECT WITHHOLDING")
            else
                disp("SPONTENEOUS ANSWER")

            end
        end
    end
end