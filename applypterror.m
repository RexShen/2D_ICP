function [errorpts] = applypterror(truepts, errorSD)
npts = size(truepts,1);
errordir = rowunitise((2.*rand(npts,2))-1);
errormag = randn(npts,1).*errorSD;

errorpts = truepts + ([errordir(:,1).*errormag, errordir(:,2).*errormag]);
end