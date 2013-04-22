%% define shape to register
polyshape = [100, 100; 120, 120; 150, 100];	% units are mm, say
%polyshape = [100, 100; 120, 90; 125, 115; 130, 80; 150, 130; 125, 140; ...
%	110, 165; 85, 140];
%polyshape = [100, 100; 150,100; 150,150; 100, 150];
origin = mean(polyshape,1);
origintfm = [1, 0, origin(1); 0, 1, origin(2); 0, 0, 1];

%% define point set
npoints = 10;
truepointset = randompointset(polyshape, npoints);
% truepointset = polyshape;
acqerrorSD = 0; % standard deviation of acquisition error (0 for no noise)
acqpointset = applypterror(truepointset,acqerrorSD);

%% simulate initial estimate
maxtransoffset = 15; % mm
maxrotoffset = 15; % degrees

% generate initial estimate
initialtfm = origintfm*randomtransform(maxtransoffset,maxrotoffset)...
	*inv(origintfm);
initialpointset = transformpoints(acqpointset, initialtfm);
regtfm = initialtfm; % start at initial transform

% set reg point set
regpointset = transformpoints(acqpointset, regtfm);
% set regshape (for plotting purposes)
regshape = transformpoints(polyshape,regtfm);

% find set of closest points
[closestpointset, dists] = ...
	getclosestpointset(regpointset, polyshape);
% update rmse values
currentrmse = sqrt(mean(dists.^2));

%% plot
margin = 15;
figure(1);
clf
hold on
grid on
axis equal
xlim([min(polyshape(:,1))-margin, max(polyshape(:,1))+margin]);
ylim([min(polyshape(:,2))-margin, max(polyshape(:,2))+margin]);

truecolor = 'g';
acqcolor = 'r';
initialcolor = 'k';
regcolor = 'b';
closecolor = 'm';
pointsize = 3;

% (true) shape
hshape = plot([polyshape(:,1);polyshape(1,1)],...
	[polyshape(:,2);polyshape(1,2)],origin(1),origin(2),'+');
set(hshape,'color', truecolor);

% true point set
% htruepts = plot(truepointset(:,1),truepointset(:,2),'o');
% set(htruepts,'markerfacecolor', truecolor,'markeredgecolor','none');

% acq point set
hacqpts = plot(acqpointset(:,1),acqpointset(:,2),'o');
set(hacqpts,'xdatasource','acqpointset(:,1)',...
	'ydatasource','acqpointset(:,2)',...
	'markerfacecolor', acqcolor,'markeredgecolor','none');

% closest point set
% hclosepts = plot(closestpointset(:,1),closestpointset(:,2),'o');
% set(hclosepts,'xdatasource','closestpointset(:,1)',...
% 	'ydatasource','closestpointset(:,2)',...
% 	'markerfacecolor', closecolor,'markeredgecolor','none');

% reg point set
hregpts = plot(regpointset(:,1),regpointset(:,2),'o');
set(hregpts,'xdatasource','regpointset(:,1)',...
	'ydatasource','regpointset(:,2)',...
	'markerfacecolor', regcolor,'markeredgecolor','none');

% reg shape
hregshape = plot([regshape(:,1);regshape(1,1)],...
	[regshape(:,2);regshape(1,2)]);
set(hregshape,'xdatasource','[regshape(:,1);regshape(1,1)]',...
	'ydatasource','[regshape(:,2);regshape(1,2)]',...
	'color', regcolor);

linkdata off

%% register
minsup = true; % local minimum suppression on if true
maxniter = 30; % set maximum number of ICP iterations before dropout
drmsethresh = 0.01; % delta rmse threshold
bestrmse = 100; % something high
framepause = 0.005; % pause between frames
maxnudgetrans = 10; % how much to nudge current reg estimate by (mm)
maxnudgerot = 10; % (degrees)


% check if local minimum suppression is on and set num runs accordingly
if minsup == true
	nruns = 10;
else
	nruns = 1;
