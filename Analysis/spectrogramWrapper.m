function dataStruct=spectrogramWrapper(dataStruct)

opts = []; 
opts.fs = dataStruct.SR;
opts.freqs=  unique(round(logspace(0,log10(180),50)));
opts.windowSize = round(dataStruct.SR); % one second
opts.overlap 	= round(0.98*opts.windowSize);


X = dataStruct.signal;
nSamps  = size(X,2); % total amount of time
origTime = linspace(0,nSamps/dataStruct.SR,nSamps);
dataStruct.signal  = [];

% get spectrogram for every channel;
[dataStruct.Power,dataStruct.Freqs,dataStruct.Time] = STFT_spectrogram(X,opts);

% get new samples for events
[TimeMarkers,Samps,Errors] = matchSampsToTime(origTime(dataStruct.trialOnsets),dataStruct.Time);
dataStruct.TimeMarkers 	= TimeMarkers;
dataStruct.EventSamps 	= Samps;
dataStruct.EventSampsErr= Errors;
dataStruct.spectrogramOpts = opts;

