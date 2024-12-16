
function preprocess_data(basedir)
% PREPROCESS_DATA This function preprocesses EEG and audio data as described in the paper: 
% Stimulus-aware spatial filtering for single-trial neural response and temporal 
% response function estimation in high-density EEG with applications in auditory research
% N Das, J Vanthornhout, T Francart, A Bertrand - bioRxiv, 2019
% In addition to preprocessing, the audio envelopes are truncated and
% matched with the corresponding EEG data
% Dependency: AMToolbox
% Input: basedir: the directory in which all the subject and stimuli data
% are saved. (Default: current folder)
% Author: Neetha Das
% KULeuven, July 2019
% As part of the work: Das, N., Vanthornhout, J., Francart, T., & Bertrand, A. (2019), 
% 'Stimulus-aware spatial filtering for single-trial neural response and temporal response 
% function estimation in high-density EEG with applications in auditory research'. bioRxiv, 
% 541318; doi: https://doi.org/10.1101/541318.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 0
    basedir = pwd;
end

stimulusdir = [basedir filesep 'stimuli'];
envelopedir = [stimulusdir filesep 'envelopes'];

if ~exist(envelopedir,'dir')
    mkdir(envelopedir);
end

% Set parameters
params.intermediatefs_audio = 8000; %Hz
params.envelopemethod = 'powerlaw';
params.subbandenvelopes = true;
params.subbandtag = ' subbands'; %if broadband, set to empty string: '';
params.spacing = 1.5;
params.freqs = erbspacebw(150,4000,params.spacing); % gammatone filter centerfrequencies
params.betamul = params.spacing*ones(size(params.freqs)); % multiplier for gammatone filter bandwidths
params.power = 0.6; % Powerlaw envelopes
params.intermediateSampleRate = 128; %Hz
params.lowpass = 50; % Hz, used for constructing a bpfilter used for both the audio and the eeg
params.highpass = 1; % Hz
params.targetSampleRate = 128; % Hz
params.rereference = 'Cz';

% Build the bandpass filter
bpFilter = construct_bpfilter(params);
g = gammatonefir(params.freqs,params.intermediatefs_audio,[],params.betamul,'real'); % create real, FIR gammatone filters.% from amtoolbox>joergensen2011.m

%% Preprocess the audio files
stimulinames = list_stimuli();
nOfStimuli = length(stimulinames);
if 1
for i = 1:nOfStimuli
    % Load a stimulus
    [~,stimuliname,stimuliext] = fileparts(stimulinames{i});
    [audio,Fs] = audioread([stimulusdir filesep stimuliname stimuliext]);
    
    % resample to 8kHz 
    audio = resample(audio,params.intermediatefs_audio,Fs); 
    Fs = params.intermediatefs_audio;
    
    % Compute envelope
    if params.subbandenvelopes
        audio = real(ufilterbank(audio,g,1));
        audio = reshape(audio,size(audio,1),[]); 
    end
    
    % apply the powerlaw
    envelope = abs(audio).^params.power;
    
    % Intermediary downsampling of envelope before applying the more strict bpfilters
    envelope = resample(envelope,params.intermediateSampleRate,Fs);
    Fs = params.intermediateSampleRate;
    
    % bandpassilter the envelope
    envelope = filtfilt(bpFilter.numerator,1,envelope);
    
    % Downsample to ultimate frequency
    downsamplefactor = Fs/params.targetSampleRate;
    if round(downsamplefactor)~= downsamplefactor, error('Downsamplefactor is not integer'); end
    envelope = downsample(envelope,downsamplefactor);
    Fs = params.targetSampleRate;
    
    subband_weights = ones(1,size(envelope,2));
    % store as .mat files
    save([envelopedir filesep params.envelopemethod params.subbandtag ' ' stimuliname],'envelope','Fs','subband_weights');
    
end
end

%% Preprocess EEG and put EEG and corresponding stimulus envelopes together

preprocdir = [basedir filesep 'preprocessed_data'];
if ~exist(preprocdir,'dir')
    mkdir(preprocdir)
