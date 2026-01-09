function [out_add_r, out_add_i, out_sub_r, out_sub_i] = R2(in1_r, in1_i, in2_r, in2_i,T_out_a_r,T_out_a_i, T_out_s_r, T_out_s_i) %#codegen
    out_add_r = cast(in1_r + in2_r,'like',T_out_a_r);
    out_add_i = cast(in1_i + in2_i,'like',T_out_a_i);
    out_sub_r = cast(in1_r - in2_r,'like',T_out_s_r);
    out_sub_i = cast(in1_i - in2_i,'like',T_out_s_i);
    