end
% set up storage for rmses to test convergence. To maintain shape,
% algorithm must not drop out until max iterations reached
% rmsestore = zeros(maxniter,nruns); drmsethresh = 0;
for run = 1:nruns
	% perform a single ICP run
	itern = 1;
	lastrmse = 100; % something high
	while ((lastrmse - currentrmse) > drmsethresh && itern <= maxniter)
		% record rmse in matrix
		rmsestore(itern,run) = currentrmse;
		% find transform that minimises rmse
		minrmsetfm = minrmse(regpointset,closestpointset);
		% set regtfm accordingly
		regtfm = minrmsetfm * regtfm;
		% update reg point set and shape
		regpointset = transformpoints(acqpointset,regtfm);
		regshape = transformpoints(polyshape,regtfm);
		% find set of closest points
		[closestpointset,dists] = ...
			getclosestpointset(regpointset,polyshape);
		% update rmse values
		lastrmse = currentrmse;
		currentrmse = sqrt(mean(dists.^2));
		refreshdata(hregpts)
		refreshdata(hregshape)
		refreshdata(hclosepts) % NB just refreshdata causes a horrible bug
		% in version R2012b
		itern = itern + 1;
		pause(framepause) % for animation
	end
	% save rmse and regtfm if best yet
	if currentrmse < bestrmse
		bestrmse = currentrmse;
		bestregtfm = regtfm;
	end
	% nudge current estimate
	regtfm = origintfm*randomtransform(maxnudgetrans,...
		maxnudgerot)*inv(origintfm)*initialtfm;
	% update reg point set and shape
	regpointset = transformpoints(acqpointset,regtfm);
	regshape = transformpoints(polyshape,regtfm);
	% find set of closest points
	[closestpointset,dists] = ...
		getclosestpointset(regpointset,polyshape);
	% update rmse values
	lastrmse = currentrmse;
	currentrmse = sqrt(mean(dists.^2));
end
% set regtfm to best and display results
rmse = bestrmse;
regtfm = bestregtfm;
% update reg point set and shape
regpointset = transformpoints(acqpointset,regtfm);
regshape = transformpoints(polyshape,regtfm);
% plot best set
refreshdata(hregpts)
refreshdata(hregshape)
refreshdata(hclosepts)
% also plot starting point
% true point set
% hinitialpts = plot(initialpointset(:,1),initialpointset(:,2),...
% 	'o','markerfacecolor', initialcolor,'markeredgecolor','none');
% print best rmse and best regtfm

%% numerical grad of search space
% nudge final registration in each of the principle axis directions and see
% how the RMSE changes. Will give an indication of how bounded the results
% is, and therefore robustness. i.e.:

%				 \      /  or  |                  |
%				  \    /         \              /
%				   \  /            \          /
%				    \/               \______/

dtrans = 1; % amount of offset for translations
dangle = 1; % amount of offset for rotations

% offset (-1X, +1Y, +1X, -1Y, -1R, +1R)

offsetpointset = regpointset + [-ones(npoints,1) zeros(npoints,1)];
% find closest points
[closestpointset, dists] = ...
	getclosestpointset(offsetpointset, polyshape);
% find rmse
drmse(1) = sqrt(mean(dists.^2));

offsetpointset = regpointset + [zeros(npoints,1) ones(npoints,1)];
% find closest points
[closestpointset, dists] = ...
	getclosestpointset(offsetpointset, polyshape);
% find rmse
drmse(2) = sqrt(mean(dists.^2));

offsetpointset = regpointset + [ones(npoints,1) zeros(npoints,1)];
% find closest points
[closestpointset, dists] = ...
	getclosestpointset(offsetpointset, polyshape);
% find rmse
drmse(3) = sqrt(mean(dists.^2));

offsetpointset = regpointset + [zeros(npoints,1) -ones(npoints,1)];
% find closest points
[closestpointset, dists] = ...
	getclosestpointset(offsetpointset, polyshape);
% find rmse
drmse(4) = sqrt(mean(dists.^2));

drotmat = [cosd(-dangle), -sind(-dangle), 0;
	sind(-dangle), cosd(-dangle), 0;
	0, 0, 1];
offsetpointset = transformpoints(regpointset, drotmat);
% find closest points
[closestpointset, dists] = ...
	getclosestpointset(offsetpointset, polyshape);
% find rmse
drmse(5) = sqrt(mean(dists.^2));

drotmat = [cosd(dangle), -sind(dangle), 0;
	sind(dangle), cosd(dangle), 0;
	0, 0, 1];
offsetpointset = transformpoints(regpointset, drotmat);
% find closest points
[closestpointset, dists] = ...
	getclosestpointset(offsetpointset, polyshape);
% find rmse
drmse(6) = sqrt(mean(dists.^2));

drmse = drmse-rmse