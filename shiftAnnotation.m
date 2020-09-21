%Number of frames to remove from beginning
framesToClip=6;

%Set to true if you want it to write a new file, and false if not.
writeToFile=true;




[fileName, pathName]=uigetfile('*.txt');
inFile=[pathName, fileName];
outFile=[inFile(1:end-4),'_',num2str(framesToClip),'_frames_clipped',inFile(end-3:end)];

fullText=fileread(inFile);
[frameList,framePointerList]=regexp(fullText,'(\d+)[(\s+)(\d+)(\s+)(\w+)]','match');
frameNums=cellfun(@str2num,frameList);
frameNums=reshape(frameNums,[2,length(frameNums)/2])';
newFrameNums=frameNums-framesToClip;

%Number of spaces to use to keep file consistent:
spaceNums=7-floor(log10(abs(newFrameNums)));

oldSpaceNums=7-floor(log10(abs(frameNums)));

numCommands=size(newFrameNums,1);
fullText2=fullText;
for i=1:numCommands
    if newFrameNums(i,2) <= 0 %Remove the line
        fullText2=regexprep(fullText2,['(\s+)',num2str(frameNums(1,1)),'(\s+)',num2str(frameNums(1,2)),'(\s+)(\w+)'],'');
    else
        if newFrameNums(i,1)<=0 %Set starting frame to 1
            newFrameNums(i,1)=1;
            spaceNums(i,1)=7;
        end
        firstFrameSpace=repmat(' ',[1,spaceNums(i,1)-oldSpaceNums(i,1)]);
        lastFrameSpace=repmat(' ',[1,spaceNums(i,2)]);
        
        fullText2=regexprep(fullText2,[num2str(frameNums(i,1)),'(\s+)',num2str(frameNums(i,2))],[firstFrameSpace,num2str(newFrameNums(i,1)),lastFrameSpace,num2str(newFrameNums(i,2))]);
        
    end
end


if writeToFile
    outFileObj=fopen(outFile,'w');
    fwrite(outFileObj,fullText2);
    fclose(outFileObj);
end


oldFrameNums=frameNums;
clear fullText fullText2 spaceNums oldSpaceNums numCommands firstFrameSpace lastFrameSpace frameList framePointerList frameNums

% 
% startFrameInds=find(frameNums(:,1)==1);
% startFrames=framePointerList(startFrameInds,1);
% stopFrames=startFrames;
% stopFrames(1)=regexp(fullText,'S2:')-1;

% wordList=regexp(fullText,'(?<=\d+\s+)([_]|[A-Z]|[a-z]+)','match')';
% frameInfo=[num2cell(frameNums),wordList];


% 
% subtractN=@(x) x-framesToClip;
% annText=textread(inFile,'%s');
% commandStartInd=find(strcmpi(annText,'file:'))+1;
% commandEndInd=find(strcmpi(annText,'S1:'))-1;
%     commandInds=commandStartInd:commandEndInd;
%     commandList=annText; 
%     commandList=commandList(commandInds);
%     commandList=reshape(commandList,[2,length(commandInds)/2])';
%     
%     %Search lines after for pattern: '\d+', '\d+', '\w+' 
%     
%     emptyOrNan=@(x) isempty(x)||isnan(x);
%     checkPattern=@(listToCheck, indsToCheck, patternToSeek)...
%         all(patternToSeek==cellfun(emptyOrNan,...
%         cellfun(@str2double,...
%         listToCheck(indsToCheck),'UniformOutput',false)));
%     
%     soughtPattern=[false;false;true]; %We want number, number, non-number to know we are in the right place to get actual annotations
% 
%     annotationInds=(commandEndInd):(commandEndInd+2);
%     patternMatch=checkPattern(annText,annotationInds,soughtPattern);
%     
%     while ~patternMatch
%         annotationInds=annotationInds+1;
%         patternMatch=checkPattern(annText,annotationInds,soughtPattern);
%     end
%     
%     firstAnnotationStartInd=annotationInds(1);
%     firstAnnotationEndInd=find(strcmpi(annText,'S2:'))-1;
%     firstAnnotationInds=firstAnnotationStartInd:firstAnnotationEndInd;
%     
%     
%     annotationInds=(firstAnnotationEndInd+1):(firstAnnotationEndInd+3);
%     patternMatch=checkPattern(annText,annotationInds,soughtPattern);
%     while ~patternMatch
%         annotationInds=annotationInds+1;
%         patternMatch=checkPattern(annText,annotationInds,soughtPattern);
%     end
%     
%     secondAnnotationStartInd=annotationInds(1);
%     secondAnnotationEndInd=length(annText);
%     secondAnnotationInds=secondAnnotationStartInd:secondAnnotationEndInd;
%     
%     %Make sure nothing extra was appended to file:
%     annotationInds=(secondAnnotationEndInd-2):(secondAnnotationEndInd);
%     patternMatch=checkPattern(annText,annotationInds,soughtPattern);
%     while ~patternMatch
%         annotationInds=annotationInds-1;
%         patternMatch=checkPattern(annText,annotationInds,soughtPattern);
%     end
%     secondAnnotationStartInd=annotationInds(1);
%     secondAnnotationEndInd=length(annText);
%     secondAnnotationInds=secondAnnotationStartInd:secondAnnotationEndInd;
% 	
%     ann1=annText(firstAnnotationInds);
%     ann2=annText(secondAnnotationInds);
%     
%     annotations1=[ann1(3:3:(end)),ann1(1:3:(end-2)),ann1(2:3:(end-1))];
%     annotations2=[ann2(3:3:(end)),ann2(1:3:(end-2)),ann2(2:3:(end-1))];
%     
%     [annotations1(:,2:3)]=cellfun(@str2double,annotations1(:,2:3),'UniformOutput',false);
%     [annotations2(:,2:3)]=cellfun(@str2double,annotations2(:,2:3),'UniformOutput',false);
% 
%     
% startFrames1=cell2mat(annotations1(:,2));
% lastFrames1=cell2mat(annotations1(:,3));
% startFrames2=cell2mat(annotations2(:,2));
% lastFrames2=cell2mat(annotations2(:,3));
%     
%     annFrames=annotations1{end,3};
%         
%     annList1=[];
%     for i=1:size(annotations1,1)
%         annCommNum=find(strcmpi(commandList(:,1),annotations1{i,1}));
%         annList1=vertcat(annList1,repmat(annCommNum,[annotations1{i,3}-annotations1{i,2}+1,1]));
%     end
%     
%     
%     annList2=[];
%     for i=1:size(annotations2,1)
%         annCommNum=find(strcmpi(commandList(:,1),annotations2{i,1}));
%         annList2=vertcat(annList2,repmat(annCommNum,[annotations2{i,3}-annotations2{i,2}+1,1]));
%     end
%     
%     
%     ignoreCommand=strcmpi(commandList(:,1),'ignore');
%     otherCommand=strcmpi(commandList(:,1),'other');
%     if any(ignoreCommand)
%         annInsertCommand=find(ignoreCommand,1,'first');
%     elseif any(otherCommand)
%         annInsertCommand=find(otherCommand ,1,'first');
%     else
%         annInsertCommand=1;
%     end
%     
