

function out = clusterWrapper(data, opts)
% wrapper function for clustering channel data

chans = ismember(data.ROIid,opts.ROIs) & ismember(data.hemChanId,opts.hemNum);

% get data
dtype   = opts.dtype;
X       =   data.(dtype)(chans,:);

% smooth data
if opts.smoothData
    filtOrd     = 5;
    movAvg      = 1/filtOrd*ones(1,filtOrd);
    X           = applyFilter(movAvg,X);
end

% settings for clustering:
opts.method     = 'kmeans';
opts.nClusters  = numel(opts.ROIs);
opts.nReplicates= 100;

% cluster
out = clusterChannels(X,opts);
CM  = confusionmat(out.index,data.ROIid(chans));

if CM(1,1)+CM(2,2) <= CM(1,2)+CM(2,1);
    temp = out.index;
    out.index(temp==1) = 2;
    out.index(temp==2) = 1;    
    out.D = [out.D(:,2) out.D(:,1)];
end
out.CM  = confusionmat(out.index,data.ROIid(chans));

% change coordinates of the distances to clusters to unity line
DC      = out.D;
nCl     = size(DC,2); % number of clusters
nV      = 1/sqrt(nCl)*ones(1,nCl);
nDC     = 1-DC/max(DC(:)); out.nDC = nDC;
out.CDB     = nDC-(nDC*nV')*nV; %cluster desicion boundary

% plotting clusters
[f1 f2] = plotClusters(data,out.nDC,out.CDB,chans);

savePath        = opts.plotPath;
extStr          = data.extension;
if strcmp(opts.type,'erp'),
    plotPath = [savePath 'group/Clusters/'];
elseif strcmp(opts.type,'ITC')
    plotPath = [savePath 'group/ITC/' opts.band '/Clusters/'];
elseif strcmp(opts.type,'power')
    plotPath = [savePath 'group/' opts.band '/Clusters/'];
end

if ~exist(plotPath,'dir'),mkdir(plotPath),end
filename = [plotPath '/' opts.hems dtype  'ClustererdChans' extStr];
print(f1,'-dtiff','-loose','-opengl','-r400',filename);
%plot2svg([filename '.svg'],f1,'tiff')

filename = [plotPath '/' opts.hems dtype  'RendClustererdChans' extStr];
print(f2,'-dtiff','-loose','-opengl',['-r' num2str(opts.resolution)],filename);

end