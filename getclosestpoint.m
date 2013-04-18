function [closestpoint, dist] = getclosestpoint(point, polygon)
closestlinepoints = zeros(size(polygon,1), 3);
% find distances to all lines
for i = 1:(size(polygon,1))
    if i ~= size(polygon,1)
        [closestlinepoints(i,1:2), closestlinepoints(i,3)] = ...
            getclosestlinepoint(point, polygon(i,:), polygon(i+1,:));
    else
        [closestlinepoints(i,1:2), closestlinepoints(i,3)] = ...
            getclosestlinepoint(point, polygon(i,:), polygon(1,:));
    end
end
% choose smallest one
[dist, distind] = min(closestlinepoints(:,3));
closestpoint = closestlinepoints(distind,1:2);
end

function [closestlinepoint, distance] = getclosestlinepoint(point, vert1, vert2)
a = point - vert1;
b = vert2 - vert1;
vert1toclosestpoint = unitise(b) * (dot(a,b)/norm(b));
closestlinepoint = vert1 + vert1toclosestpoint;
% check to make sure point lies between vertices
c = closestlinepoint - vert1;
if dot(b,c) < 0
    closestlinepoint = vert1;
elseif dot(c-b,-b) < 0
    closestlinepoint = vert2;
end
% record distance (pythag)
distance = sqrt(norm(a)^2 - norm(vert1toclosestpoint)^2);
end