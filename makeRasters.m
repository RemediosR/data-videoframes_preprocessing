function makeRasters()

%Default parameters:
defaultBehaviorValue=1;
defaultColorString='[1,1,1]';
defaultColorFile='savedColors.mat';
minEllipsisLength=3;
minTotalCharLength=22;
filePath='.\';
defaultsFound=true;
oldChangeColorString=defaultColorString;
otherInd=1;
noneSelected=false;
defaultImgFormatInd=4;
curExp=1;
defaultRowNum=4;


%Initialization of multi-function-spanning variables:
[colorFilePath, colorFileFullPath, streamString, filePath]=deal('');
[nBehaviors, otherColor, nSpecialColors, nFiles, framesPerSecond]=deal([]);
[colorList, colorString, behaviorStringBase, behaviorString,...
    ellipsesString, specialColorString, scInds, specialColor,...
    scBehaviors, rawBehaviorString, superRawBehaviors, startPoint,...
    stopPoint, frameRes, nStreams, streamString, fullPath, filePaths,...
    fileNames, fileExts, a]=deal({});
imgExtInd=defaultImgFormatInd;


%Figure parameters:
rasterPixelHeight=30; %Height in pixels of each raster
spacePixelHeight=24; %Height in pixels of spaces separating rasters
rasterFigWidth=600; %Width of figure containing rasters
rasterAxWidth=.9; %Width of rasters as a fraction of figure width
rasterAxWidthStart=(1-rasterAxWidth)/2; %Leftmost point of rasters as a fraction of figure width
legendBarHeight=15;

figWidth=470;
figHeight=400;
screenSize=get(0, 'ScreenSize');
screenWidth=screenSize(1,3);
screenHeight=screenSize(1,4);

widthStart=round(screenWidth-figWidth)/2;
heightStart=round(screenHeight*.8)-figHeight;

pbP = {'Style', 'pushbutton',...
    'Units', 'normalized',...
    'FontUnits', 'normalized',...
    'FontSize', .45};
chP = {'Style', 'checkbox',...
    'Units', 'normalized',...
    'FontUnits', 'normalized',...
    'FontSize', .45};
edP = {'Style', 'edit',...
    'Units', 'normalized',...
    'BackgroundColor', [1, 1, 1],...
    'HorizontalAlignment', 'left',...
    'FontUnits', 'normalized',...
    'FontSize', .5};
txP = {'Style', 'text',...
    'Units', 'normalized',...
    'FontUnits', 'normalized',...
    'FontSize', .5};
txP2 = {'Style', 'text',...
    'Units', 'normalized',...
    'FontUnits', 'normalized',...
    'FontSize', .9};
puP = {'Style', 'popupmenu',...
    'Units', 'normalized',...
    'FontUnits', 'normalized',...
    'FontSize', .5,...
    'BackgroundColor', [1, 1, 1]};
slP = {'Style', 'slider',...
    'Units', 'normalized'};
rbP = {'Style', 'radiobutton',...
    'Units', 'normalized',...
    'FontUnits', 'normalized',...
    'FontSize', .5};
tbP = {'Style', 'togglebutton',...
    'Units', 'normalized',...
    'FontUnits', 'normalized',...
    'FontSize', .45};
lbP = {'Style', 'listbox',...
    'Units', 'normalized'};

eH=20/figHeight;  %=.05 when figure is 400x480 pixels
eW=150/figWidth;
hEW=eW/2;
spH=eH/5;
spW=5/figWidth;
lbH=14*eH-spH;
lbW=2*eW+spW;

imageFormats={'eps', 'ai', 'emf', 'png', 'tif', 'jpg', 'fig', 'bmp',...
    'pdf', 'pbm', 'pcx', 'pgm', 'ppm'};


loadColors();
loadRasterData();
if noneSelected
    return
end


isNotOther= @(x) any(x~=otherColor);


figMain = figure(...
    'MenuBar', 'none',...
    'Name', 'Make Rasters',...
    'NumberTitle', 'off',...
    'Resize', 'on',...
    'Toolbar', 'auto',...
    'Units', 'pixels',...
    'Visible', 'on',...
    'Color',[.7 .7 .7],...
    'Position', [widthStart heightStart figWidth figHeight]);

sH=1-eH;
sW=spW;
pbChangeBehavior=uicontrol('Parent', figMain, pbP{:},...
    'Position', [sW, sH, eW, eH],...
    'String', 'Change behavior to:',...
    'Callback', @callbackChangeBehavior);
sH=sH-eH;
edChangeBehavior=uicontrol('Parent', figMain, edP{:},...
    'String', behaviorStringBase{defaultBehaviorValue},...
    'Position', [sW, sH, eW, eH]);

sH=sH-eH-spH;
txBehaviors=uicontrol('Parent', figMain, txP{:},...
    'Position', [sW, sH, eW, eH],...
    'String', 'Behaviors:',...
    'HorizontalAlignment', 'left');

sH=sH-lbH;
lbBehaviors=uicontrol('Parent', figMain, lbP{:},...
    'Position', [sW, sH, lbW, lbH],...
    'String', behaviorString,...
    'Max', length(behaviorString),...
    'FontName', 'FixedWidth',...
    'Callback', @callbackLbBehaviors);

sH=sH-eH;
puExperiment=uicontrol('Parent', figMain, puP{:},...
    'Position', [sW, sH, lbW, eH],...
    'String', fileNames,...
    'Value', curExp,...
    'Callback', @callbackPuExperiment);

sH=sH-1.5*eH-spH;
pbMakeRaster=uicontrol('Parent', figMain, pbP{:},...
    'Position', [sW, sH, eW, 1.5*eH],...
    'String', 'Make Raster',...
    'Callback', @callbackMakeRaster);

sW=sW+eW+spW;
pbSaveColors=uicontrol('Parent', figMain, pbP{:},...
    'Position', [sW, sH, eW, 1.5*eH],...
    'String', 'Save Colors',...
    'Callback', @saveColors);


sH=1-eH;
pbChangeColor=uicontrol('Parent', figMain, pbP{:},...
    'Position', [sW, sH, eW, eH],...
    'String', 'Change color to:',...
    'Callback', @callbackChangeColor);
sH=sH-eH;
edChangeColor=uicontrol('Parent', figMain, edP{:},...
    'String', defaultColorString,...
    'Position', [sW, sH, hEW, eH],...
    'Callback', @callbackEdChangeColor);

txChangeColorDisp=uicontrol('Parent', figMain, txP{:},...
    'Position', [sW+hEW, sH, hEW, eH],...
    'BackgroundColor', str2num(defaultColorString));

sH=sH-eH-spH;
txColors=uicontrol('Parent', figMain, txP{:},...
    'Position', [sW, sH, hEW, eH],...
    'String', 'Colors:',...
    'HorizontalAlignment', 'left');

txSelectedColorDisp=uicontrol('Parent', figMain, txP{:},...
    'Position', [sW+hEW, sH, hEW, eH]);
callbackLbBehaviors();


sW=sW+eW+spW;
sH=1-eH;

txStreams=uicontrol('Parent', figMain, txP{:},...
    'Position', [sW, sH, eW, eH],...
    'String', 'Show streams:',...
    'HorizontalAlignment', 'left');
sH=sH-eH;
edStreams=uicontrol('Parent', figMain, edP{:},...
    'Position', [sW, sH, eW, eH],...
    'String', streamString{curExp});


sH=sH-eH-spH;
txStartFrame=uicontrol('Parent', figMain, txP{:},...
    'String', 'Start at frame:',...
    'Position', [sW, sH, eW, eH]);
sH=sH-eH;
edStartFrame=uicontrol('Parent', figMain, edP{:},...
    'String', num2str(startPoint{curExp}),...
    'Position', [sW, sH, eW, eH]);


sH=sH-eH-spH;
txEndFrame=uicontrol('Parent', figMain, txP{:},...
    'String', 'End at frame:',...
    'Position', [sW, sH, eW, eH]);
sH=sH-eH;
edEndFrame=uicontrol('Parent', figMain, edP{:},...
    'String', num2str(stopPoint{curExp}),...
    'Position', [sW, sH, eW, eH]);

sH=sH-eH-spH;
txFramesPerRow=uicontrol('Parent', figMain, txP{:},...
    'String', 'Resolution (frames per row):',...
    'Position', [sW, sH, eW, eH]);
sH=sH-eH;
edFramesPerRow=uicontrol('Parent', figMain, edP{:},...
    'String', num2str(frameRes{curExp}),...
    'Position', [sW, sH, eW/2, eH],...
    'Callback', @callbackFramesPerRow);
chFramesPerRow=uicontrol('Parent', figMain, chP{:},...
    'String', 'Apply to all',...
    'Position', [sW+eW/2, sH, eW/2, eH],...
    'Callback', @callbackFramesPerRow);

sH=sH-eH-spH;
puFramesOrSeconds=uicontrol('Parent', figMain, puP{:},...
    'String', {'Frames','Seconds'},...
    'Position', [sW, sH, eW/2, eH],...
    'Callback', @callbackPuFramesOrSeconds);
edFramesPerSecond=uicontrol('Parent', figMain, edP{:},...
    'String', '30',...
    'Position', [sW+eW/2, sH, eW/4, eH],...
    'Callback', @callbackEdFramesPerSecond,...
    'Enable', 'off');
txFramesPerSecond=uicontrol('Parent', figMain, txP{:},...
    'String', 'FPS',...
    'Position', [sW+3*eW/4, sH, eW/4, eH]);

sH=sH-eH-spH;
chIncludeLegend=uicontrol('Parent', figMain, chP{:},...
    'String', 'Include Legend',...
    'Position', [sW, sH, eW, eH],...
    'Value', true);
sH=sH-eH-spH;
pbDownQueue=uicontrol('Parent', figMain, pbP{:},...
    'String', 'Down Queue',...
    'Position', [sW, sH, hEW, eH],...
    'Callback', {@callbackMoveQueue, 'down'});
pbUpQueue=uicontrol('Parent', figMain, pbP{:},...
    'String', 'Up Queue',...
    'Position', [sW+hEW, sH, hEW, eH],...
    'Callback', {@callbackMoveQueue, 'up'});

sH=sH-eH-2*spH;
pbLoadNewData=uicontrol('Parent', figMain, pbP{:},...
    'String', 'Load New Data',...
    'Position', [sW, sH, eW, eH],...
    'Callback', @callbackLoadNewData);

sH=sH-eH-2*spH;

pbMakeAllRasters=uicontrol('Parent', figMain, pbP{:},...
    'String', 'Make/Save All Rasters',...
    'Position', [sW, sH, eW, eH],...
    'Callback', @callbackMakeAllRasters);

sH=sH-eH-spH;
txSaveRastersAs=uicontrol('Parent', figMain, txP{:},...
    'String', 'Save as:',...
    'Position', [sW, sH, hEW, eH]);
