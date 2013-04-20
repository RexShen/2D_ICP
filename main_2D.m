%% define shape to register
polyshape = [100, 100; 120, 120; 150, 100];	% units are mm, say
origin = mean(polyshape,1);
origintfm = [1, 0, origin(1); 0, 1, origin(2); 0, 0, 1];

%% define point set
npoints = 10;
truepointset = randompointset(polyshape, npoints);
%truepointset = polyshape;
acqpointset = truepointset;

%% simulate initial estimate
maxtransoffset = 10; % mm
maxrotoffset = 10; % degrees

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

% shape
hshape = plot([polyshape(:,1);polyshape(1,1)],...
	[polyshape(:,2);polyshape(1,2)],'g',origin(1),origin(2),'+');

% true point set
htruepts = plot(truepointset(:,1),truepointset(:,2),...
	'o','markerfacecolor','g','markeredgecolor','none');

% reg point set
hregpts = plot(regpointset(:,1),regpointset(:,2),...
	'o','markerfacecolor','b','markeredgecolor','none');
set(hregpts,'xdatasource','regpointset(:,1)',...
	'ydatasource','regpointset(:,2)');

% closest point set
% hclosepts = plot(closestpointset(:,1),closestpointset(:,2),...
% 	'o','markerfacecolor','m','markeredgecolor','none');
% set(hclosepts,'xdatasource','closestpointset(:,1)',...
% 	'ydatasource','closestpointset(:,2)');

% reg shape
hregshape = plot([regshape(:,1);regshape(1,1)],...
	[regshape(:,2);regshape(1,2)],'b');
set(hregshape,'xdatasource','[regshape(:,1);regshape(1,1)]',...
	'ydatasource','[regshape(:,2);regshape(1,2)]');

linkdata off

%% register
minsup = true;
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
rmsestore = zeros(maxniter,nruns); drmsethresh = 0;
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
		refreshdata
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
refreshdata
% also plot starting point
% true point set
hinitialpts = plot(initialpointset(:,1),initialpointset(:,2),...
	'o','markerfacecolor','r','markeredgecolor','none');
% print best rmse and best regtfm
rmse
regtfm