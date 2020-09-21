% open mp4 video in Matlab

vid01=VideoReader('C:\Users\ryan\Desktop\vl06_01.mp4');
figure;
while hasFrame(vid01)
vidFrame = readFrame(vid01);
image(vidFrame);
pause(1/vid.FrameRate);
end

