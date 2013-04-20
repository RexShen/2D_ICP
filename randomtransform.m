function [randtrans] = randomtransform(maxtrans, maxrot)

rtr = unitise((rand(2,1)*2)-1)*maxtrans;
transtfm = [1, 0, rtr(1); 0, 1, rtr(2); 0, 0, 1];

rangle = ((rand*2)-1)*maxrot;
rottfm = [cosd(rangle), -sind(rangle), 0; sind(rangle), cosd(rangle), 0;...
	0, 0, 1];

randtrans = transtfm * rottfm;
end