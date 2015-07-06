function plotFigure3_v3(data1,data2,data3,data4,data5,data6,opts)
% dependencies
%   scatterPlotWithErrors.m
inkscapePath='/Applications/Inkscape.app/Contents/Resources/bin/inkscape';

fontSizeLabels  = 14;
subjectDots = 12;
scatterDots = 35;
WyTicks      = [0 0.1];
legendMarkerSize = 10;
labelLetterSize = 24;

% figure margins
lMargin = 0.08;
tMargin = 0.08;
bMargin = 0.15;
rMargin = 0.08;

betweenBarScatterSpace = 0.01;
betweenScatROIscatSpace = 0.15;
betweenBarTC_Space = 0.1;
betweenTCsSpace = 0.03;

% figure dimensions
figW = 800;
figH = 480;

% scatter plot dimension
scatterW = 0.30;
scatterH = 0.22;%scatterW*figW/(figH);

% bar plot dimensions
hBarH      = 0.08;
hBarW    = scatterW;
vBarW    = hBarH;     
vBarH = scatterH;

% scatter plot coordinates
scatterXpos = lMargin+vBarW+betweenBarScatterSpace;
scatterYpos = 1-scatterH-tMargin;

% vertical barplot Coords
vBarXpos = lMargin;
vBarYpos = scatterYpos;

% horizontal barplot Coords
hBarXpos = scatterXpos;
hBarYpos  = scatterYpos-betweenBarScatterSpace-hBarH;

% dimension for weight time courses
weTCh      = 1-hBarYpos-betweenBarTC_Space;
weTCw      = 0.40;

% weight TC coordinates
weTC1xPos = lMargin;
weTC1yPos   = bMargin;

weTC2xPos   = lMargin+weTCw+betweenTCsSpace;
weTC2yPos   = weTC1yPos;

% roi classification positions
roiScatxPos     = scatterXpos+scatterW +betweenScatROIscatSpace;
roiScatyPos     = scatterYpos-hBarH;
roiScatW         = 1-(roiScatxPos+rMargin);
roiScatH         = scatterH+hBarH;

% overall positions
scatterPos  = [scatterXpos scatterYpos scatterW scatterH];
vBarPos     = [vBarXpos vBarYpos vBarW vBarH];
hBarPos     = [hBarXpos hBarYpos hBarW hBarH];
roiScatPos  = [roiScatxPos roiScatyPos roiScatW roiScatH];

weTC1Pos    = [weTC1xPos weTC1yPos weTCw weTCh];
weTC2Pos    = [weTC2xPos weTC2yPos weTCw weTCh];

% additinonal settings
colors      = [];
colors{1}  = [0.9 0.2 0.2];
colors{2}  = [0.1 0.5 0.8];

ScatterRTTicks = [0.5:0.2:0.9];
ScatterStimTicks = [0.5:0.1:0.9];
nBoot1 = data1.classificationParams.nBoots;
nBoot2 = data2.classificationParams.nBoots;

%% channel selection
Subjchans   = ismember(data1.subjChans,opts.subjects);
chans       = double(ismember(data1.ROIid.*Subjchans,opts.ROIs));

stimLims = opts.ylims;
RTLims = opts.xlims;

N = sum(chans);
nROIs = numel(opts.ROIs);
nChanPerROI =[];
if opts.ROIids
    cols = zeros(N,3);
    cnt = 1;
    for rr = opts.ROIs
        
        roiChans = chans & (data1.ROIid==rr); n = sum(roiChans);
        nChanPerROI = [nChanPerROI sum(roiChans)];
        chans(cnt:(n+cnt-1)) = find(roiChans);
        cols(cnt:(n+cnt-1),:)= repmat(colors{rr},n,1);
        
        cnt = cnt + n;
    end
    chans = chans(1:N);
else
    cols = repmat(colors{4},[N,1]);
end

% get channel means and standard errors
% stim
M1 =[];
M1(:,1) = data1.mBAC(chans);
M1(:,2) = data1.sdBAC(chans)/sqrt(nBoot1-1);

