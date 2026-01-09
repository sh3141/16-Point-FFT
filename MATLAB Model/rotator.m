function [res_r, res_im] = rotator(ip_r, ip_im, f_r, f_im,T_mul_r,T_mul_i) %#codegen
    prod_r_1 = cast(ip_r.*f_r,'like',T_mul_r);
    prod_r_2 = cast(ip_im.*f_im,'like',T_mul_r);

    res_r = cast(ip_r.*f_r - ip_im.*f_im,'like',T_mul_r);

    prod_i_1 = cast(ip_r.*f_im,'like',T_mul_i);
    prod_i_2 = cast(ip_im.*f_r,'like',T_mul_i);
    res_im = cast(ip_r.*f_im + ip_im.*f_r,'like',T_mul_i);
    