[fileName, pathName]=uigetfile('*.txt');
inFile=[pathName, fileName];

annText=textread(inFile,'%s');
commandStartInd=find(strcmpi(annText,'file:'))+1;
commandEndInd=find(strcmpi(annText,'S1:'))-1;
    commandInds=commandStartInd:commandEndInd;
    commandList=annText; 
    commandList=commandList(commandInds);
    commandList=reshape(commandList,[2,length(commandInds)/2])';
    
    %Search lines after for pattern: '\d+', '\d+', '\w+' 
    
    emptyOrNan=@(x) isempty(x)||isnan(x);
    checkPattern=@(listToCheck, indsToCheck, patternToSeek)...
        all(patternToSeek==cellfun(emptyOrNan,...
        cellfun(@str2double,...
        listToCheck(indsToCheck),'UniformOutput',false)));
    
    soughtPattern=[false;false;true]; %We want number, number, non-number to know we are in the right place to get actual annotations

    annotationInds=(commandEndInd):(commandEndInd+2);
    patternMatch=checkPattern(annText,annotationInds,soughtPattern);
    
    while ~patternMatch
        annotationInds=annotationInds+1;
        patternMatch=checkPattern(annText,annotationInds,soughtPattern);
    end
    
    firstAnnotationStartInd=annotationInds(1);
    firstAnnotationEndInd=find(strcmpi(annText,'S2:'))-1;
    firstAnnotationInds=firstAnnotationStartInd:firstAnnotationEndInd;
    
    annotationInds=(firstAnnotationEndInd+1):(firstAnnotationEndInd+3);
    patternMatch=checkPattern(annText,annotationInds,soughtPattern);
    while ~patternMatch
        annotationInds=annotationInds+1;
        patternMatch=checkPattern(annText,annotationInds,soughtPattern);
    end
    secondAnnotationStartInd=annotationInds(1);
    secondAnnotationEndInd=length(annText);
        
    %Make sure nothing extra was appended to file:
    annotationInds=(secondAnnotationEndInd-2):(secondAnnotationEndInd);
    patternMatch=checkPattern(annText,annotationInds,soughtPattern);
    while ~patternMatch
        annotationInds=annotationInds-1;
        patternMatch=checkPattern(annText,annotationInds,soughtPattern);
    end
    
    secondAnnotationEndInd=annotationInds(end);%length(annText);
    secondAnnotationInds=secondAnnotationStartInd:secondAnnotationEndInd;
	
    ann1=annText(firstAnnotationInds);
    ann2=annText(secondAnnotationInds);
    
    annotations1=[ann1(3:3:(end)),ann1(1:3:(end-2)),ann1(2:3:(end-1))];
    annotations2=[ann2(3:3:(end)),ann2(1:3:(end-2)),ann2(2:3:(end-1))];
    
    [annotations1(:,2:3)]=cellfun(@str2double,annotations1(:,2:3),'UniformOutput',false);
    [annotations2(:,2:3)]=cellfun(@str2double,annotations2(:,2:3),'UniformOutput',false);
    ann1=annotations1;
    ann2=annotations2;
    
    
    
    %Keep extraneous variables from cluttering workspace even more
    clear annotations1 annotations2 annText annotationInds firstAnnotationInds secondAnnotationInds;
    clear firstAnnotationStartInd firstAnnotationEndInd secondAnnotationStartInd secondAnnotationEndInd;
    clear commandStartInd commandEndInd commandInds
    clear soughtPattern patternMatch emptyOrNan checkPattern
    
% startFrames1=cell2mat(annotations1(:,2));
% lastFrames1=cell2mat(annotations1(:,3));
% startFrames2=cell2mat(annotations2(:,2));
% lastFrames2=cell2mat(annotations2(:,3));
    
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
