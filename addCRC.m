function [a] = addCRC(m,g,r)
    tmp = zeros(1,r+1);
    tmp(r+1) = 1;
    a = zeros(1,(length(m)+r));
    mx = gfconv(m,tmp);
    [res,c] = gfdeconv(mx,g);
    a_0 = gfadd(mx,c);
    for i = 1:(length(a_0))
        a(i) = a_0(i);
    end
end