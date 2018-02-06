function [x,fly,timeStamp,touchFrame,touchFlyIds,movie,bg,numberOfFlies,flag,success,track_points,track_angles,track_maj_axis,track_min_axis,track_area,track_ecc,n_tracks,n_frames] = flyTracker(varargin)

%%
%   flyTracker segments and estimate the number of interacting fly in a single 
%   blob for a given .mkv video format. 
%   [x,fly,timeStamp,touchFrame,touchFlyIds] = flyTracker 
%   uses Hungarian Algorithm to estimate the number of interacting flies in
%   a single blob.
%
%   X is the object which contains the video information.
%   FLY is the structure which contains the feature of each fly in a
%   frame. eg Length of Major Axis, Length of Minor axis, Area of a fly etc.  
%   TIMESTAMP is the corresponding time stamps of each frame.
%   TOUCHFRAME is the frame numbers where touches have been detected. These
%   touches are detected only in those frames, where GMM has been called.
%   TOUCHFLYIDS is the ids of touching flies in touchFrame.
%   NUMBEROFFLIES is an array which contains the number of flies in each
%   frame.
%   SUCCESS returns either 1 or 1. 1 indicates success; all the frame
%   contains same number of flies. 0 indictaes that unsuccessfull result.
%   The number of flies in each frame is not constant and the segmentation
%   results are not proper.
% 
% 
%   
%   TOTAL_FLIES is the total number of flies present in the chamber.
%   VARGARIN: The OPTIONAL arguments which user can pass is the full path 
%   name where user wants to store its analysis results and an indicator if
%   user wants to see the results of segemntation for each frame. An indicator 1 
%   determines if user wants to see the results simulataneously while a 0
%   determines if user does not want to see the results simultaenously. An
%   indicator 1 will increase the execution time and will take loads of
%   memory as well. Its default value is 0.
%   



%   Bugs corrected ,works correctly and tested with about 15 videos


%%
prompt = {'Please enter the number of flies in the Experiment:'};
dlg_title = 'Input';
total_flies = inputdlg(prompt,dlg_title);
total_flies = cell2mat(total_flies);
total_flies = str2num(total_flies);
% if nargin < 1
%     error('myApp:argChk', 'Wrong number of input arguments!')
% end

if nargin > 1 
    analysis_path = varargin{1};
    flag = varargin{2};
%     if nargin > 3
%         analysis_path = varargin{1};
%         flag = varargin{2};
%     end
else
 flag = 0;
 analysis_path = pwd;
end
flag = 0;
   
x = ffmsReader();
[fn pn] = uigetfile('*.mkv','Select the .mkv file');
movie = strcat(pn,fn);
[res,filename] = x.open(movie,0);
[pathstr,name,ext] = fileparts(filename);

touchFlyIds = cell(x.numberOfFrames,1);

% prompt = {'Enter total number of flies:'};
% dlg_title = 'Number of flies';
% num_lines = 1;
% total_flies = inputdlg(prompt,dlg_title,num_lines);
% total_flies = cell2mat(total_flies);

