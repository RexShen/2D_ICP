function [minrmsetfm, finalrmse] = ...
	minrmse(regpointset,initialtfm,polyshape)

%initialangle = atan2(initialtfm(2,1),initialtfm(1,1)) * (180/pi);
%initialtrans = [initialtfm(1,3), initialtfm(2,3)];

%initialguess = [initialangle, initialtrans];
initialguess = [0,0,0];

[rottransvec,finalrmse] = fminsearch(@(rottransvec) ...
	calcrmse(polyshape,regpointset,rottransvec),...
	initialguess);

rotangle = rottransvec(1);
transl = rottransvec(2:3);
minrmsetfm = [cosd(rotangle), -sind(rotangle), transl(1);...
	sind(rotangle), cosd(rotangle), transl(2);...
	0, 0, 1];
end

function [rmse] = calcrmse(polyshape,regpointset,rottransvec)
[closestpointset,dists] = ...
	getclosestpointset(regpointset,polyshape);

rotangle = rottransvec(1);
transl = rottransvec(2:3);
arbpointset = transformpoints(regpointset,...
	[cosd(rotangle), -sind(rotangle), transl(1);...
	sind(rotangle), cosd(rotangle), transl(2);...
	0, 0, 1]);
errorvecs = (arbpointset - closestpointset);
errormags = sqrt(errorvecs(:,1).^2 + errorvecs(:,2).^2);
rmse = sqrt(mean(errormags.^2));
end