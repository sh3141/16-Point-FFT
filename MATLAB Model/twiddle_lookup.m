function [W_r, W_i] = twiddle_lookup(N) %#codegen

    k = (0:(N/2-1))';
    W_r = cos((-2*pi).*k./N);
    W_i = sin((-2*pi).*k./N);