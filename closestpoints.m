function [closestpointset] = closestpoints(pointset, polygon)
closestpointset = zeros(size(pointset,1));
for i = 1:size(pointset,1)
	closestpointset(i,:) = getclosestpoint(pointset(i,:), polygon);
end