function playSound(app)

    %% sets up paths
    [app.current_path, ~] = fileparts(mfilename('fullpath'));   % launches the app picker and stores it as the current path
    addpath(genpath(app.current_path))  % adds previous paht to PATH
    NICard_fullpath = [app.current_path filesep 'NICard\' app.NICard_filename.Value];   % adds the NIcard init script in PATH
    Sound_Path = app.Sound_filename.Value;  % takes the sound

    %% initializes NI card
    addpath(genpath(app.current_path));
    [~,NICard_script] = fileparts(NICard_fullpath);
    feval(NICard_script)
    disp('NI card Initialized')

    app.user_settings = user_settings;
    datlist={'fsound','frec','TTLstartcam','Speaker','TTLSound',...
            'SoundCopy', 'TTLReward', 'TTLtrig2ph', 'TTLstart2ph',...
            'Lick', 'TTLtrigcamera','TTLtrigsounds','TTLPuff'};

    for n=1:length(datlist)
        switch datlist{n}
            case {'fsound, 'freq'}
                if isfield(user_data, datlist{n})
                    app.(datlist{n}).Value = user_settings.(datlist{n});
                end
            otherwise
                if isfield(user_data, datlist{n})
                    app.([datlist{n} 'CheckBox']).Value = 1;
            else
                 app.([datlist{n} 'CheckBox']).Value = 0;
            end
        end
    end

%% Get the sounds
ExpFile = app.Sound_filename.Value;
[~,~,fExt] = fileparts(ExpFile);

switch fExt
    case '.mat'
        S = load(ExpFile);

    app.Sound_data = S.Sound;
    disp('Sound loaded')

    otherwise
        uialert(app.UIFigure, ['Unexpected file type: ', fExt], 'No sound loaded');
end

dataOutput = app.Sound_data{app.Sound_ID_num.Value} * app.Soundlevel.Value;
DigitalTTL = ones(length(dataOutput),1);

% sends the sound to the relevant SI
preload(app.user_data.sSound,[dataOutput,DigitalTTL]);

start(app.user_data.sSound)
pause(2)
stop(app.user_data.sSound)

end