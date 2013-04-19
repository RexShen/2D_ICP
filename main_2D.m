%% define shape to register
polyshape = [100, 100; 120, 120; 150, 100];	% units are mm, say
origin = mean(polyshape,1);
origintfm = [1, 0, origin(1); 0, 1, origin(2); 0, 0, 1];

%% define point set
npoints = 3;
truepointset = randompointset(polyshape, npoints);
%truepointset = polyshape;
acqpointset = truepointset;

%% simulate initial estimate
maxtransoffset = 10; % mm
maxrotoffset = 10; % degrees

rtr = unitise((rand(2,1)*2)-1)*maxtransoffset;
transtfm = [1, 0, rtr(1); 0, 1, rtr(2); 0, 0, 1];

rangle = ((rand*2)-1)*maxrotoffset;
rottfm = [cosd(rangle), -sind(rangle), 0; sind(rangle), cosd(rangle), 0;...
	0, 0, 1];

% generate initial estimate
initialtfm = origintfm * transtfm * rottfm * inv(origintfm);
initialpointset = transformpoints(acqpointset, initialtfm);

regtfm = initialtfm; % start at initial transform
% set registering point set
registeringpointset = transformpoints(acqpointset, regtfm);

% find set of closest points
[closestpointset, dists] = ...
	getclosestpointset(registeringpointset, polyshape);
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
hmodel = plot([polyshape(:,1);polyshape(1,1)],...
	[polyshape(:,2);polyshape(1,2)],origin(1),origin(2),'+');

% true point set
htruepts = plot(truepointset(:,1),truepointset(:,2),...
	'o','markerfacecolor','g','markeredgecolor','none');

% registering point set
hregpts = plot(registeringpointset(:,1),registeringpointset(:,2),...
	'o','markerfacecolor','r','markeredgecolor','none');
set(hregpts,'xdatasource','registeringpointset(:,1)',...
	'ydatasource','registeringpointset(:,2)');

% closest point set
hclosepts = plot(closestpointset(:,1),closestpointset(:,2),...
	'o','markerfacecolor','m','markeredgecolor','none');
set(hclosepts,'xdatasource','closestpointset(:,1)',...
	'ydatasource','closestpointset(:,2)');

linkdata off

%% register
maxniter = 200; % set maximum number of ICP iterations before dropout
lastrmse = 100; % something high
itern = 1;
while ((lastrmse - currentrmse) > 0.1 && itern < maxniter)
	% find transform that minimises rmse
	minrmsetfm = minrmse(registeringpointset,closestpointset);
	% set regtfm accordingly
	regtfm = minrmsetfm * regtfm;
	% update registering point set
	registeringpointset = transformpoints(acqpointset,regtfm);
	% find set of closest points
	[closestpointset,dists] = ...
		getclosestpointset(registeringpointset,polyshape);
	% update rmse values
	lastrmse = currentrmse;
	currentrmse = sqrt(mean(dists.^2));
	refreshdata
	itern = itern + 1;
	pause(0.5)
end