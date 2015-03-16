function out = binTrials(X,binSamps)
% out = binTrials(X,binSamps)
% function that returns a trial matrix corresponding to the bins as
% generated by getBinSamps
% 
% X         -> data matrix to be compressed
% binSamps  -> bin and time trial matrix
% a.gonzl june 2013

nTr = size(X,1);
nBins = size(binSamps,1);

out = zeros(nTr,nBins);
parfor tr = 1:nTr
    for bin = 1:nBins
        out(tr,bin) = mean(X(tr,binSamps(bin,:)));
    end
end
