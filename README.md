# flytraker
## Usage: 
Open MATLAB and build the mex file. 
<br />Use this link to [build mex files](https://www.mathworks.com/help/matlab/matlab_external/what-you-need-to-build-mex-files.html)
<br />Then, run the function flytracker.m
`[x,fly,timeStamp,touchFrame,touchFlyIds,movie,bg,numberOfFlies,flag,success,track_points,track_angles,track_maj_axis,track_min_axis,track_area,track_ecc,n_tracks,n_frames] = flyTracker;`
<br />The output will be stored in a cell which contains the trajectory of each fly.