end
subjects = dir([basedir filesep 'S*.mat']);
subjects = sort({subjects(:).name});
postfix = '_dry.mat';


for subject = subjects
    load(fullfile(basedir,subject{1}))
    preproc_trials = {};
    for trialnum = 1: size(trials,2) %#ok<USENS>
        
        trial = trials{trialnum};
        
        % Rereference the EEG data if necessary
        if strcmpi(params.rereference,'Cz')
            trial.RawData.EegData = trial.RawData.EegData - repmat(trial.RawData.EegData(:,48),[1,64]);
        elseif strcmpi(params.rereference,'mean')
            trial.RawData.EegData = trial.RawData.EegData - repmat(mean(trial.RawData.EegData,2),[1,64]);
        end
        
        % Apply the bandpass filter
        trial.RawData.EegData = filtfilt(bpFilter.numerator,1,double(trial.RawData.EegData));
        trial.RawData.HighPass = params.highpass;
        trial.RawData.LowPass = params.lowpass;
        trial.RawData.bpFilter = bpFilter;
        
        % downsample EEG (using downsample so no filtering appears).
        downsamplefactor = trial.FileHeader.SampleRate/params.targetSampleRate;
        if round(downsamplefactor)~= downsamplefactor, error('Downsamplefactor is not integer'); end
        trial.RawData.EegData = downsample(trial.RawData.EegData,downsamplefactor);
        trial.FileHeader.SampleRate = params.targetSampleRate;
        
        % Load the correct stimuli, truncate to the length of EEG
        if trial.repetition,stimname_len = 16; else stimname_len = 12;end % rep_partX_trackX or partX_trackX
        
        %LEFT ear
        load([envelopedir filesep params.envelopemethod params.subbandtag ' ' trial.stimuli{1}(1:stimname_len) postfix ]);
        left = envelope(1:length(trial.RawData.EegData),:);
        
        %RIGHT ear
        load( [envelopedir filesep params.envelopemethod params.subbandtag ' ' trial.stimuli{2}(1:stimname_len) postfix ]);
        right = envelope(1:length(trial.RawData.EegData),:);
        
        trial.Envelope.AudioData = cat(3,left, right);
        trial.Envelope.subband_weights = subband_weights;
        
        preproc_trials{trialnum} = trial;
    end
    save(fullfile(preprocdir,subject{1}),'preproc_trials')
end

end

function [ stimulinames ] = list_stimuli()
%List of stimuli names

stimulinames = {};

for experiment = [1 3]
    for track = 1:2
        if experiment == 1 % experiment 3 uses the same stimuli, but the attention of the listener is switched
            no_parts = 4;
            rep = false;
        elseif experiment ==3
            no_parts = 4;
            rep = true;
        end
        
        for part = 1:no_parts
            stimulinames =[stimulinames; {gen_stimuli_names(part,track,rep)}];
        end
    end
end
end

function [ filename ] = gen_stimuli_names(part,track,rep)
%Generates filename for audio stimuli

assert(islogical(rep));
assert(isnumeric(part));
assert(any(track == [1 2]));


part_tag = ['part' num2str(part)];
track_tag = ['track' num2str(track)];

cond_tag = 'dry';
extension = '.wav';

if rep == true
    rep_tag = 'rep';
elseif rep == false
    rep_tag = '';
end

separator = '_';
filename = [rep_tag separator part_tag separator track_tag separator cond_tag extension];
filename = regexprep(filename,[separator '+'],separator); %remove multiple underscores
filename = regexprep(filename,['^' separator],''); %remove starting underscore

end

function [ BP_equirip ] = construct_bpfilter( params )

Fs = params.intermediateSampleRate;
Fst1 = params.highpass-0.45;
Fp1 = params.highpass+0.45;
Fp2 = params.lowpass-0.45;
Fst2 = params.lowpass+0.45;
Ast1 = 20; %attenuation in dB
Ap = 0.5;
Ast2 = 15;
BP = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,Fs);
BP_equirip = design(BP,'equiripple');

end




