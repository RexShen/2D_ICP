function [closestpoint, dist] = getclosestpoint(point, polygon)
% find distances to all lines
for i = 1:(size(polygon,1)-1)
	if i ~= size(polygon,1)
		[closestlinepoints(i,1:2), closestlinepoints(i,3)] = ...
			getclosestlinepoint(point, polygon(i,:), polygon(i+1,:));
	else
		[closestlinepoints(i,1:2), closestlinepoints(i,3)] = ...
			getclosestlinepoint(point, polygon(i,:), polygon(1,:));
	end
	% choose smallest one
[dist, distind] = min(closestlinepoints(:,3));
closestpoint = closestlinepoints(distind,1:2);
end
end

function [closestlinepoint, distance] = getclosestlinepoint(point, vert1, vert2)
a = point - vert1;
b = vert2 - vert1;
closestlinepoint = vert1 + (a * dot(a,b)/(norm(a)*norm(b)));
% check to make sure point lies between vertices

% record distance (pythag)
distance = sqrt(norm(a)^2 - norm(a * dot(a,b)/(norm(a)*norm(b))));
end