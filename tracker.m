function [track_points,track_angles,track_maj_axis,track_min_axis,track_area,track_ecc,n_tracks,n_frames] = tracker (x,fly);

%% Track them
% Finally! A one liner. TRACKER connects all the segmented blobs in each
% with the successive frames using Hungarian algorithm. 
% [track_points,track_angles,n_tracks] = tracker (x,fly) Uses Hungarian
% algorithm to track the flies. 
% X is the object which contains the video information.
% FLY is the structure which contains the feature of each fly in a
% frame. eg Length of Major Axis, Length of Minor axis, Area of a fly etc.
% TRACK_POINTS is the cell that contains the x,y co-ordinates of tracked
% flies. 
% TRACK_ANGLES is the cell that contains the orientation of each fly in
% various frames.
% N_TRACKS is the number of tracks found. It should be equal to the number
% of flies present in the chamber.

% Bugs corrected
% Written by Tanmay Nath 
%%

n_frames = 260%x.numberOfFrames;
points = cell(n_frames,1);

for i = 1 : n_frames
    flies = [fly(i).features.Centroid];
    ang = [fly(i).features.Orientation];
    majAx = [fly(i).features.MajorAxisLength];
    minAx = [fly(i).features.MinorAxisLength];
    eccentricity = [fly(i).features.Eccentricity];
    Ar = [fly(i).features.Area];
    new_flies = reshape(flies,2,numel(flies)/2);
    new_flies = new_flies';
    temp_ang = ang';
    majAxis{i} = majAx';
    minAxis{i} = minAx';
    Area{i} = Ar';
    points{i} = new_flies;
    angle{i} = temp_ang;
    ecc{i} = eccentricity';
end
max_linking_distance = Inf;%4
max_gap_closing = 0.005;%Inf;%originally 0.1
debug = true;
%% Plotting the
% figure(1)
% clf
% hold on
% for i_frame = 1 : n_frames
%    
%     str = num2str(i_frame);
%     for j_point = 1 : size(points{i_frame}, 1)
%         pos = points{i_frame}(j_point, :);
%         plot(pos(1), pos(2))%, 'x')
%         %text('Position', pos, 'String', str)
%     end
%     
% end
%%
[ tracks, adjacency_tracks ] = simpletracker(points,...
    'MaxLinkingDistance', max_linking_distance, ...
    'MaxGapClosing', max_gap_closing, ...
    'Debug', debug);

%% Plot tracks
% We want to plot each track in a given color. Normally we would have to
% retrieve the points coordinates in the given |points| initiall cell
% array, for each point in frame. To skip this, we simple use the
% adjacency_tracks, that can pick points directly in the concatenated
% points array |all_points|.

n_tracks = numel(tracks);
colors = hsv(n_tracks);
track_points = cell(n_tracks,1);
track_angles = cell(n_tracks,1);
track_area = cell(n_tracks,1);
track_maj_axis = cell(n_tracks,1);
track_min_axis = cell(n_tracks,1);
track_ecc = cell(n_tracks,1);
all_points = vertcat(points{:});
all_points = all_points; %converting to cm
all_angles = vertcat(angle{:});
all_maj_ax = vertcat(majAxis{:});
all_min_ax = vertcat(minAxis{:});
all_area = vertcat(Area{:});
all_ecc = vertcat(ecc{:});

% close all
%set(0,'DefaultLineMarkerSize', 15)

% figure;
% axisLimits = [-8 8 -8 8];
% g = gca;
% set (g, 'XLim', [axisLimits(1) axisLimits(2)]);
% set (g, 'YLim', [axisLimits(3) axisLimits(4)]);
% 
% xLim = get(g,'Xlim');
% yLim = get(g,'Ylim');

for i_track = 1 : n_tracks
    
   hold on
    % We use the adjacency tracks to retrieve the points coordinates. It
    % saves us a loop.
    
    track = adjacency_tracks{i_track};
    track_points{i_track} = all_points(track, :);
    track_angles{i_track} = all_angles(track,:);
    track_maj_axis{i_track} = all_maj_ax(track,:);
    track_min_axis{i_track} = all_min_ax(track,:);
    track_area{i_track} = all_area(track,:);
    track_ecc{i_track} = all_ecc(track,:);
%     g = gca;
%     set (g, 'XLim', [axisLimits(1) axisLimits(2)]);
%     set (g, 'YLim', [axisLimits(3) axisLimits(4)]);
%     axisLimits = [-8 8 -8 8];

    %figure(i_track);
    hold on
    axis off
    axis square
    plot(track_points{i_track}(:,1), track_points{i_track}(:, 2), 'Color',colors(i_track, :))
    
end   



end

    
