function convertMovieDirectory(inDir,outDir)


if nargin < 2
    tic;
    if nargin < 1
        inDir=uigetdir();
    end
    [parentDir,subDir]=fileparts(inDir);
    outDir=[parentDir,filesep,subDir,'_SEQs'];
    outDir=regexprep(outDir,' ','_');
end

if ~exist(outDir,'dir')
    mkdir(outDir);
end



movieExts={'.mp4','.avi','.wmv','.mpeg','.mpg'};

isMovie=@(x) ismember(x,movieExts);

d=dir(inDir);

dNames={d(:).name}';
dDirInds=[d(:).isdir]';

dDirNames=dNames(dDirInds);
dDirNames=setdiff(dDirNames,{'.','..'});
dFileNames=dNames(~dDirInds);

[~,dFileRoots,dFileExts]=cellfun(@fileparts,dFileNames,'UniformOutput',false);

dMovieFileInds=cellfun(isMovie,dFileExts);

dMovieRoots=dFileRoots(dMovieFileInds);
dMovieExts=dFileExts(dMovieFileInds);

inFileNames=strcat(inDir,filesep,dMovieRoots,dMovieExts);
outFileNames=strcat(outDir,filesep,dMovieRoots,'.seq');

timeOld=toc;
if ~isempty(inFileNames)
    for k=1:length(inFileNames)
        inFileName=inFileNames{k};%[inDir,filesep,dMovieRoots,dMovieExts];
        outFileName=outFileNames{k};%[outDir,filesep,dMovieRoots,'.seq'];
        if ~exist(outFileName,'file')
            disp(inFileName)
            disp(outFileName)
            disp('...')
            vid_convert(inFileName,outFileName,'seq');
            timeNew=toc;
            disp(['Done after ',num2str(timeNew-timeOld),' seconds.'])
            timeOld=timeNew;
            disp(' ')
        end
    end
end


if ~isempty(dDirInds)
    for k=1:length(dDirNames)
        newInDir=[inDir,filesep,dDirNames{k}];
        newOutDir=[outDir,filesep,dDirNames{k}];
        convertMovieDirectory(newInDir,newOutDir);
    end
end


if nargin < 2
    timeNew=toc;
    disp(['All files finished after ',num2str(timeNew),' seconds.'])
end