function [closestpointset, dists] = getclosestpointset(pointset, polygon)
closestpointset = zeros(size(pointset,1),2);
dists = zeros(size(pointset,1),1);
for i = 1:size(pointset,1)
	[closestpointset(i,:), dists(i)] = getclosestpoint(pointset(i,:), polygon);
end