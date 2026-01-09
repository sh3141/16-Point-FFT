function [res_r, res_im] = trivial_rotator(ip_r, ip_im,sel,T_mul_r, T_mul_i)
    sel = logical(sel);
    res_r = cast(ip_r,'like',T_mul_r);
    res_im = cast(ip_im,'like',T_mul_i);
    res_r(sel) = cast(ip_im(sel),'like',T_mul_r);
    res_im(sel) = cast(-ip_r(sel),'like',T_mul_i);

