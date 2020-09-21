% d1 = hdf5read('F:\1st MOnly\er18 day1\concat\rescued_mosaic.h5','/Object');

d1Length=size(d1,3);
segmentSize=10000;

nSegments=ceil(d1Length/segmentSize);

for i=1:nSegments
    
    startInd=((i-1)*segmentSize+1);
    stopInd=min([(i*segmentSize),d1Length]);
    
    hdf5write(['d1Test',num2str(i),'.h5'],'/Object',d1(:,:,startInd:stopInd));
    
end

