function [ bg ] = backgroundmodel( x)

%Backgroundmodel function models the background.Reads the sampled frames for background estimation and Subtraction.bg is the background image.   

j = 1;

for i = 1: 1000:x.numberOfFrames
%     k = x.getFrame(i);
    q(:,:,j) = x.getFrame(i);
    j = j+1;
end

bg = max(q,[],3);

% Filter the image with a median filter iff the background subtraction does
% not produce proper output.
%bg = medfilt2(bg,[9,9]);

end