puSaveRastersAs=uicontrol('Parent', figMain, puP{:},...
    'String', imageFormats,...
    'Position', [sW+hEW, sH, hEW, eH],...
    'Value', imgExtInd,...
    'HorizontalAlignment', 'right');


%% Changing GUI settings
    function callbackPuExperiment(varargin)
        curExp=get(puExperiment, 'Value');
        updateGUI();
    end

    function callbackChangeColor(varargin)
        newColorString=get(edChangeColor, 'String');
        newColor=str2num(newColorString);
        if any(size(newColor)~=[1,3]) || min(newColor)<0 || max(newColor)>1
            disp('Color must be of form [r, g, b] where each entry is between 0 and 1.');
            return
        end
        selectionInds=get(lbBehaviors, 'Value');
        colorString(selectionInds)={newColorString};
        behaviorString=cellfun(@horzcat, behaviorStringBase,...
            ellipsesString, colorString, 'UniformOutput', false);
        set(lbBehaviors, 'String', behaviorString);
        colorList=cellfun(@str2num, colorString, 'UniformOutput', false);
        otherColor=specialColor{1};
        set(txSelectedColorDisp, 'BackgroundColor',...
            get(txChangeColorDisp, 'BackgroundColor'));
        updateOtherInd();
    end

    function callbackChangeBehavior(varargin)
        newBehaviorName=get(edChangeBehavior, 'String');
        currentVal=get(lbBehaviors, 'Value');
        if isempty(strtrim(newBehaviorName))
            errordlg('Please enter at least one non-whitespace character.');
        elseif length(currentVal) > 1
            errordlg(['Behavior names must be unique. '...
                'Please select only one behavior name to change at a time.']);
        elseif length(currentVal) < 1
            errordlg('Please select at least one behavior name to change.');
        else
            currentMatches=strcmpi(behaviorStringBase, newBehaviorName);
            if find(currentMatches)~=currentVal
                errordlg(['The behavior "' newBehaviorName...
                    '" already exists. Behavior names must be unique. '...
                    'Please choose a different name for the behavior.']);
            else %No error
                behaviorStringBase{currentVal}=newBehaviorName;
                makeEllipsesString();
                behaviorString=cellfun(@horzcat, behaviorStringBase,...
                    ellipsesString, colorString, 'UniformOutput', false);
                set(lbBehaviors, 'String', behaviorString);
                updateOtherInd();
            end
        end
    end

    function callbackMoveQueue(hSource, eventData, upOrDown)
        indsToMove=get(lbBehaviors,'Value');
        nInds=length(indsToMove);
        if nInds < 1
            return
        end
        switch upOrDown
            case 'up'
%                 minList=1:nInds
                for k=1:nInds
                    if indsToMove(k) > k
                        indsToSwap=[indsToMove(k), indsToMove(k)-1];
                        swapLists(indsToSwap);
                        if k==otherInd
                            otherInd=k-1;
                        end
                        indsToMove(k)=indsToMove(k)-1;
                    end
                end
            case 'down'
                indsToMove=fliplr(indsToMove);
                maxList=nBehaviors-(1:nInds)+1;
                for k=1:nInds
                    if indsToMove(k) < maxList(k)
                        indsToSwap=[indsToMove(k),indsToMove(k)+1];
                        swapLists(indsToSwap);
                        if k==otherInd
                            otherInd=k+1;
                        end
                        indsToMove(k)=indsToMove(k)+1;
                    end
                end
        end
        indsToMove=sort(unique(indsToMove));
        set(lbBehaviors, 'Value', indsToMove);
        updateGUI();
    end

    function callbackLbBehaviors(varargin)
        selectionList=get(lbBehaviors, 'Value');
        selectionNum=length(selectionList);
        if selectionNum==1
            selectedColorDisp=colorList{selectionList};
        elseif selectionNum > 1
            allSame=true;
            for k=2:length(selectionList)
                allSame=allSame &&...
                    all(colorList{selectionList(1)}==colorList{selectionList(k)});
            end
            if allSame
                selectedColorDisp=colorList{selectionList(1)};
            else
                selectedColorDisp=get(txColors, 'BackgroundColor');
            end
        else
            selectedColorDisp=get(txColors, 'BackgroundColor');
        end
        set(txSelectedColorDisp, 'BackgroundColor', selectedColorDisp);
    end

    function callbackEdChangeColor(varargin)
        changeColorString=get(edChangeColor, 'String');
        newColor=str2num(changeColorString);
        
        if all(size(newColor)==[1,3]) && all(newColor>=0) && all(newColor<=1)
            set(txChangeColorDisp, 'BackgroundColor', newColor);
            oldChangeColorString=get(edChangeColor, 'String');
        else
            set(edChangeColor, 'String', oldChangeColorString);
        end
    end

    function callbackPuFramesOrSeconds(varargin)
        framesOrSecondsValue=get(puFramesOrSeconds,'Value');
        if framesOrSecondsValue==1
            set(edFramesPerSecond,'Enable','off');
        elseif framesOrSecondsValue==2
            set(edFramesPerSecond,'Enable','on');
        end
    end

    function callbackEdFramesPerSecond(varargin)
        newFPS=get(edFramesPerSecond,'String');
        if ~isempty(newFPS)
            framesPerSecond=str2double(newFPS);
        else
            set(edFramesPerSecond,'String',num2str(framesPerSecond));
        end
    end

%% Automatic GUI and data updating
    function makeBehaviorString()
        makeEllipsesString();
        behaviorString=cellfun(@horzcat, behaviorStringBase, ellipsesString, colorString, 'UniformOutput', false);
    end

    function makeEllipsesString()
        behaviorStringLengths=cellfun(@length,behaviorStringBase, 'UniformOutput', false);
        maxBehaviorStringLength=max([behaviorStringLengths{:}])+...
            minEllipsisLength;
        minStringLength=max(minTotalCharLength, maxBehaviorStringLength);
        minStringLengthList=repmat({minStringLength},nBehaviors,1);
        ellipsesLengths=cellfun(@minus, minStringLengthList, behaviorStringLengths, 'UniformOutput', false);
        ellipsesStringBase=repmat({'.'}, nBehaviors, 1);
        oneList=repmat({1},nBehaviors,1);
        ellipsesString=cellfun(@repmat,ellipsesStringBase, oneList,ellipsesLengths,'UniformOutput',false);
    end
    
    function partitionInds=getPartitionInds(L)
        [partition, n]=partitionList(L);
        partitionInds=zeros(n,1);
        for k=1:n
            partitionInds(k)=find(partition==k,1,'first');
        end
    end

    function [partition, partCount]=partitionList(L)
        n=length(L);
        partition=zeros(n,1);
        compMatColRep=repmat(L,1,n);
        compMatRowRep=compMatColRep';
        matchMat=cellfun(@isequal,compMatColRep,compMatRowRep, 'UniformOutput', false);
        matchMatLog=cellfun(@all, matchMat);
        partCount=0;
        for k=1:n
            if ~partition(k)
                partCount=partCount+1;
                partition(matchMatLog(:,k))=partCount;
            end
        end
    end
    
    function csv=cell2csv(L)
        n=length(L);
        if n==1
            csv=L{:};
            return
        end
        m=n-1;
        L(1:m)=cellfun(@horzcat, L(1:m),repmat({', '},m,1),'UniformOutput',false);
        csv=[L{:}];
    end

    function swapLists(indsToSwap)
        colorList=listSwap(colorList,indsToSwap);
        colorString=listSwap(colorString,indsToSwap);
        behaviorStringBase=listSwap(behaviorStringBase,indsToSwap);
        rawBehaviorString=listSwap(rawBehaviorString, indsToSwap);
        ellipsesString=listSwap(ellipsesString, indsToSwap);
        behaviorString=listSwap(behaviorString, indsToSwap);
    end

    function list=listSwap(list, indsToSwap)
        list(indsToSwap)=list(fliplr(indsToSwap));
    end

    function callbackFramesPerRow(varargin)
        frameResString=get(edFramesPerRow, 'String');
        frameResNum=num2str(frameResString);
        if isempty(frameResNum)
            set(edFramesPerRow, 'String', num2str(frameRes{curExp}));
            return
%         else
%             resLimits=cellfun(@minus, stopPoint, startPoint);
        end
        if get(chFramesPerRow, 'Value')
            for k=1:nFiles
                frameRes{k}=frameResNum;
            end
        else
            frameRes{curExp}=frameResNum;
        end
    end
 
    function sortLists()
        %Sorts lists according to order of scBehaviors with behaviors
        %appearing in this list always on the top.
        
        scbCell=repmat({scBehaviors}, nBehaviors, 1);
        lbCell=repmat({rawBehaviorString}, nSpecialColors, 1);
        
        lbIndsFound=cellfun(@ismember, rawBehaviorString, scbCell);
        lbIndsNotFound=~lbIndsFound;
        
        scIndsFound=cellfun(@ismember, scBehaviors, lbCell);
        
        effIndsRawTop=find(lbIndsFound);
        effIndsBot=find(lbIndsNotFound);
        
        [sortDump topIndInds]=sort(scBehaviors(scIndsFound));
        [sortDump topIndMap]=sort(topIndInds);
        
        effIndsTop=effIndsRawTop(topIndMap);
        
        affIndsTop=1:sum(lbIndsFound);
        affIndsBot=(nSpecialColors-sum(lbIndsNotFound)+1):nBehaviors;
        
        effInds=vertcat(effIndsTop, effIndsBot);
        affInds=(1:nBehaviors)';
        
        colorList(affInds)=colorList(effInds);
        colorString(affInds)=colorString(effInds);
        behaviorStringBase(affInds)=behaviorStringBase(effInds);
        rawBehaviorString(affInds)=rawBehaviorString(effInds);
        ellipsesString(affInds)=ellipsesString(effInds);
        behaviorString(affInds)=behaviorString(effInds);
    end

    function updateOtherInd()
       otherInds=strcmpi(behaviorStringBase, 'other');
       if any(otherInds)
           otherInds=find(otherInds);
           otherInd=otherInds(1);
       else
           otherInd=0;
           otherColor=str2num(defaultColorString);
       end
       if otherInd > 0
           otherColor=colorList{otherInd};
       end
       isNotOther= @(x) any(x~=otherColor);
    end

    function updateGUI()
        %set(edStreams, 'String', streamString{curExp});
        set(lbBehaviors, 'String', behaviorString,...
            'Max', length(behaviorString));
        set(puExperiment, 'String', fileNames, 'Value', curExp);
        set(edStartFrame, 'String', startPoint{curExp});
        set(edEndFrame, 'String', num2str(stopPoint{curExp}));
        set(edFramesPerRow, 'String', num2str(frameRes{curExp}));
    end


