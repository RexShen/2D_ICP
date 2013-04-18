function [unitvec] = unitise(invector)
invectormag = norm(invector);
unitvec = invector/invectormag;
end