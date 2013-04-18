function [pointset] = randompointset(polyshape, npoints)
% decare pointset
pointset = zeros(npoints,2);

for i = 1:npoints
	% select a random vertex
	randomvertind = randi(size(polyshape,1));
	% choose one of its neighbours
	sign = randi([0 1]);
	if sign == 0
		neighbourind = randomvertind - 1;
		% sort it out if we run off the bottom
		if neighbourind < 1
			neighbourind = size(polyshape,1);
		end
	else
		neighbourind = randomvertind + 1;
		% sort it out if we run off the top
		if neighbourind > size(polyshape,1)
			neighbourind = 1;
		end
	end
	% find a random point between these two
	randmag = rand;
	line = polyshape(neighbourind,:) - polyshape(randomvertind,:);
	% store the random point
	pointset(i,:) = polyshape(randomvertind,:)+(randmag*line);
end
end