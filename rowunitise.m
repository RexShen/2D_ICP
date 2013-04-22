function [unitveclist] = rowunitise(invectorlist)
% unitises row vectors
if size(invectorlist,2) ~= 2
	error('rowunitise: Incorrect usage')
end
nvecs = size(invectorlist,1);
unitveclist = zeros(nvecs,2);
for n = 1:nvecs;
	unitveclist(n,:) = invectorlist(n,:)/norm(invectorlist(n,:));
end
end