%% Calculating and displaying rasters
    function callbackMakeAllRasters(hSource, eventData)
        for k=1:nFiles
            set(puExperiment, 'Value', k);
            callbackPuExperiment();
            callbackMakeRaster(hSource, eventData, true);
        end
    end

    function callbackMakeRaster(varargin)
        if nargin > 2
            closeAndSave=varargin{3};
        else
            closeAndSave=false;
        end
        streamString{curExp}=get(edStreams, 'String');
        streamsToShow=eval(['[', streamString{curExp}, ']']);
        
        validStreams=streamsToShow > 0 & streamsToShow<=nStreams{curExp};
        streamsToShow=streamsToShow(validStreams);
        nStrmShow=length(streamsToShow);
        
        startFrame=round(str2num(get(edStartFrame,'String')))-1;
        endFrame=round(str2num(get(edEndFrame, 'String')));
        framesPerRow=round(str2num(get(edFramesPerRow, 'String')));
        
        showLegend=get(chIncludeLegend, 'Value');
       
        minFrame=0;
        maxFrame=a{curExp}.nFrame();
        
        startFrame=notInBounds(startFrame,minFrame, maxFrame, 'min');
        endFrame=notInBounds(endFrame,minFrame, maxFrame, 'max');
        
        frameRange=endFrame-startFrame;
        numRows=ceil(frameRange/framesPerRow);
        
        lastRowLength=rem(frameRange, framesPerRow);
        numRasters=nStrmShow*numRows;
        
        %Make figure for rasters:        
        rasterFigHeight=rasterPixelHeight*numRasters+...
            (numRows+1)*spacePixelHeight+2*spacePixelHeight;
        
        if showLegend
            colorsToShow=cellfun(isNotOther, colorList);
            plotBehaviors=getPlotBehaviors();
            for kk=1:nBehaviors
                if colorsToShow(kk)
                    colorsToShow(kk)=...
                        any(strcmp(plotBehaviors,rawBehaviorString(kk)));
                end 
            end
            colorListToShow=colorList(colorsToShow);
            partitionInds=getPartitionInds(colorListToShow);
            numColorsToShow=length(partitionInds);
            colorListToShow=colorListToShow(partitionInds);
            numLegendRows=ceil(numColorsToShow/3);
            
            behaviorsToShow=behaviorStringBase(colorsToShow);
            behaviorsToShow=behaviorsToShow(partitionInds);
            rasterFigHeight=rasterFigHeight+...
            numLegendRows*legendBarHeight+2*spacePixelHeight;
        end
        
        rasterWidthStart=floor(screenWidth-rasterFigWidth)/2;
        rasterHeightStart=floor(screenHeight-rasterFigHeight)/2;
        
        rasterFig = figure(...
            'Resize', 'on',...
            'Toolbar', 'auto',...
            'Units', 'pixels',...
            'Visible', 'on',...
            'Position', [rasterWidthStart rasterHeightStart rasterFigWidth rasterFigHeight]);
        
        %Put legend in figure
        if showLegend
            legendAxHeightStart=spacePixelHeight/rasterFigHeight;
            legendAxHeight=(numLegendRows+1)*legendBarHeight/rasterFigHeight;
            
            legendAxes=axes('Parent', rasterFig,...
                'Units', 'normalized',...
                'Position', [rasterAxWidthStart, legendAxHeightStart,...
                rasterAxWidth, legendAxHeight],...
                'Visible', 'off',...
                'XLimMode', 'manual',...
                'YLimMode', 'manual',...
                'YTickLabel', {''},...
                'YMinorTick', 'off',...
                'XTickMode', 'manual',...
                'YTickMode', 'manual',...
                'YTick', [],...
                'XTick', [],...
                'XLim', [0, 6],...
                'YLim', [-1,numLegendRows]);
            xs=0;
            ys=numLegendRows-1;
            xw=.5;
            yh=1;
            spX=xw/5;
            [legendText, legendBar, textStartsY, textHeights]=...
                deal(zeros(numColorsToShow,1));
            textExtents=zeros(numColorsToShow,4);
            [textStartsX, textWidths]=deal(zeros(3,1));
            colCount=1;
            for k=1:numColorsToShow
                legendText(k)=text(xs,ys,behaviorsToShow{k},...
                    'Parent', legendAxes,...
                    'Interpreter', 'none');
                
                textExtents(k,:)=get(legendText(k), 'Extent');
                textStartsY(k)=textExtents(k,2);
                textHeights(k)=textExtents(k,4);
                ys=mod(ys-1,numLegendRows);
                
                if ys==(numLegendRows-1) || k==numColorsToShow
                    startInd=k-ys;
                    textStartsX(colCount)=max(textExtents(startInd:k,1));
                    textWidths(colCount)=max(textExtents(startInd:k,3));
                    xs=xs+2;
                    colCount=colCount+1;
                end

            end
            barStartsX=textStartsX+textWidths+spX;
            textStartsY=textStartsY+textHeights/4;
            
            for k=1:numColorsToShow
                colCount=ceil(k/numLegendRows);
                barPos=[barStartsX(colCount), textStartsY(k), xw, textHeights(k)/2];
                legendBar(k)=rectangle('Parent', legendAxes,...
                    'Position', barPos,...
                    'FaceColor', colorListToShow{k},...
                    'EdgeColor', colorListToShow{k});
            end
            
        end
        %% ===============================================
        %Put raster axes in figure:
        rasterAxHeight=rasterPixelHeight/rasterFigHeight;
        spaceHeight=spacePixelHeight/rasterFigHeight;
        rasterAxHeightStart=1;
        
        xStarts=zeros(numRows,1);
        xEnds=zeros(numRows,1);
        xStart=startFrame-framesPerRow;
        xEnd=startFrame;
        
        rasterAxes=zeros(numRows,nStrmShow);
        for k=1:numRows
            rasterAxHeightStart=rasterAxHeightStart-spaceHeight;
            
            xStart=xStart+framesPerRow;
            if k==numRows
                xEnd=endFrame+1;
            else
                xEnd=xEnd+framesPerRow;
            end
            xStarts(k)=xStart;
            xEnds(k)=xEnd;

            for kk=1:nStrmShow
                rasterAxHeightStart=rasterAxHeightStart-rasterAxHeight;
                rasterAxes(k,kk)=axes('Parent', rasterFig,...
                    'Units', 'normalized',...
                    'Position', [rasterAxWidthStart, rasterAxHeightStart,...
                    rasterAxWidth, rasterAxHeight],...
                    'Layer', 'top',...
                    'XLimMode', 'manual',...
                    'YLimMode', 'manual',...
                    'YTickLabel', {''},...
                    'YMinorTick', 'off',...
                    'XTickMode', 'manual',...
                    'YTickMode', 'manual',...
                    'YTick', [],...
                    'XTick', [],...
                    'XLim', [xStart xEnd],...
                    'YLim', [0,1]);
                
            end
            
        end
        
        %% ===============================================
        %Set tick marks automatically
        set(rasterAxes(:,nStrmShow), 'XTickMode', 'auto');
        lastRasterAxWidth=rasterAxWidth*lastRowLength/framesPerRow;
        if lastRasterAxWidth == 0
            lastRasterAxWidth=rasterAxWidth;
        end
        rasterAxHeightStart=rasterAxHeightStart+rasterAxHeight*(nStrmShow-1);
        for kk=1:nStrmShow
            set(rasterAxes(numRows,kk), 'Position',...
                [rasterAxWidthStart, rasterAxHeightStart,...
                lastRasterAxWidth, rasterAxHeight],...
                'XLim', [xStart xEnd]);
            rasterAxHeightStart=rasterAxHeightStart-rasterAxHeight;
        end
        
        %% ===============================================
        %Add rectangles to plot
        rectNum=1;
        for kk=1:nStrmShow
            rowNum=1;
            a{curExp}.setStrm(streamsToShow(kk));
            annotations=consolidateRectangles();
            nBlocks=length(annotations);
            frameBoundaries=[a{curExp}.getBnds()' circshift(a{curExp}.getBnds()',-1)];
            frameBoundaries=frameBoundaries(1:nBlocks,:);
            
            rectWidths=frameBoundaries(:,2)-frameBoundaries(:,1);
            for m=1:nBlocks
                if frameBoundaries(m,1) < xStarts(rowNum)
                    frameBoundaries(m,1)=xStarts(rowNum);
                end
                if frameBoundaries(m,2) <= xEnds(rowNum)
                    r(rectNum)=rectangle('Parent', rasterAxes(rowNum,kk),...
                        'Position', [frameBoundaries(m,1), 0, rectWidths(m), 1],...
                        'FaceColor', colorList{annotations(m)},...
                        'EdgeColor', colorList{annotations(m)});
                    rectNum=rectNum+1;
                end
                
                while frameBoundaries(m,2) > xEnds(rowNum)
                    
                    if xEnds(rowNum) > frameBoundaries(m,1);
                        startRect=frameBoundaries(m,1);
                        
                        rectWidth=xEnds(rowNum)-startRect;
                        r(rectNum)=rectangle('Parent', rasterAxes(rowNum,kk),...
                            'Position', [startRect, 0, rectWidth, 1],...
                            'FaceColor', colorList{annotations(m)},...
                            'EdgeColor', colorList{annotations(m)});
                        rectNum=rectNum+1;
                    end
                    
                    rectNum=rectNum+1;
                    if rowNum < numRows
                        rowNum=rowNum+1;
                        if frameBoundaries(m,2) <= xEnds(rowNum)
                            rectWidth=frameBoundaries(m,2)-xStarts(rowNum);
                            r(rectNum)=rectangle('Parent', rasterAxes(rowNum,kk),...
                                'Position', [xStarts(rowNum), 0, rectWidth, 1],...
                                'FaceColor', colorList{annotations(m)},...
                                'EdgeColor', colorList{annotations(m)});
                            rectNum=rectNum+1;
                        end
                    else
                        break
                    end
                end
                if (frameBoundaries(m,2) > xEnds(rowNum)) && (rowNum>=numRows)
                    break
                end
            end
        end
        
        if closeAndSave
            originalImgFile=[filePaths{curExp}, fileNames{curExp}];
            imgFormat=imageFormats{get(puSaveRastersAs, 'Value')};
            imgExt=['.', imgFormat];
            
            fullImgFile=[originalImgFile, imgExt];
            imgFileCount=1;

            while exist(fullImgFile, 'file');
                fullImgFile=[originalImgFile, '_', num2str(imgFileCount),...
                    imgExt];
                imgFileCount=imgFileCount+1;
            end
            
            saveas(rasterFig, fullImgFile, imgFormat);
            delete(rasterFig);
        end
        
    end

    function plotBehaviors=getPlotBehaviors()
        streamsToShow=eval(['[', streamString{curExp}, ']']);
        streamLabels=cell(nStreams{curExp},1);
        behaviorNames=a{curExp}.getNames()';
        for jj=streamsToShow
            a{curExp}.setStrm(jj);
            streamLabels{jj}=unique(a{curExp}.getTypes()');
        end
        plotBehaviorInds=union(streamLabels{:});
        plotBehaviors=behaviorNames(plotBehaviorInds);
    end

    function frame=notInBounds(frame, minFrame, maxFrame, minOrMax)
        if isempty(frame)
            switch minOrMax
                case 'min'
                    frame=minFrame;
                case 'max'
                    frame=maxFrame;
            end
            return
        end
        
        if frame < minFrame
            frame=minFrame;
        elseif frame > maxFrame
            frame=maxFrame;
        end
        
    end

    function annotations=consolidateRectangles()
        annotations=getAnnotations();
        for ii=1:nBehaviors
            for jj=ii:nBehaviors
                if all(colorList{ii}==colorList{jj})
                    jjInds=annotations==jj;
                    annotations(jjInds)=ii; 
                end
            end
        end
    end
    
    function annotations=getAnnotations()
        rawAnnotations=uint16(a{curExp}.getTypes()');
        oneFileBehaviors=a{curExp}.getNames();
        nBeh=length(oneFileBehaviors);
        annLength=length(rawAnnotations);
        annotations=zeros(annLength,1);
        for k=1:nBeh
            newInd=find(strcmp(rawBehaviorString,oneFileBehaviors{k}));
            annotations(rawAnnotations==k)=newInd;
        end
    end


%% Saving and loading data
    function callbackLoadNewData(varargin)
        loadRasterData();
        updateGUI();
    end

    function loadRasterData()
        if exist(filePath, 'dir')~=7
            filePath='.\';
        end
        if ~strcmp(filePath(length(filePath)),filesep)
            filePath=[filePath filesep];
        end
        savePath();
        
        fullPath=uipickfiles('FilterSpec', [filePath, '*.txt']);
        if iscell(fullPath) && ~isempty(fullPath)
            nFiles=length(fullPath);
            a=cell(nFiles,1);
            behaviorNames=cell(nFiles,1);
            behaviorStringBase={};
            for k=1:nFiles
                a{k}=behavior_data('load', fullPath{k});
                stopPoint{k}=a{k}.nFrame();
                frameRes{k}=round(stopPoint{k}/defaultRowNum);
                nStreams{k}=a{k}.nStrm();
                streamString{k}=cell2csv(cellfun(@num2str, mat2cell((1:nStreams{k}),1,ones(nStreams{k},1)), 'UniformOutput', false));
                behaviorNames{k}=a{k}.getNames()';
                behaviorStringBase=union(behaviorStringBase, behaviorNames{k});
            end
        else
            noneSelected=true;
            return
        end
        startPoint=repmat({1},nFiles,1);
        curExp=1;
        
        [filePaths, fileNames, fileExts]=cellfun(@fileparts, fullPath, 'UniformOutput', false);
        filePaths=strcat(filePaths, filesep);
        filePath=filePaths{nFiles};
        savePath();
        
        [rawBehaviorString, superRawBehaviors]=deal(behaviorStringBase);
        nBehaviors=length(behaviorStringBase);
        colorString=repmat({defaultColorString},nBehaviors,1);
        
        if ~defaultsFound
            nSpecialColors=12;
            [specialColorString scInds]=deal(cell(nSpecialColors,1));
            specialColorString{1,1}='[1,1,1]';     %Other         - white
            specialColorString{2,1}='[.6,.6,.6]';  %Ignore        - gray
            specialColorString{3,1}='[.4,.6,1]';   %Light         - light blue
            specialColorString{4,1}='[0,1,0]';     %Mount         - green
            specialColorString{5,1}='[1,0,0]';     %Attack        - red
            specialColorString{6,1}='[1,.6,0]';    %Chase         - orange
            specialColorString{7,1}='[0,0,.75]';   %Corner        - dark blue
            specialColorString{8,1}='[1,1,0]';     %Sniffgenitals - yellow
            specialColorString{9,1}='[0,0,0]';     %Circle        - black
            specialColorString{10,1}='[1,0,0]';    %Bite          - red
            specialColorString{11,1}='[1,.5,.5]';  %Redlight      - light red
            specialColorString{12,1}='[.5,1,.5]';  %Greenlight    - light green
            
            scBehaviors={...
                'other';...
                'ignore';...
                'light';...
                'mount';...
                'attack';...
                'chase';...
                'corner';...
                'sniffgenitals';...
                'circle';...
                'bite';...
                'redlight';...
                'greenlight'};
            
        end
        specialColor=cellfun(@str2num,specialColorString,'UniformOutput', false);
        for k=1:nSpecialColors
            if ~isempty(specialColor{k,1})
                scInds{k}=strcmpi(behaviorStringBase,scBehaviors{k});
                if any(scInds{k})
                    colorString{scInds{k}}=specialColorString{k};
                end
            end
        end
        
        makeBehaviorString();
        colorList=cellfun(@str2num, colorString, 'UniformOutput', false);
        
        sortLists();
        updateOtherInd();
    end
    function savePath()
        nChars=length(filePath);
        if exist(filePath, 'dir')~=7
            filePath='.\';
        end
        if ~strcmp(filePath(nChars),filesep)
            filePath=[filePath filesep];
        end
        if exist(colorFileFullPath, 'file')==2
            save(colorFileFullPath, '-mat', 'filePath', '-append');
        end
    end


%% Saving and loading settings
    function saveColors(varargin)
        save(colorFileFullPath, '-mat',...
            'behaviorStringBase', 'colorString', 'colorList', 'filePath');
        savePath();
        disp('Colors saved.');
    end

    function loadColors(varargin)
        [colorFilePath, ~, ~] =...
            fileparts(mfilename('fullpath'));
        colorFileFullPath=[colorFilePath, filesep, defaultColorFile];
        imgExtNotFound=true;
        try
            colorMat=load(colorFileFullPath);
            specialColorString=colorMat.colorString;
            scBehaviors=colorMat.behaviorStringBase;
            nSpecialColors=length(specialColorString);
            
            if isfield(colorMat, 'filePath')
                filePath=colorMat.filePath;
            else
                filePath=['.' filesep];
            end
            
            if isfield(colorMat, 'imgExtension')
                imgExtension=colorMat.imgExtension;
                extMatches=strcmpi(imageFormats,imgExtension);
                if any(extMatches)
                    imgExtInd=find(extMatches, 1, 'first');
                    imgExtNotFound=false;
                end
            end
            if imgExtNotFound
                imgExtInd=defaultImgFormatInd;
            end
            
            defaultsFound=true;
        catch errorMessage
            colorFileFullPath
            disp(errorMessage);
            defaultsFound=false;
        end
    end

end






%% 
%All functions below are part of uipickfiles(), a program written by
%Douglas M. Schwartz, and made available online. They are included here
%since the makeRasters() program calls the main function.


function out = uipickfiles(varargin)
%uipickfiles: GUI program to select files and/or folders.
%
% Syntax:
%   files = uipickfiles('PropertyName',PropertyValue,...)
%
% The current folder can be changed by operating in the file navigator:
% double-clicking on a folder in the list or pressing Enter to move further
% down the tree, using the popup menu, clicking the up arrow button or
% pressing Backspace to move up the tree, typing a path in the box to move
% to any folder or right-clicking (control-click on Mac) on the path box to
% revisit a previously-visited folder.  These folders are listed in order
% of when they were last visited (most recent at the top) and the list is
% saved between calls to uipickfiles.  The list can be cleared or its
% maximum length changed with the items at the bottom of the menu.
% (Windows only: To go to a UNC-named resource you will have to type the
% UNC name in the path box, but all such visited resources will be
% remembered and listed along with the mapped drives.)  The items in the
% file navigator can be sorted by name, modification date or size by
% clicking on the headers, though neither date nor size are displayed.  All
% folders have zero size.
%
% Files can be added to the list by double-clicking or selecting files
% (non-contiguous selections are possible with the control key) and
% pressing the Add button.  Control-F will select all the files listed in
% the navigator while control-A will select everything (Command instead of
% Control on the Mac).  Since double-clicking a folder will open it,
% folders can be added only by selecting them and pressing the Add button.
% Files/folders in the list can be removed or re-ordered.  Recall button
% will insert into the Selected Files list whatever files were returned the
% last time uipickfiles was run.  When finished, a press of the Done button
% will return the full paths to the selected items in a cell array,
% structure array or character array.  If the Cancel button or the escape
% key is pressed then zero is returned.
%
% The figure can be moved and resized in the usual way and this position is
% saved and used for subsequent calls to uipickfiles.  The default position
% can be restored by double-clicking in a vacant region of the figure.
%
% The following optional property/value pairs can be specified as arguments
% to control the indicated behavior:
%
%   Property    Value
%   ----------  ----------------------------------------------------------
%   FilterSpec  String to specify starting folder and/or file filter.
%               Ex:  'C:\bin' will start up in that folder.  '*.txt'
%               will list only files ending in '.txt'.  'c:\bin\*.txt' will
%               do both.  Default is to start up in the current folder and
%               list all files.  Can be changed with the GUI.
%
%   REFilter    String containing a regular expression used to filter the
%               file list.  Ex: '\.m$|\.mat$' will list files ending in
%               '.m' and '.mat'.  Default is empty string.  Can be used
%               with FilterSpec and both filters are applied.  Can be
%               changed with the GUI.
%
%   REDirs      Logical flag indicating whether to apply the regular
%               expression filter to folder names.  Default is false which
%               means that all folders are listed.  Can be changed with the
%               GUI.
%
%   Type        Two-column cell array where the first column contains file
%               filters and the second column contains descriptions.  If
%               this property is specified an additional popup menu will
%               appear below the File Filter and selecting an item will put
%               that item into the File Filter.  By default, the first item
%               will be entered into the File Filter.  For example,
%                   { '*.m',   'M-files'   ;
%                     '*.mat', 'MAT-files' }.
%               Can also be a cell vector of file filter strings in which
%               case the descriptions will be the same as the file filters
%               themselves.
%               Must be a cell array even if there is only one entry.
%
%   Prompt      String containing a prompt appearing in the title bar of
%               the figure.  Default is 'Select files'.
%
%   NumFiles    Scalar or vector specifying number of files that must be
%               selected.  A scalar specifies an exact value; a two-element
%               vector can be used to specify a range, [min max].  The
%               function will not return unless the specified number of
%               files have been chosen.  Default is [] which accepts any
%               number of files.
%
%   Append      Cell array of strings, structure array or char array
%               containing a previously returned output from uipickfiles.
%               Used to start up program with some entries in the Selected
%               Files list.  Any included files that no longer exist will
%               not appear.  Default is empty cell array, {}.
%
%   Output      String specifying the data type of the output: 'cell',
%               'struct' or 'char'.  Specifying 'cell' produces a cell
%               array of strings, the strings containing the full paths of
%               the chosen files.  'Struct' returns a structure array like
%               the result of the dir function except that the 'name' field
%               contains a full path instead of just the file name.  'Char'
%               returns a character array of the full paths.  This is most
%               useful when you have just one file and want it in a string
%               instead of a cell array containing just one string.  The
%               default is 'cell'.
%
% All properties and values are case-insensitive and need only be
% unambiguous.  For example,
%
%   files = uipickfiles('num',1,'out','ch')
%
% is valid usage.

% Version: 1.14, 5 January 2012
% Author:  Douglas M. Schwarz
% Email:   dmschwarz=ieee*org, dmschwarz=urgrad*rochester*edu
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
% Copyright (c) 2007, Douglas M. Schwarz
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.


% Define properties and set default values.
prop.filterspec = '*';
prop.refilter = '';
prop.redirs = false;
prop.type = {};
prop.prompt = 'Select files';
prop.numfiles = [];
prop.append = [];
prop.output = 'cell';

% Process inputs and set prop fields.
prop = parsepropval(prop,varargin{:});

% Validate FilterSpec property.
if isempty(prop.filterspec)
	prop.filterspec = '*';
end
if ~ischar(prop.filterspec)
	error('FilterSpec property must contain a string.')
end

% Validate REFilter property.
if ~ischar(prop.refilter)
	error('REFilter property must contain a string.')
end

% Validate REDirs property.
if ~isscalar(prop.redirs)
	error('REDirs property must contain a scalar.')
end

% Validate Type property.
if isempty(prop.type)
elseif iscellstr(prop.type) && isscalar(prop.type)
	prop.type = repmat(prop.type(:),1,2);
elseif iscellstr(prop.type) && size(prop.type,2) == 2
else
	error(['Type property must be empty or a cellstr vector or ',...
		'a 2-column cellstr matrix.'])
end

% Validate Prompt property.
if ~ischar(prop.prompt)
	error('Prompt property must contain a string.')
end

% Validate NumFiles property.
if numel(prop.numfiles) > 2 || any(prop.numfiles < 0)
	error('NumFiles must be empty, a scalar or two-element vector.')
end
prop.numfiles = unique(prop.numfiles);
if isequal(prop.numfiles,1)
	numstr = 'Select exactly 1 file.';
elseif length(prop.numfiles) == 1
	numstr = sprintf('Select exactly %d items.',prop.numfiles);
else
	numstr = sprintf('Select %d to %d items.',prop.numfiles);
end

% Validate Append property and initialize pick data.
if isstruct(prop.append) && isfield(prop.append,'name')
	prop.append = {prop.append.name};
elseif ischar(prop.append)
	prop.append = cellstr(prop.append);
end
if isempty(prop.append)
	file_picks = {};
	full_file_picks = {};
	dir_picks = dir(' ');  % Create empty directory structure.
elseif iscellstr(prop.append) && isvector(prop.append)
	num_items = length(prop.append);
	file_picks = cell(1,num_items);
	full_file_picks = cell(1,num_items);
	dir_fn = fieldnames(dir(' '));
	dir_picks = repmat(cell2struct(cell(length(dir_fn),1),dir_fn(:)),...
		num_items,1);
	for item = 1:num_items
		if exist(prop.append{item},'dir') && ...
				~any(strcmp(full_file_picks,prop.append{item}))
			full_file_picks{item} = prop.append{item};
			[unused,fn,ext] = fileparts(prop.append{item});
			file_picks{item} = [fn,ext];
			temp = dir(fullfile(prop.append{item},'..'));
			if ispc || ismac
				thisdir = strcmpi({temp.name},[fn,ext]);
			else
				thisdir = strcmp({temp.name},[fn,ext]);
			end
			dir_picks(item) = temp(thisdir);
			dir_picks(item).name = prop.append{item};
		elseif exist(prop.append{item},'file') && ...
				~any(strcmp(full_file_picks,prop.append{item}))
			full_file_picks{item} = prop.append{item};
			[unused,fn,ext] = fileparts(prop.append{item});
			file_picks{item} = [fn,ext];
			dir_picks(item) = dir(prop.append{item});
			dir_picks(item).name = prop.append{item};
		else
			continue
		end
	end
	% Remove items which no longer exist.
	missing = cellfun(@isempty,full_file_picks);
	full_file_picks(missing) = [];
	file_picks(missing) = [];
	dir_picks(missing) = [];
else
	error('Append must be a cell, struct or char array.')
end

% Validate Output property.
legal_outputs = {'cell','struct','char'};
out_idx = find(strncmpi(prop.output,legal_outputs,length(prop.output)));
if length(out_idx) == 1
	prop.output = legal_outputs{out_idx};
else
	error(['Value of ''Output'' property, ''%s'', is illegal or '...
		'ambiguous.'],prop.output)
end


% Set style preference for display of folders.
%   1 => folder icon before and filesep after
%   2 => bullet before and filesep after
%   3 => filesep after only
folder_style_pref = 1;
fsdata = set_folder_style(folder_style_pref);

% Initialize file lists.
if exist(prop.filterspec,'dir')
	current_dir = prop.filterspec;
	filter = '*';
else
	[current_dir,f,e] = fileparts(prop.filterspec);
	filter = [f,e];
end
if isempty(current_dir)
	current_dir = pwd;
end
if isempty(filter)
	filter = '*';
end
re_filter = prop.refilter;
full_filter = fullfile(current_dir,filter);
network_volumes = {};
[path_cell,new_network_vol] = path2cell(current_dir);
if exist(new_network_vol,'dir')
	network_volumes = unique([network_volumes,{new_network_vol}]);
end
fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
	@(x)file_sort(x,[1 0 0]));
filenames = {fdir.name}';
filenames = annotate_file_names(filenames,fdir,fsdata);

% Initialize some data.
show_full_path = false;
nodupes = true;

% Get history preferences and set history.
history = getpref('uipickfiles','history',...
	struct('name',current_dir,'time',now));
default_history_size = 15;
history_size = getpref('uipickfiles','history_size',default_history_size);
history = update_history(history,current_dir,now,history_size);

% Get figure position preference and create figure.
gray = get(0,'DefaultUIControlBackgroundColor');
if ispref('uipickfiles','figure_position');
	fig_pos = getpref('uipickfiles','figure_position');
	fig = figure('Position',fig_pos,...
		'Color',gray,...
		'MenuBar','none',...
		'WindowStyle','modal',...
		'Resize','on',...
		'NumberTitle','off',...
		'Name',prop.prompt,...
		'IntegerHandle','off',...
		'CloseRequestFcn',@cancel,...
		'ButtonDownFcn',@reset_figure_size,...
		'KeyPressFcn',@keypressmisc,...
		'Visible','off');
else
	fig_pos = [0 0 740 494];
	fig = figure('Position',fig_pos,...
		'Color',gray,...
		'MenuBar','none',...
		'WindowStyle','modal',...
		'Resize','on',...
		'NumberTitle','off',...
		'Name',prop.prompt,...
		'IntegerHandle','off',...
		'CloseRequestFcn',@cancel,...
		'CreateFcn',{@movegui,'center'},...
		'ButtonDownFcn',@reset_figure_size,...
		'KeyPressFcn',@keypressmisc,...
		'Visible','off');
end

% Set system-dependent items.
if ismac
	set(fig,'DefaultUIControlFontName','Lucida Grande')
	set(fig,'DefaultUIControlFontSize',9)
	sort_ctrl_size = 8;
	mod_key = 'command';
	action = 'Control-click';
elseif ispc
	set(fig,'DefaultUIControlFontName','Tahoma')
	set(fig,'DefaultUIControlFontSize',8)
	sort_ctrl_size = 7;
	mod_key = 'control';
	action = 'Right-click';
else
	sort_ctrl_size = get(fig,'DefaultUIControlFontSize') - 1;
	mod_key = 'control';
	action = 'Right-click';
end

% Create uicontrols.
frame1 = uicontrol('Style','frame',...
	'Position',[255 260 110 70]);
frame2 = uicontrol('Style','frame',...
	'Position',[275 135 110 100]);

navlist = uicontrol('Style','listbox',...
	'Position',[10 10 250 320],...
	'String',filenames,...
	'Value',[],...
	'BackgroundColor','w',...
	'Callback',@clicknav,...
	'KeyPressFcn',@keypressnav,...
	'Max',2);

tri_up = repmat([1 1 1 1 0 1 1 1 1;1 1 1 0 0 0 1 1 1;1 1 0 0 0 0 0 1 1;...
	1 0 0 0 0 0 0 0 1],[1 1 3]);
tri_up(tri_up == 1) = NaN;
tri_down = tri_up(end:-1:1,:,:);
tri_null = NaN(4,9,3);
tri_icon = {tri_down,tri_null,tri_up};
sort_state = [1 0 0];
last_sort_state = [1 1 1];
sort_cb = zeros(1,3);
sort_cb(1) = uicontrol('Style','checkbox',...
	'Position',[15 331 70 15],...
	'String','Name',...
	'FontSize',sort_ctrl_size,...
	'Value',sort_state(1),...
	'CData',tri_icon{sort_state(1)+2},...
	'KeyPressFcn',@keypressmisc,...
	'Callback',{@sort_type,1});
sort_cb(2) = uicontrol('Style','checkbox',...
	'Position',[85 331 70 15],...
	'String','Date',...
	'FontSize',sort_ctrl_size,...
	'Value',sort_state(2),...
	'CData',tri_icon{sort_state(2)+2},...
	'KeyPressFcn',@keypressmisc,...
	'Callback',{@sort_type,2});
sort_cb(3) = uicontrol('Style','checkbox',...
	'Position',[155 331 70 15],...
	'String','Size',...
	'FontSize',sort_ctrl_size,...
	'Value',sort_state(3),...
	'CData',tri_icon{sort_state(3)+2},...
	'KeyPressFcn',@keypressmisc,...
	'Callback',{@sort_type,3});

pickslist = uicontrol('Style','listbox',...
	'Position',[380 10 350 320],...
	'String',file_picks,...
	'BackgroundColor','w',...
	'Callback',@clickpicks,...
	'KeyPressFcn',@keypresslist,...
	'Max',2,...
	'Value',[]);

openbut = uicontrol('Style','pushbutton',...
	'Position',[270 300 80 20],...
	'String','Open',...
	'Enable','off',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@open);

arrow = [ ...
	'        1   ';
	'        10  ';
	'         10 ';
	'000000000000';
	'         10 ';
	'        10  ';
	'        1   '];
cmap = NaN(128,3);
cmap(double('10'),:) = [0.5 0.5 0.5;0 0 0];
arrow_im = NaN(7,76,3);
arrow_im(:,45:56,:) = ind2rgb(double(arrow),cmap);
addbut = uicontrol('Style','pushbutton',...
	'Position',[270 270 80 20],...
	'String','Add    ',...
	'Enable','off',...
	'CData',arrow_im,...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@add);

removebut = uicontrol('Style','pushbutton',...
	'Position',[290 205 80 20],...
	'String','Remove',...
	'Enable','off',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@remove);
moveupbut = uicontrol('Style','pushbutton',...
	'Position',[290 175 80 20],...
	'String','Move Up',...
	'Enable','off',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@moveup);
movedownbut = uicontrol('Style','pushbutton',...
	'Position',[290 145 80 20],...
	'String','Move Down',...
	'Enable','off',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@movedown);

dir_popup = uicontrol('Style','popupmenu',...
	'Position',[10 350 225 20],...
	'BackgroundColor','w',...
	'String',path_cell,...
	'Value',length(path_cell),...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@dirpopup);

uparrow = [ ...
	'  0     ';
	' 000    ';
	'00000   ';
	'  0     ';
	'  0     ';
	'  0     ';
	'  000000'];
cmap = NaN(128,3);
cmap(double('0'),:) = [0 0 0];
uparrow_im = ind2rgb(double(uparrow),cmap);
up_dir_but = uicontrol('Style','pushbutton',...
	'Position',[240 350 20 20],...
	'CData',uparrow_im,...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@dir_up_one,...
	'ToolTip','Go to parent folder');
if length(path_cell) > 1
	set(up_dir_but','Enable','on')
else
	set(up_dir_but','Enable','off')
end

hist_cm = uicontextmenu;
pathbox = uicontrol('Style','edit',...
	'Position',[10 375 250 26],...
	'BackgroundColor','w',...
	'String',current_dir,...
	'HorizontalAlignment','left',...
	'TooltipString',[action,' to display folder history'],...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@change_path,...
	'UIContextMenu',hist_cm);
label1 = uicontrol('Style','text',...
	'Position',[10 401 250 16],...
	'String','Current Folder',...
	'HorizontalAlignment','center',...
	'TooltipString',[action,' to display folder history'],...
	'UIContextMenu',hist_cm);
hist_menus = [];
make_history_cm()

label2 = uicontrol('Style','text',...
	'Position',[10 440+36 80 17],...
	'String','File Filter',...
	'HorizontalAlignment','left');
label3 = uicontrol('Style','text',...
	'Position',[100 440+36 160 17],...
	'String','Reg. Exp. Filter',...
	'HorizontalAlignment','left');
showallfiles = uicontrol('Style','checkbox',...
	'Position',[270 420+32 110 20],...
	'String','Show All Files',...
	'Value',0,...
	'HorizontalAlignment','left',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@togglefilter);
refilterdirs = uicontrol('Style','checkbox',...
	'Position',[270 420+10 100 20],...
	'String','RE Filter Dirs',...
	'Value',prop.redirs,...
	'HorizontalAlignment','left',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@toggle_refiltdirs);
filter_ed = uicontrol('Style','edit',...
	'Position',[10 420+30 80 26],...
	'BackgroundColor','w',...
	'String',filter,...
	'HorizontalAlignment','left',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@setfilspec);
refilter_ed = uicontrol('Style','edit',...
	'Position',[100 420+30 160 26],...
	'BackgroundColor','w',...
	'String',re_filter,...
	'HorizontalAlignment','left',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@setrefilter);

type_value = 1;
type_popup = uicontrol('Style','popupmenu',...
	'Position',[10 422 250 20],...
	'String','',...
	'BackgroundColor','w',...
	'Value',type_value,...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@filter_type_callback,...
	'Visible','off');
if ~isempty(prop.type)
	set(filter_ed,'String',prop.type{type_value,1})
	setfilspec()
	set(type_popup,'String',prop.type(:,2),'Visible','on')
end

viewfullpath = uicontrol('Style','checkbox',...
	'Position',[380 335 230 20],...
	'String','Show full paths',...
	'Value',show_full_path,...
	'HorizontalAlignment','left',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@showfullpath);
remove_dupes = uicontrol('Style','checkbox',...
	'Position',[380 360 280 20],...
	'String','Remove duplicates (as per full path)',...
	'Value',nodupes,...
	'HorizontalAlignment','left',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@removedupes);
recall_button = uicontrol('Style','pushbutton',...
	'Position',[665 335 65 20],...
	'String','Recall',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@recall,...
	'ToolTip','Add previously selected items');
label4 = uicontrol('Style','text',...
	'Position',[380 405 350 20],...
	'String','Selected Items',...
	'HorizontalAlignment','center');
done_button = uicontrol('Style','pushbutton',...
	'Position',[280 80 80 30],...
	'String','Done',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@done);
cancel_button = uicontrol('Style','pushbutton',...
	'Position',[280 30 80 30],...
	'String','Cancel',...
	'KeyPressFcn',@keypressmisc,...
	'Callback',@cancel);

% If necessary, add warning about number of items to be selected.
num_files_warn = uicontrol('Style','text',...
	'Position',[380 385 350 16],...
	'String',numstr,...
	'ForegroundColor',[0.8 0 0],...
	'HorizontalAlignment','center',...
	'Visible','off');
if ~isempty(prop.numfiles)
	set(num_files_warn,'Visible','on')
end

resize()
% Make figure visible and hide handle.
set(fig,'HandleVisibility','off',...
	'Visible','on',...
	'ResizeFcn',@resize)

% Wait until figure is closed.
uiwait(fig)

% Compute desired output.
switch prop.output
	case 'cell'
		out = full_file_picks;
	case 'struct'
		out = dir_picks(:);
	case 'char'
		out = char(full_file_picks);
	case 'cancel'
		out = 0;
end

% Update history preference.
setpref('uipickfiles','history',history)
if ~isempty(full_file_picks) && ~strcmp(prop.output,'cancel')
	setpref('uipickfiles','full_file_picks',full_file_picks)
end

% Update figure position preference.
setpref('uipickfiles','figure_position',fig_pos)


% ----------------- Callback nested functions ----------------

	function add(varargin)
		values = get(navlist,'Value');
		for i = 1:length(values)
			dir_pick = fdir(values(i));
			pick = dir_pick.name;
			pick_full = fullfile(current_dir,pick);
			dir_pick.name = pick_full;
			if ~nodupes || ~any(strcmp(full_file_picks,pick_full))
				file_picks{end + 1} = pick; %#ok<AGROW>
				full_file_picks{end + 1} = pick_full; %#ok<AGROW>
				dir_picks(end + 1) = dir_pick; %#ok<AGROW>
			end
		end
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',[]);
		else
			set(pickslist,'String',file_picks,'Value',[]);
		end
		set([removebut,moveupbut,movedownbut],'Enable','off');
	end

	function remove(varargin)
		values = get(pickslist,'Value');
		file_picks(values) = [];
		full_file_picks(values) = [];
		dir_picks(values) = [];
		top = get(pickslist,'ListboxTop');
		num_above_top = sum(values < top);
		top = top - num_above_top;
		num_picks = length(file_picks);
		new_value = min(min(values) - num_above_top,num_picks);
		if num_picks == 0
			new_value = [];
			set([removebut,moveupbut,movedownbut],'Enable','off')
		end
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',new_value,...
				'ListboxTop',top)
		else
			set(pickslist,'String',file_picks,'Value',new_value,...
				'ListboxTop',top)
		end
	end

	function open(varargin)
		values = get(navlist,'Value');
		if fdir(values).isdir
			set(fig,'pointer','watch')
			drawnow
			current_dir = fullfile(current_dir,fdir(values).name);
			history = update_history(history,current_dir,now,history_size);
			make_history_cm()
			full_filter = fullfile(current_dir,filter);
			path_cell = path2cell(current_dir);
			fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
				@(x)file_sort(x,sort_state));
			filenames = {fdir.name}';
			filenames = annotate_file_names(filenames,fdir,fsdata);
			set(dir_popup,'String',path_cell,'Value',length(path_cell))
			if length(path_cell) > 1
				set(up_dir_but','Enable','on')
			else
				set(up_dir_but','Enable','off')
			end
			set(pathbox,'String',current_dir)
			set(navlist,'ListboxTop',1,'Value',[],'String',filenames)
			set(addbut,'Enable','off')
			set(openbut,'Enable','off')
			set(fig,'pointer','arrow')
		end
	end

	function clicknav(varargin)
		value = get(navlist,'Value');
		nval = length(value);
		dbl_click_fcn = @add;
		switch nval
			case 0
				set([addbut,openbut],'Enable','off')
			case 1
				set(addbut,'Enable','on');
				if fdir(value).isdir
					set(openbut,'Enable','on')
					dbl_click_fcn = @open;
				else
					set(openbut,'Enable','off')
				end
			otherwise
				set(addbut,'Enable','on')
				set(openbut,'Enable','off')
		end
		if strcmp(get(fig,'SelectionType'),'open')
			dbl_click_fcn();
		end
	end

	function keypressmisc(h,evt) %#ok<INUSL>
		if strcmp(evt.Key,'escape') && isequal(evt.Modifier,cell(1,0))
			% Escape key means Cancel.
			cancel()
		end
	end

	function keypressnav(h,evt) %#ok<INUSL>
		if length(path_cell) > 1 && strcmp(evt.Key,'backspace') && ...
				isequal(evt.Modifier,cell(1,0))
			% Backspace means go to parent folder.
			dir_up_one()
		elseif strcmp(evt.Key,'f') && isequal(evt.Modifier,{mod_key})
			% Control-F (Command-F on Mac) means select all files.
			value = find(~[fdir.isdir]);
			set(navlist,'Value',value)
		elseif strcmp(evt.Key,'rightarrow') && ...
				isequal(evt.Modifier,cell(1,0))
			% Right arrow key means select the file.
			add()
		elseif strcmp(evt.Key,'escape') && isequal(evt.Modifier,cell(1,0))
			% Escape key means Cancel.
			cancel()
		end
	end

	function keypresslist(h,evt) %#ok<INUSL>
		if strcmp(evt.Key,'backspace') && isequal(evt.Modifier,cell(1,0))
			% Backspace means remove item from list.
			remove()
		elseif strcmp(evt.Key,'escape') && isequal(evt.Modifier,cell(1,0))
			% Escape key means Cancel.
			cancel()
		end
	end

	function clickpicks(varargin)
		value = get(pickslist,'Value');
		if isempty(value)
			set([removebut,moveupbut,movedownbut],'Enable','off')
		else
			set(removebut,'Enable','on')
			if min(value) == 1
				set(moveupbut,'Enable','off')
			else
				set(moveupbut,'Enable','on')
			end
			if max(value) == length(file_picks)
				set(movedownbut,'Enable','off')
			else
				set(movedownbut,'Enable','on')
			end
		end
		if strcmp(get(fig,'SelectionType'),'open')
			remove();
		end
	end

	function recall(varargin)
		if ispref('uipickfiles','full_file_picks')
			ffp = getpref('uipickfiles','full_file_picks');
		else
			ffp = {};
		end
		for i = 1:length(ffp)
			if exist(ffp{i},'dir') && ...
					(~nodupes || ~any(strcmp(full_file_picks,ffp{i})))
				full_file_picks{end + 1} = ffp{i}; %#ok<AGROW>
				[unused,fn,ext] = fileparts(ffp{i});
				file_picks{end + 1} = [fn,ext]; %#ok<AGROW>
				temp = dir(fullfile(ffp{i},'..'));
				if ispc || ismac
					thisdir = strcmpi({temp.name},[fn,ext]);
				else
					thisdir = strcmp({temp.name},[fn,ext]);
				end
				dir_picks(end + 1) = temp(thisdir); %#ok<AGROW>
				dir_picks(end).name = ffp{i};
			elseif exist(ffp{i},'file') && ...
					(~nodupes || ~any(strcmp(full_file_picks,ffp{i})))
				full_file_picks{end + 1} = ffp{i}; %#ok<AGROW>
				[unused,fn,ext] = fileparts(ffp{i});
				file_picks{end + 1} = [fn,ext]; %#ok<AGROW>
				dir_picks(end + 1) = dir(ffp{i}); %#ok<AGROW>
				dir_picks(end).name = ffp{i};
			end
		end
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',[]);
		else
			set(pickslist,'String',file_picks,'Value',[]);
		end
		set([removebut,moveupbut,movedownbut],'Enable','off');
	end

	function sort_type(h,evt,cb) %#ok<INUSL>
		if sort_state(cb)
			sort_state(cb) = -sort_state(cb);
			last_sort_state(cb) = sort_state(cb);
		else
			sort_state = zeros(1,3);
			sort_state(cb) = last_sort_state(cb);
		end
		set(sort_cb,{'CData'},tri_icon(sort_state + 2)')
		
		fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
				@(x)file_sort(x,sort_state));
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(openbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function dirpopup(varargin)
		value = get(dir_popup,'Value');
		container = path_cell{min(value + 1,length(path_cell))};
		path_cell = path_cell(1:value);
		set(fig,'pointer','watch')
		drawnow
		if ispc && value == 1
			current_dir = '';
			full_filter = filter;
			drives = getdrives(network_volumes);
			num_drives = length(drives);
			temp = tempname;
			mkdir(temp)
			dir_temp = dir(temp);
			rmdir(temp)
			fdir = repmat(dir_temp(1),num_drives,1);
			[fdir.name] = deal(drives{:});
		else
			current_dir = cell2path(path_cell);
			history = update_history(history,current_dir,now,history_size);
			make_history_cm()
			full_filter = fullfile(current_dir,filter);
			fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
				@(x)file_sort(x,sort_state));
		end
		filenames = {fdir.name}';
		selected = find(strcmp(filenames,container));
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'String',filenames,'Value',selected)
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function dir_up_one(varargin)
		value = length(path_cell) - 1;
		container = path_cell{value + 1};
		path_cell = path_cell(1:value);
		set(fig,'pointer','watch')
		drawnow
		if ispc && value == 1
			current_dir = '';
			full_filter = filter;
			drives = getdrives(network_volumes);
			num_drives = length(drives);
			temp = tempname;
			mkdir(temp)
			dir_temp = dir(temp);
			rmdir(temp)
			fdir = repmat(dir_temp(1),num_drives,1);
			[fdir.name] = deal(drives{:});
		else
			current_dir = cell2path(path_cell);
			history = update_history(history,current_dir,now,history_size);
			make_history_cm()
			full_filter = fullfile(current_dir,filter);
			fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
				@(x)file_sort(x,sort_state));
		end
		filenames = {fdir.name}';
		selected = find(strcmp(filenames,container));
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'String',filenames,'Value',selected)
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function change_path(varargin)
		set(fig,'pointer','watch')
		drawnow
		proposed_path = get(pathbox,'String');
		% Process any folders named '..'.
		proposed_path_cell = path2cell(proposed_path);
		ddots = strcmp(proposed_path_cell,'..');
		ddots(find(ddots) - 1) = true;
		proposed_path_cell(ddots) = [];
		proposed_path = cell2path(proposed_path_cell);
		% Check for existance of folder.
		if ~exist(proposed_path,'dir')
			set(fig,'pointer','arrow')
			uiwait(errordlg(['Folder "',proposed_path,...
				'" does not exist.'],'','modal'))
			return
		end
		current_dir = proposed_path;
		history = update_history(history,current_dir,now,history_size);
		make_history_cm()
		full_filter = fullfile(current_dir,filter);
		[path_cell,new_network_vol] = path2cell(current_dir);
		if exist(new_network_vol,'dir')
			network_volumes = unique([network_volumes,{new_network_vol}]);
		end
		fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
				@(x)file_sort(x,sort_state));
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(openbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function showfullpath(varargin)
		show_full_path = get(viewfullpath,'Value');
		if show_full_path
			set(pickslist,'String',full_file_picks)
		else
			set(pickslist,'String',file_picks)
		end
	end

	function removedupes(varargin)
		nodupes = get(remove_dupes,'Value');
		if nodupes
			num_picks = length(full_file_picks);
			[unused,rev_order] = unique(full_file_picks(end:-1:1)); %#ok<SETNU>
			order = sort(num_picks + 1 - rev_order);
			full_file_picks = full_file_picks(order);
			file_picks = file_picks(order);
			dir_picks = dir_picks(order);
			if show_full_path
				set(pickslist,'String',full_file_picks,'Value',[])
			else
				set(pickslist,'String',file_picks,'Value',[])
			end
			set([removebut,moveupbut,movedownbut],'Enable','off')
		end
	end

	function moveup(varargin)
		value = get(pickslist,'Value');
		set(removebut,'Enable','on')
		n = length(file_picks);
		omega = 1:n;
		index = zeros(1,n);
		index(value - 1) = omega(value);
		index(setdiff(omega,value - 1)) = omega(setdiff(omega,value));
		file_picks = file_picks(index);
		full_file_picks = full_file_picks(index);
		dir_picks = dir_picks(index);
		value = value - 1;
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',value)
		else
			set(pickslist,'String',file_picks,'Value',value)
		end
		if min(value) == 1
			set(moveupbut,'Enable','off')
		end
		set(movedownbut,'Enable','on')
	end

	function movedown(varargin)
		value = get(pickslist,'Value');
		set(removebut,'Enable','on')
		n = length(file_picks);
		omega = 1:n;
		index = zeros(1,n);
		index(value + 1) = omega(value);
		index(setdiff(omega,value + 1)) = omega(setdiff(omega,value));
		file_picks = file_picks(index);
		full_file_picks = full_file_picks(index);
		dir_picks = dir_picks(index);
		value = value + 1;
		if show_full_path
			set(pickslist,'String',full_file_picks,'Value',value)
		else
			set(pickslist,'String',file_picks,'Value',value)
		end
		if max(value) == n
			set(movedownbut,'Enable','off')
		end
		set(moveupbut,'Enable','on')
	end

	function togglefilter(varargin)
		set(fig,'pointer','watch')
		drawnow
		value = get(showallfiles,'Value');
		if value
			filter = '*';
			re_filter = '';
			set([filter_ed,refilter_ed],'Enable','off')
		else
			filter = get(filter_ed,'String');
			re_filter = get(refilter_ed,'String');
			set([filter_ed,refilter_ed],'Enable','on')
		end
		full_filter = fullfile(current_dir,filter);
		fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
				@(x)file_sort(x,sort_state));
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function toggle_refiltdirs(varargin)
		set(fig,'pointer','watch')
		drawnow
		value = get(refilterdirs,'Value');
		prop.redirs = value;
		full_filter = fullfile(current_dir,filter);
		fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
				@(x)file_sort(x,sort_state));
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function setfilspec(varargin)
		set(fig,'pointer','watch')
		drawnow
		filter = get(filter_ed,'String');
		if isempty(filter)
			filter = '*';
			set(filter_ed,'String',filter)
		end
		% Process file spec if a subdirectory was included.
		[p,f,e] = fileparts(filter);
		if ~isempty(p)
			newpath = fullfile(current_dir,p,'');
			set(pathbox,'String',newpath)
			filter = [f,e];
			if isempty(filter)
				filter = '*';
			end
			set(filter_ed,'String',filter)
			change_path();
		end
		full_filter = fullfile(current_dir,filter);
		fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
				@(x)file_sort(x,sort_state));
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function setrefilter(varargin)
		set(fig,'pointer','watch')
		drawnow
		re_filter = get(refilter_ed,'String');
		fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
				@(x)file_sort(x,sort_state));
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(navlist,'String',filenames,'Value',[])
		set(addbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function filter_type_callback(varargin)
		type_value = get(type_popup,'Value');
		set(filter_ed,'String',prop.type{type_value,1})
		setfilspec()
	end

	function done(varargin)
		% Optional shortcut: click on a file and press 'Done'.
% 		if isempty(full_file_picks) && strcmp(get(addbut,'Enable'),'on')
% 			add();
% 		end
		numfiles = length(full_file_picks);
		if ~isempty(prop.numfiles)
			if numfiles < prop.numfiles(1)
				msg = {'Too few items selected.',numstr};
				uiwait(errordlg(msg,'','modal'))
				return
			elseif numfiles > prop.numfiles(end)
				msg = {'Too many items selected.',numstr};
				uiwait(errordlg(msg,'','modal'))
				return
			end
		end
		fig_pos = get(fig,'Position');
		delete(fig)
	end

	function cancel(varargin)
		prop.output = 'cancel';
		fig_pos = get(fig,'Position');
		delete(fig)
	end

	function history_cb(varargin)
		set(fig,'pointer','watch')
		drawnow
		current_dir = history(varargin{3}).name;
		history = update_history(history,current_dir,now,history_size);
		make_history_cm()
		full_filter = fullfile(current_dir,filter);
		path_cell = path2cell(current_dir);
		fdir = filtered_dir(full_filter,re_filter,prop.redirs,...
				@(x)file_sort(x,sort_state));
		filenames = {fdir.name}';
		filenames = annotate_file_names(filenames,fdir,fsdata);
		set(dir_popup,'String',path_cell,'Value',length(path_cell))
		if length(path_cell) > 1
			set(up_dir_but','Enable','on')
		else
			set(up_dir_but','Enable','off')
		end
		set(pathbox,'String',current_dir)
		set(navlist,'ListboxTop',1,'Value',[],'String',filenames)
		set(addbut,'Enable','off')
		set(openbut,'Enable','off')
		set(fig,'pointer','arrow')
	end

	function clear_history(varargin)
		history = update_history(history(1),'',[],history_size);
		make_history_cm()
	end

	function set_history_size(varargin)
		result_cell = inputdlg('Number of Recent Folders:','',1,...
			{sprintf('%g',history_size)});
		if isempty(result_cell)
			return
		end
		result = sscanf(result_cell{1},'%f');
		if isempty(result) || result < 1
			return
		end
		history_size = result;
		history = update_history(history,'',[],history_size);
		make_history_cm()
		setpref('uipickfiles','history_size',history_size)
	end

	function resize(varargin)
		% Get current figure size.
		P = 'Position';
		pos = get(fig,P);
		w = pos(3); % figure width in pixels
		h = pos(4); % figure height in pixels
		
		% Enforce minimum figure size.
		w = max(w,564);
		h = max(h,443);
		if any(pos(3:4) < [w h])
			pos(3:4) = [w h];
			set(fig,P,pos)
		end
		
		% Change positions of all uicontrols based on the current figure
		% width and height.
		navw_pckw = round([1 1;-350 250]\[w-140;0]);
		navw = navw_pckw(1);
		pckw = navw_pckw(2);
		navp = [10 10 navw h-174];
		pckp = [w-10-pckw 10 pckw h-174];
		set(navlist,P,navp)
		set(pickslist,P,pckp)
		
		set(frame1,P,[navw+5 h-234 110 70])
		set(openbut,P,[navw+20 h-194 80 20])
		set(addbut,P,[navw+20 h-224 80 20])
		
		frame2y = round((h-234 + 110 - 100)/2);
		set(frame2,P,[w-pckw-115 frame2y 110 100])
		set(removebut,P,[w-pckw-100 frame2y+70 80 20])
		set(moveupbut,P,[w-pckw-100 frame2y+40 80 20])
		set(movedownbut,P,[w-pckw-100 frame2y+10 80 20])
		
		set(done_button,P,[navw+30 80 80 30])
		set(cancel_button,P,[navw+30 30 80 30])
		
		set(sort_cb(1),P,[15 h-163 70 15])
		set(sort_cb(2),P,[85 h-163 70 15])
		set(sort_cb(3),P,[155 h-163 70 15])
		
		set(dir_popup,P,[10 h-144 navw-25 20])
		set(up_dir_but,P,[navw-10 h-144 20 20])
		set(pathbox,P,[10 h-119 navw 26])
		set(label1,P,[10 h-93 navw 16])
		
		set(viewfullpath,P,[pckp(1) h-159 230 20])
		set(remove_dupes,P,[pckp(1) h-134 280 20])
		set(recall_button,P,[w-75 h-159 65 20])
		set(label4,P,[w-10-pckw h-89 pckw 20])
		set(num_files_warn,P,[w-10-pckw h-109 pckw 16])
		
		set(label2,P,[10 h-18 80 17])
		set(label3,P,[100 h-18 160 17])
		set(showallfiles,P,[270 h-42 110 20])
		set(refilterdirs,P,[270 h-64 100 20])
		set(filter_ed,P,[10 h-44 80 26])
		set(refilter_ed,P,[100 h-44 160 26])
		set(type_popup,P,[10 h-72 250 20])
	end

	function reset_figure_size(varargin)
		if strcmp(get(fig,'SelectionType'),'open')
			root_units = get(0,'units');
			screen_size = get(0,'ScreenSize');
			set(0,'Units',root_units)
			hw = [740 494];
			pos = [round((screen_size(3:4) - hw - [0 26])/2),hw];
			set(fig,'Position',pos)
			resize()
		end
	end



% ------------------ Other nested functions ------------------

	function make_history_cm
		% Make context menu for history.
		if ~isempty(hist_menus)
			delete(hist_menus)
		end
		num_hist = length(history);
		hist_menus = zeros(1,num_hist+2);
		for i = 1:num_hist
			hist_menus(i) = uimenu(hist_cm,'Label',history(i).name,...
				'Callback',{@history_cb,i});
		end
		hist_menus(num_hist+1) = uimenu(hist_cm,...
			'Label','Clear Menu',...
			'Separator','on',...
			'Callback',@clear_history);
		hist_menus(num_hist+2) = uimenu(hist_cm,'Label',...
			sprintf('Set Number of Recent Folders (%d) ...',history_size),...
			'Callback',@set_history_size);
	end

end


% -------------------- Subfunctions --------------------

function [c,network_vol] = path2cell(p)
% Turns a path string into a cell array of path elements.
if ispc
	p = strrep(p,'/','\');
	c1 = regexp(p,'(^\\\\[^\\]+\\[^\\]+)|(^[A-Za-z]+:)|[^\\]+','match');
	vol = c1{1};
	c = [{'My Computer'};c1(:)];
	if strncmp(vol,'\\',2)
		network_vol = vol;
	else
		network_vol = '';
	end
else
	c = textscan(p,'%s','delimiter','/');
	c = [{filesep};c{1}(2:end)];
	network_vol = '';
end
end

% --------------------

function p = cell2path(c)
% Turns a cell array of path elements into a path string.
if ispc
	p = fullfile(c{2:end},'');
else
	p = fullfile(c{:},'');
end
end

% --------------------

function d = filtered_dir(full_filter,re_filter,filter_both,sort_fcn)
% Like dir, but applies filters and sorting.
p = fileparts(full_filter);
if isempty(p) && full_filter(1) == '/'
	p = '/';
end
if exist(full_filter,'dir')
	dfiles = dir(' ');
else
	dfiles = dir(full_filter);
end
if ~isempty(dfiles)
	dfiles([dfiles.isdir]) = [];
end

ddir = dir(p);
ddir = ddir([ddir.isdir]);
[unused,index0] = sort(lower({ddir.name})); %#ok<ASGLU>
ddir = ddir(index0);
ddir(strcmp({ddir.name},'.') | strcmp({ddir.name},'..')) = [];

% Additional regular expression filter.
if nargin > 1 && ~isempty(re_filter)
	if ispc || ismac
		no_match = cellfun('isempty',regexpi({dfiles.name},re_filter));
	else
		no_match = cellfun('isempty',regexp({dfiles.name},re_filter));
	end
	dfiles(no_match) = [];
end
if filter_both
	if nargin > 1 && ~isempty(re_filter)
		if ispc || ismac
			no_match = cellfun('isempty',regexpi({ddir.name},re_filter));
		else
			no_match = cellfun('isempty',regexp({ddir.name},re_filter));
		end
		ddir(no_match) = [];
	end
end
% Set navigator style:
%	1 => list all folders before all files, case-insensitive sorting
%	2 => mix files and folders, case-insensitive sorting
%	3 => list all folders before all files, case-sensitive sorting
nav_style = 1;
switch nav_style
	case 1
		[unused,index1] = sort_fcn(dfiles); %#ok<ASGLU>
		[unused,index2] = sort_fcn(ddir); %#ok<ASGLU>
		d = [ddir(index2);dfiles(index1)];
	case 2
		d = [dfiles;ddir];
		[unused,index] = sort(lower({d.name})); %#ok<ASGLU>
		d = d(index);
	case 3
		[unused,index1] = sort({dfiles.name}); %#ok<ASGLU>
		[unused,index2] = sort({ddir.name}); %#ok<ASGLU>
		d = [ddir(index2);dfiles(index1)];
end
end

% --------------------

function [files_sorted,index] = file_sort(files,sort_state)
switch find(sort_state)
	case 1
		[files_sorted,index] = sort(lower({files.name}));
		if sort_state(1) < 0
			files_sorted = files_sorted(end:-1:1);
			index = index(end:-1:1);
		end
	case 2
		if sort_state(2) > 0
			[files_sorted,index] = sort([files.datenum]);
		else
			[files_sorted,index] = sort([files.datenum],'descend');
		end
	case 3
		if sort_state(3) > 0
			[files_sorted,index] = sort([files.bytes]);
		else
			[files_sorted,index] = sort([files.bytes],'descend');
		end
end
end

% --------------------

function drives = getdrives(other_drives)
% Returns a cell array of drive names on Windows.
letters = char('A':'Z');
num_letters = length(letters);
drives = cell(1,num_letters);
for i = 1:num_letters
	if exist([letters(i),':\'],'dir');
		drives{i} = [letters(i),':'];
	end
end
drives(cellfun('isempty',drives)) = [];
if nargin > 0 && iscellstr(other_drives)
	drives = [drives,unique(other_drives)];
end
end

% --------------------

function filenames = annotate_file_names(filenames,dir_listing,fsdata)
% Adds a trailing filesep character to folder names and, optionally,
% prepends a folder icon or bullet symbol.
for i = 1:length(filenames)
	if dir_listing(i).isdir
		filenames{i} = sprintf('%s%s%s%s',fsdata.pre,filenames{i},...
			fsdata.filesep,fsdata.post);
	end
end
end

% --------------------

function history = update_history(history,current_dir,time,history_size)
if ~isempty(current_dir)
	% Insert or move current_dir to the top of the history.
	% If current_dir already appears in the history list, delete it.
	match = strcmp({history.name},current_dir);
	history(match) = [];
	% Prepend history with (current_dir,time).
	history = [struct('name',current_dir,'time',time),history];
end
% Trim history to keep at most <history_size> newest entries.
history = history(1:min(history_size,end));
end

% --------------------

function success = generate_folder_icon(icon_path)
% Black = 1, manila color = 2, transparent = 3.
im = [ ...
	3 3 3 1 1 1 1 3 3 3 3 3;
	3 3 1 2 2 2 2 1 3 3 3 3;
	3 1 1 1 1 1 1 1 1 1 1 3;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 2 2 2 2 2 2 2 2 2 2 1;
	1 1 1 1 1 1 1 1 1 1 1 1];
cmap = [0 0 0;255 220 130;255 255 255]/255;
fid = fopen(icon_path,'w');
if fid > 0
	fclose(fid);
	imwrite(im,cmap,icon_path,'Transparency',[1 1 0])
end
success = exist(icon_path,'file');
end

% --------------------

function fsdata = set_folder_style(folder_style_pref)
% Set style to preference.
fsdata.style = folder_style_pref;
% If style = 1, check to make sure icon image file exists.  If it doesn't,
% try to create it.  If that fails set style = 2.
if fsdata.style == 1
	icon_path = fullfile(prefdir,'uipickfiles_folder_icon.png');
	if ~exist(icon_path,'file')
		success = generate_folder_icon(icon_path);
		if ~success
			fsdata.style = 2;
		end
	end
end
% Set pre and post fields.
if fsdata.style == 1
	icon_url = ['file://localhost/',...
		strrep(strrep(icon_path,':','|'),'\','/')];
	fsdata.pre = sprintf('<html><img src="%s">&nbsp;',icon_url);
	fsdata.post = '</html>';
elseif fsdata.style == 2
	fsdata.pre = '<html><b>&#8226;</b>&nbsp;';
	fsdata.post = '</html>';
elseif fsdata.style == 3
	fsdata.pre = '';
	fsdata.post = '';
end
fsdata.filesep = filesep;

end

% --------------------

function prop = parsepropval(prop,varargin)
% Parse property/value pairs and return a structure.
properties = fieldnames(prop);
arg_index = 1;
while arg_index <= length(varargin)
	arg = varargin{arg_index};
	if ischar(arg)
		prop_index = match_property(arg,properties);
		prop.(properties{prop_index}) = varargin{arg_index + 1};
		arg_index = arg_index + 2;
	elseif isstruct(arg)
		arg_fn = fieldnames(arg);
		for i = 1:length(arg_fn)
			prop_index = match_property(arg_fn{i},properties);
			prop.(properties{prop_index}) = arg.(arg_fn{i});
		end
		arg_index = arg_index + 1;
	else
		error(['Properties must be specified by property/value pairs',...
			' or structures.'])
	end
end
end

% --------------------

function prop_index = match_property(arg,properties)
% Utility function for parsepropval.
prop_index = find(strcmpi(arg,properties));
if isempty(prop_index)
	prop_index = find(strncmpi(arg,properties,length(arg)));
end
if length(prop_index) ~= 1
	error('Property ''%s'' does not exist or is ambiguous.',arg)
end
end
