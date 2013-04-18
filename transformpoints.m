function [transformedpoints] = transformpoints(pointset, transform)
pointset = [pointset, ones(size(pointset,1),1)]';
transformedpoints = transform * pointset;
transformedpoints = transformedpoints';
transformedpoints = transformedpoints(:,1:2);
end