% RT
M2 =[];
M2(:,1) = data2.mBAC(chans);
M2(:,2) = data2.sdBAC(chans)/sqrt(nBoot2-1);

%% scatter plot and bar graphs of accuracy
if 1
    % plot M1 vs M2
    f = figure(1); clf;
    set(gcf,'position',[-800 200,figW,figH],'PaperPositionMode','auto','color','w')
    
    % scatter Plot axes
    ha(1) = axes('position',scatterPos);
    % horizontal Bar Plot axes
    ha(2) = axes('position',hBarPos);
    % vertical Bar Plot axes
    ha(3) = axes('position',vBarPos);
    
    % panel ID
    axes('position', [0.0 0.95 0.1 0.05]); xlim([0 1]); ylim([0 1])
    text(0.01,0.45,' a ','fontsize',labelLetterSize)
    set(gca,'visible','off')
    
    % axes labels
    axes('position',[hBarXpos,hBarYpos-betweenBarTC_Space,hBarW,betweenBarTC_Space])
    text(0.5,0.4,'RL Acc','fontsize',fontSizeLabels,...
        'VerticalAlignment','middle','horizontalAlignment','center')
    axis off
    
    axes('position',[0,vBarYpos,lMargin/2,vBarH])
    text(0.5,0.5,'SL Acc','fontsize',fontSizeLabels,'rotation',90, ...
        'VerticalAlignment','middle','horizontalAlignment','center')
    axis off
    
    % scatter plot
    axes(ha(1)); hold on;
    scatterPlotWithErrors(M2,M1,scatterDots, cols, [RTLims; stimLims], [0.5 0.5 1]);
    set(gca,'yTick',ScatterStimTicks,'xTick',ScatterRTTicks)
    set(gca,'yTicklabel','','xTicklabel','')
    
    % hortizontal bar plot. RT
    axes(ha(2)); hold on;    
    cnt = 1;
    for r = 1:nROIs
        roiChans = cnt:nChanPerROI(r)+cnt-1;
        
        ym = mean([M2(roiChans,1)]);
        ys = std([M2(roiChans,1)])/sqrt(nChanPerROI(r)-1);
        
        barh(r,ym,'FaceColor',colors{r},'edgeColor','none','basevalue', 0.5,'ShowBaseLine','off')
        plot([-ys ys]+ym,[r r],'color',[0 0 0],'linewidth',3)
        
        cnt = cnt + nChanPerROI(r);
    end
    xlim(RTLims);ylim([0.5 2.5])
    plot([0.5 0.5],ylim,'--','color',0.3*ones(3,1),'linewidth',2)
    set(gca,'LineWidth',2,'FontSize',fontSizeLabels, 'fontWeight','normal')
    set(gca,'xtick',ScatterRTTicks,'xtickLabel',ScatterRTTicks,'ytick',[])
    set(gca,'box','off')
    
    % vertical bar plot, stim
    axes(ha(3)); hold on;
    xlim([0 nROIs]+0.5); ylim(stimLims)
    
    cnt = 1;
    for r = 1:nROIs
        roiChans = cnt:nChanPerROI(r)+cnt-1;
        
        ym = mean([M1(roiChans,1)]);
        ys = std([M1(roiChans,1)])/sqrt(nChanPerROI(r)-1);
        
        bar(r,ym,'FaceColor',colors{r},'edgeColor','none','basevalue', 0.5,'ShowBaseLine','off')
        plot([r r],[-ys ys]+ym,'color',[0 0 0],'linewidth',3)
        
        cnt = cnt + nChanPerROI(r);
    end
    plot(xlim,[0.5 0.5],'--','color',0.3*ones(3,1),'linewidth',2)
    set(gca,'LineWidth',2,'FontSize',fontSizeLabels,'fontWeight','normal')
    set(gca,'ytick',ScatterStimTicks,'ytickLabel',ScatterStimTicks,'xtick',[])
    
    % legend IPS/SPL
    axes('position',[vBarXpos hBarYpos vBarW hBarH]); hold on;
    plot([0.3],[0.5],'o','color',colors{1},'markersize',legendMarkerSize,'markerfacecolor',colors{1})
    plot([0.3],[2],'o','color',colors{2},'markersize',legendMarkerSize,'markerfacecolor',colors{2})
    
    xlim([0 1]); ylim([0 3])
    text(0.5,0.5,'IPS','fontsize',fontSizeLabels)
    text(0.5,2,'SPL','fontsize',fontSizeLabels)
    set(gca,'visible','off')
    
    %  plots for ROI level  
    % panel ID
    axes('position', [roiScatxPos-0.08 0.95 0.05 0.05])
    text(0.05,0.45,' c ','fontsize',labelLetterSize)
    set(gca,'visible','off')
            
    % ylabel axes
    axes('position',[roiScatxPos-0.06 roiScatyPos 0.05 roiScatH])
    text(0.05,0.5,' Acc','fontsize',fontSizeLabels,'rotation',90, ...
        'VerticalAlignment','middle','horizontalAlignment','center')
    axis off
    
    axes('position',roiScatPos)
    plot([0 3],[0.5 0.5], '--', 'color', 0.3*ones(3,1), 'linewidth',2);hold on;
    xlim([0.5 2.5]); ylim(RTLims);
    set(gca,'linewidth',2, 'fontsize', fontSizeLabels, 'box','off')
    set(gca,'xtick',[1 2], 'xtickLabel', {'stim', 'resp'})
    set(gca,'ytick',ScatterRTTicks,'ytickLabel',ScatterRTTicks)
    
    subSymbols = {'o','d','s','p','h'};
    
    n       = size(data3.perf(opts.subjects,opts.ROIs,:,:),4);
    RTsMACC  = mean(data4.perf(opts.subjects,opts.ROIs,:,:),4);
    RTsSEACC = std(data4.perf(opts.subjects,opts.ROIs,:,:),0,4)/sqrt(n-1);
    StimMACC = mean(data3.perf(opts.subjects,opts.ROIs,:,:),4);
    StimSEACC = std(data3.perf(opts.subjects,opts.ROIs,:,:),0,4)/sqrt(n-1);
    
    for rr = 1:2
        M =  [];
        M(:,1) = StimMACC(:,rr);
        M(:,2) = RTsMACC(:,rr);
        S = [];
        S(:,1) = StimSEACC(:,rr);
        S(:,2) = RTsSEACC(:,rr);
        
        for ss =1:5
            xpS1 = 1+0.05*randn;
            xpS2 = 2+0.05*randn;
            
            plot([xpS1 xpS1], M(ss,1)+[-S(ss,1) S(ss,1)],'color',0.3*ones(3,1),'linewidth',1)
            plot([xpS2 xpS2], M(ss,2)+[-S(ss,2) S(ss,2)],'color',0.3*ones(3,1),'linewidth',1)
            plot([xpS1 xpS2],M(ss,:),['-' subSymbols{ss}],'color', colors{rr},'markersize',subjectDots,'markerfacecolor',colors{rr})
            
        end
    end
    
    % subject legend
    axes('position', [roiScatxPos, roiScatyPos-hBarH*1.8-betweenBarScatterSpace, roiScatW, hBarH*1.5]); hold on;
    for ss=1:5
        plot(0.16*(ss-0.5),0.5,subSymbols{ss},'color',0.3*ones(3,1),'markersize',subjectDots,'markerfacecolor',0.3*ones(3,1))
        text(0.16*(ss-0.5),0,['S' num2str(ss)],'fontsize',fontSizeLabels-1,'VerticalAlignment','top','horizontalAlignment','center')
    end
    axis off    
    
    % bottom panel
    t{1} = 0.05:0.1:1;
    t{2} = -0.75:0.1:0.2;
    % second version, including only channels with significant decodign
    % accuracy
    X{1} = squeeze(data1.chModel);
    X{2} = squeeze(data2.chModel);
    
    Y{1} = data1.mBAC;
    Y{2} = data2.mBAC;
    
    perfThr = 0;
    
    yLimits = [-0.1 0.15];
    sigBar      = cell(2,1);
    sigBar{1}   = 0.95*yLimits(2)*ones(1,2);
    sigBar{2}   = 0.97*yLimits(2)*ones(1,2);
    
    pThr = 0.005;
    timeTicks   = [0:0.2:1; -0.8:0.2:0.2];        
    
    ha(5)=axes('position',weTC1Pos);
    ha(6)=axes('position',weTC2Pos);   
    
    yRefLims    = [yLimits(1)*0.3 yLimits(2)*0.3];
    
    chIdx{1}   = (data1.ROIid==1) & (data1.hemChanId==1) & (Y{1} >= perfThr) & (Y{2} >= perfThr);
    chIdx{2}   = (data1.ROIid==2) & (data1.hemChanId==1) & (Y{1} >= perfThr) & (Y{2} >= perfThr);
    
    axIDs = [5 6];
    for col = 1:2
        axes(ha(axIDs(col))); cla;
        
        x = cell(2,1);
        x{1} = X{col}(chIdx{1},:);
        x{2} = X{col}(chIdx{2},:);
        
        % plot traces
        hh=plotNTraces(x,t{col},'rb','none',[],'mean',yLimits); hold on;
        yy=get(gca,'children');
        set(yy(9),'YData',[yRefLims],'color',0.3*ones(3,1))
        set(yy(10),'color',0.3*ones(3,1))
        
        % plot sig bar IPS
        h = ttest(x{1},0,pThr);
        sigBins = t{col}(h==1);
        for ii = 1:numel(sigBins)
            plot([-0.05 0.05]+sigBins(ii),sigBar{1},'linewidth',2,'color',colors{1})
            plot(sigBins(ii),sigBar{1}(1),'*','linewidth',2,'color',colors{1})
        end
        
        % plot sig bar SPL
        h = ttest(x{2},0,pThr);
        sigBins = t{col}(h==1);
        for ii = 1:numel(sigBins)
            plot([-0.05 0.05]+sigBins(ii),sigBar{2},'linewidth',2,'color',colors{2})
            plot(sigBins(ii),sigBar{2}(1),'*','linewidth',2,'color',colors{2})
        end
        
        
        set(gca,'fontsize',fontSizeLabels,'fontWeight','normal')
        set(gca,'ytick',WyTicks)
        set(gca,'yticklabel',WyTicks)
        set(gca,'xtick', timeTicks(col,:))
        
        if (col==1)
            %             xx=legend([hh.h1.mainLine,hh.h2.mainLine],'IPS','SPL');
            %             set(xx,'box','off','location','northwest')
            set(gca,'XtickLabel',{'stim','','0.4','','0.8',''})
            xlim([-0.1 1.02])
            set(yy(10),'Xdata',[-0.1 1.02])
        end
        
        if (col==2)
            set(gca,'YAXisLocation','right')
            set(gca,'XtickLabel',{'-0.8','','-0.4','','resp',''})
            xlim([-0.9 0.22])
            set(yy(10),'Xdata',[-0.9 0.22])
        end
        
    end
    
    axes('position', [0 bMargin lMargin/2 weTCh])
    text(0.5,0.5,' Weights (au) ','fontsize',fontSizeLabels,'rotation',90, ...
        'VerticalAlignment','middle','horizontalAlignment','center')
    set(gca,'visible','off')
    
    axes('position', [0 weTC1yPos+weTCh+0.02 0.1 0.05]); xlim([0 1]); ylim([0 1])
    text(0.01,0.45,' b ','fontsize',labelLetterSize)
    set(gca,'visible','off')
    
    axes('position', [0 bMargin-0.08 1 0.06]); xlim([0 1]); ylim([0 1])
    text(0.45,0,' Time (s) ','fontsize',fontSizeLabels)
    set(gca,'visible','off')
    
    %%
    cPath = pwd;
    cd(opts.savePath)
    addpath(cPath)
    addpath([cPath '/Plotting/'])
    
    filename = 'Fig3_HGP_ACC_WeV3';
    plot2svg([filename '.svg'],f)
    eval(['!' inkscapePath ' -z ' filename '.svg --export-pdf=' filename '.pdf'])
    eval(['!rm ' filename '.svg'])
    
    cd(cPath)
end



