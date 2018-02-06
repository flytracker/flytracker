% Notice that the we are trying to locate the ellipse in an image. The
% origin is at top left corner of the image. In order to plot the ellipse
% on the image we have subtracted the y column of pixelList from the size 
% of image so that it gets inverted. The eigen vector corresponding to the
% maximum eigen value represents the major axis of ellipse. This
% orientation is the actual orientation of the ellipse. But if we try to
% plot the ellipse with this orientation then it will not be plotted
% properly because the figure has different axis.


% Consulted http://cosmic.mse.iastate.edu/library/pdf/pcalevel1.pdf

% Bugs corrected.
% Written by Tanmay Nath 30 September,2013


sig = ob.Sigma;
mu = ob.mu;

for cluster = 1:k
   
    [v,d] = svd(sig(:,:,cluster));
    [majValue,index] = max(diag(d));
    majVector = v(:,index); 
    a = max(diag(d)); 
    b = min(diag(d));

    ra = 2 * a; rb = 2 * b;
    
    x0 = mu(cluster,1);
    y0 = mu(cluster,2);

    ang = atand(majVector(2,1)/majVector(1,1));

    area = pi*a/2 *b/2 ;
    ecc = sqrt(1 - (rb * rb)/(ra * ra));

    if flag == 1
        imshow(fg)
        hold on
%        y0 = (n - y0);
%         h=ellipse(ra/4,rb/4,ang,x0,y0,'g',500);
        H = ellipseImage(x0,y0,ang,a/2,2*b,500);
        
        line(H(:,1),H(:,2),'Color','red','LineWidth',2);
        hold on
    end

    gmmFeatures(cluster) = struct('Area',area,'Centroid',[mu(cluster,1), mu(cluster,2)],...
        'Eccentricity',ecc,'MajorAxisLength',ra, 'MinorAxisLength',rb, 'Orientation',ang,'PixelList',[]);
% gmmFeatures(cluster) = struct('Area',area,'Centroid',[C(:,1),n - C(:,2)],...
%     'Eccentricity',ecc,'MajorAxisLength',ra, 'MinorAxisLength',rb, 'Orientation',ang,'PixelList',[]);
    if cluster == 1 
        flyIdx = flyId(lg); 
    else
        flyIdx = numel(fly(i).features)+1;
    end
    fly(i).features(flyIdx).Area = gmmFeatures(cluster).Area;
    fly(i).features(flyIdx).Centroid = gmmFeatures(cluster).Centroid;
    fly(i).features(flyIdx).Eccentricity = gmmFeatures(cluster).Eccentricity;
    fly(i).features(flyIdx).MajorAxisLength = gmmFeatures(cluster).MajorAxisLength;
    fly(i).features(flyIdx).MinorAxisLength = gmmFeatures(cluster).MinorAxisLength;
    fly(i).features(flyIdx).Orientation = gmmFeatures(cluster).Orientation;
    fly(i).features(flyIdx).PixelList = gmmFeatures(cluster).PixelList;

end
touchFly{lg} = [fly(i).features(flyId(lg)).Centroid; fly(i).features(flyIdx).Centroid];
% touchFly = reshape(touchFly,2,2);
