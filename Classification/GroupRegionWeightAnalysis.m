%  Quantify the proportion of features that were more 
% important by region

clear all;
clc;
load('/Users/alexg8/Documents/ECOG/Results/Classification/group/power/IPS-SPL/allSubjsClassXVBstimLock0msTo1000mspowerhgam_tFtrial_tTBin_gTIPS-SPL_SolverliblinearS0.mat')

nSubjs = numel(unique(S.subjChans));

nChansPerROIPerSubj = zeros(nSubjs,2);
FeauturesROI_ID  = cell(nSubjs,1);
FeaturesBySubjROI      = cell(nSubjs,2);
nTimeFeatures = 10; % for stim-lock
% number of IPS/SPL channels per subject.
TValOfFeaturesBySubjROI = zeros(nSubjs,1);
for ss = 1:nSubjs
    for rr = 1:2 % nROIs IPS/SPL
        nChansPerROIPerSubj(ss,rr) = sum(S.subjChans==ss & S.ROIid==rr); 
    end
    FeauturesROI_ID{ss} = 2*ones(size((S.model{ss})));
    FeauturesROI_ID{ss}(1:nChansPerROIPerSubj(ss,1)*nTimeFeatures)=1;    
     X=abs(zscore(S.model{ss}));
    FeaturesBySubjROI{ss,1} =X(FeauturesROI_ID{ss}==1);
    FeaturesBySubjROI{ss,2} = X(FeauturesROI_ID{ss}==2);
    
    [~,~,~,t] = ttest2(FeaturesBySubjROI{ss,1},FeaturesBySubjROI{ss,2});
    TValOfFeaturesBySubjROI(ss) = t.tstat;
end


FeauturesByROIstim = cell(2,1);
for ss = 1:5
    FeauturesByROIstim{1} = [FeauturesByROIstim{1}; FeaturesBySubjROI{ss,1}'];
    FeauturesByROIstim{2} = [FeauturesByROIstim{2}; FeaturesBySubjROI{ss,2}'];
end
[~,p,~,t]=ttest2(FeauturesByROIstim{1},FeauturesByROIstim{2})
%%
load('/Users/alexg8/Documents/ECOG/Results/Classification/group/power/IPS-SPL/allSubjsClassXVBRTLockn800msTo200mspowerhgam_tFtrial_tTBin_gTIPS-SPL_SolverliblinearS0.mat')
nSubjs = numel(unique(S.subjChans));

nChansPerROIPerSubj = zeros(nSubjs,2);
FeauturesROI_ID  = cell(nSubjs,1);
FeaturesBySubjROI      = cell(nSubjs,2);
nTimeFeatures = 10; % for stim-lock
% number of IPS/SPL channels per subject.
TValOfFeaturesBySubjROI = zeros(nSubjs,1);
for ss = 1:nSubjs
    for rr = 1:2 % nROIs IPS/SPL
        nChansPerROIPerSubj(ss,rr) = sum(S.subjChans==ss & S.ROIid==rr); 
    end
    FeauturesROI_ID{ss} = 2*ones(size((S.model{ss})));
    FeauturesROI_ID{ss}(1:nChansPerROIPerSubj(ss,1)*nTimeFeatures)=1;    
    
    X=abs(zscore(S.model{ss}));
    FeaturesBySubjROI{ss,1} = X(FeauturesROI_ID{ss}==1);
    FeaturesBySubjROI{ss,2} = X(FeauturesROI_ID{ss}==2);
    
    [~,~,~,t] = ttest2(FeaturesBySubjROI{ss,1},FeaturesBySubjROI{ss,2});
    TValOfFeaturesBySubjROI(ss) = t.tstat;
end


FeauturesByROIRT = cell(2,1);
for ss = 1:5
    FeauturesByROIRT{1} = [FeauturesByROIRT{1}; FeaturesBySubjROI{ss,1}'];
    FeauturesByROIRT{2} = [FeauturesByROIRT{2}; FeaturesBySubjROI{ss,2}'];
end
[~,p,~,t]=ttest2(FeauturesByROIRT{1},FeauturesByROIRT{2})