%%
% Reading the filename to create the log files
% idno = find(ismember(filename,'\'));
% filename = filename(idno(end)+1:end);
% filename = strcat(filename,'.','txt');
% filename = fullfile(analysis_path,filename);
% filename = fullfile(pathstr,filename);
%fopen(filename,'w+');
%diary(filename);

%%
[bg] = backgroundmodel(x);

ts = zeros(x.numberOfFrames,1);
for i = 1: x.numberOfFrames
    [frame,timeStamp] = x.getFrame(i-1); 
    frame1 = imsubtract(bg,frame);
    ts(i) = timeStamp;
if i == 1 
     fg = frame1 > 40;
else fg = frame1 > 30;
    
end

%%
%labeling and thresholding the connected the components
% 
thresh = 2;%5
[m,n] = size(frame);
img = bwlabel(fg);
blobarea = regionprops(img,'Area');
blobarea = cat(1,blobarea.Area);
false = find(blobarea<thresh); % taking care of any false positives that occur.
blobarea(false) = [];
blobs{i} = blobarea;
img = bwareaopen(img, thresh);
blobarea = regionprops(img,'Area');
blobarea = cat(1,blobarea.Area);
flag = 0;
if flag == 1
    figure(1) % for watching continuosly the movement of each blob
    imshow(frame);
end
    

 str = sprintf(' Reading frame %d',i);
 disp(str)

[connectedFlies,number(i)] = bwlabel(img);
detectCentroid = regionprops(connectedFlies,'Area','Centroid','Eccentricity',...
    'MajorAxisLength', 'MinorAxisLength', 'Orientation','PixelList');
fly(i) = struct('features',detectCentroid);

if number(i)~= total_flies
    disp('GMM');
    
     if (total_flies - number(i) == 1)
         touchFrame(i) = i;
         flyId = find(blobarea == max(blobarea));
         k = 2;
         g{i} = flyId;
          
%           if length(flyId) > (total_flies-number(i)) % This happens when 
%               %1 fly is on floor and the other fly is on roof.Sometimes,
%               %in this case there are more than 1 fly with same area. 
%               %So it becomes difficult to understand which bob has multiple flies.
%              flyId = g{i-1};
%           end
          
         lg = length(flyId);
         c = fly(i).features(flyId(lg)).Centroid;
         options = optimset('Display','final', 'MaxIter',1000); 
%          options = statset('Display','final');            
         pixelList = [fly(i).features(flyId).PixelList];
         pixelList(:,2) = n - pixelList(:,2);
%          P = impixel(frame,pixelList(:,1),n - pixelList(:,2));
%         [nCount,nbins] = hist(P(:,1),3);
%         Pinfo = [P(:,1),pixelList(:,1),n - pixelList(:,2)];
%         Psort = sortrows(Pinfo,1);
% 
%         for wt = 1 : length(nCount)
%             PWeight{wt} = repmat(Psort(1:nCount(wt),2:end),ceil(length(nCount)/wt),1);
%         end
%  
%         PWeight = PWeight';
%         PWeight = cell2mat(PWeight);
%         [IDX,C] = kmeans(PWeight,k,'emptyaction','Singleton','options',options);
%         
%         hold on
%         plot(C(:,1),C(:,2),'y.')
        
         [IDX,C] = kmeans(pixelList,k,'Options',options);
%         imshow(Is) 
         ob = gmdistribution.fit(pixelList,k,'Options',options,'Start',IDX,...
             'Regularize',1e-5);
%          ob = gmdistribution.fit(PWeight,k,'Options',options,'Start',IDX,...
%              'Regularize',1e-5);
         
         ellipse_parameters;
             
%          [flyIdx] = ellipse_parameters(ob,k,lg,flyId,i);
%          touchFlyIds{i} = [fly(i).features(flyId).Centroid ; fly(i).features(flyIdx).Centroid];

        
     else (total_flies - number(i) > 1 )
           disp('more than 1 missing blob') ;
                 touchFrame(i) = i;
               
           tmpflies = [fly(i-1).features.Centroid];
           tmpflies = reshape(tmpflies,2,numel(fly(i-1).features));
           tmpflies = [tmpflies]';
           largeblob = [fly(i).features.Area];
           avgArea = mean(largeblob);
           flyId = find(largeblob > avgArea);%35;
           largeblobCentroid = [fly(i).features(flyId).Centroid];
           largeblobCentroid = reshape(largeblobCentroid,2,length(flyId))';
           target1 = [fly(i).features.Centroid];
           target1 = reshape(target1,2,numel(fly(i).features))';
           
          
               for  j = 1: total_flies - numel(fly(i).features)
                   target1 = [target1;largeblobCentroid];
               end
           
           
           [ target_index target_dist unassign_targets totalCost ] = hungarianlinker(tmpflies, target1);
           
                        
           for lg = 1:length(flyId)
               
               for z = 1 : length(target1(target_index, :))
                   tmp = target1(target_index, :);
                   np(z) = isequal(tmp(z,:),largeblobCentroid(lg,:));
               end
               
               np = sum(np);
               k = np(1);
               options = optimset('Display','final', 'MaxIter',1000);            
               pixelList = [fly(i).features(flyId(lg)).PixelList];
               pixelList(:,2) = n - pixelList(:,2);
%                
%                P = impixel(frame,pixelList(:,1),n-pixelList(:,2));
%                 [nCount,nbins] = hist(P(:,1),3);
%                 Pinfo = [P(:,1),pixelList(:,1),n - pixelList(:,2)];
%                 Psort = sortrows(Pinfo,1);
% 
%                 for wt = 1 : length(nCount)
%                     PWeight{wt} = repmat(Psort(1:nCount(wt),2:end),ceil(length(nCount)/wt),1);
%                 end
% 
%                 PWeight = PWeight';
%                 PWeight = cell2mat(PWeight);
%                 [IDX,C] = kmeans(PWeight,k,'emptyaction','Singleton','options',options);
%                 hold on
%                 plot(C(:,1),C(:,2),'y.')
                [IDX,C] = kmeans(pixelList,k,'Options',options);
%                 PWeight(:,2) = n - PWeight(:,2)
%              ob = gmdistribution.fit(PWeight,k,'Options',options,'Start',IDX,...
%              'Regularize',1e-5);
% 
               ob = gmdistribution.fit(pixelList,k,'options',options,...
                   'Start',IDX,'Regularize',1e-5);
               ellipse_parameters;
%                touchFlyIds{i}(lg) = touchFly;
%                [flyId,flyIdx] = ellipse_parameters(ob,k,lg,flyId,i);
%                touchFlyIds{i} = [fly(i).features(flyId).Centroid ; fly(i).features(flyIdx).Centroid];
           end
     end
touchFlyIds{i} = touchFly;
     end
numberOfFlies(i)= numel(fly(i).features);
clear PWeight

end



%Reading time stamps

timeStamp =ts;
touchFrame = [find(touchFrame~=0)]';
if (max(numberOfFlies)== total_flies & min(numberOfFlies) == total_flies)
    disp('Success')
    success = max(numberOfFlies)== total_flies & min(numberOfFlies) == total_flies;
else
    disp('Unsuccessful segmentation')
    success = max(numberOfFlies)== total_flies & min(numberOfFlies) == total_flies;
end
diary ('off');


[track_points,track_angles,track_maj_axis,track_min_axis,track_area,track_ecc,n_tracks,n_frames] = tracker(x,fly);
end