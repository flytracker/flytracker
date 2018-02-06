function H = ellipseImage( x0,y0,ang,a,b,points )
% ELLIPSEIMAGE plots the ellipse on the desired image. The equation for 
% plotting the ellipse has been taken from wikipedia.
% x0 is the x cordinate of the center of ellispe.
% y0 is the y cordinate of the center of ellipse.
% ang is the orientation of ellipse in angles.
% a is the semi major axis of the ellipse.
% b is the semi minor axis of the ellispe.
% points is the number of points to be plotted.
% H returns the points to be plotted to construct the ellipse. 

% Bugs corrected. 

% Written by Tanmay Nath 01/10/2013. 
    
    beta = - ang * (pi / 180);
    sinbeta = sin(beta);
    cosbeta = cos(beta);

    alpha = linspace(0, 360, points)' .* (pi / 180);
    sinalpha = sin(alpha);
    cosalpha = cos(alpha);

    X = x0 + (a * cosalpha * cosbeta - b * sinalpha * sinbeta);
    Y = y0 + (a * cosalpha * sinbeta + b * sinalpha * cosbeta);
    H = [X Y];
end



