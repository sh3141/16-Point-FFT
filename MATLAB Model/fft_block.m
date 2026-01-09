function [X_r,X_i] = fft_block(x_r, x_i,T) %#codegen
    
    N = 16; 
    x_r = cast(x_r,'like',T.x_r);
    x_i = cast(x_i,'like',T.x_i);

    [W_r, W_i] = twiddle_lookup(N);
    W_r = cast(W_r,'like',T.W_r);
    W_i = cast(W_i,'like',T.W_i);

    
    %%%%%% stage 0 %%%%%%%%%%%%%%
    x_delayed_8_r = cast([zeros(N/2,1);x_r],'like',T.x_delayed_8_r); %%len = 3N/2
    x_delayed_8_i = cast([zeros(N/2,1);x_i],'like',T.x_delayed_8_i);
    x_r_extended_8 = cast([x_r;zeros(N/2,1)],'like',T.x_r_extended_8);
    x_i_extended_8 = cast([x_i;zeros(N/2,1)],'like',T.x_i_extended_8);
    [x_e0_r, x_e0_i, x_o0_r, x_o0_i] = R2(x_delayed_8_r, x_delayed_8_i,  x_r_extended_8, x_i_extended_8,T.x_e0_r,T.x_e0_i, T.x_o0_r, T.x_o0_i);
    x_e0_r = cast(x_e0_r,'like',T.x_e0_r);
    x_e0_i = cast(x_e0_i,'like',T.x_e0_i);
    x_o0_r = cast(x_o0_r,'like',T.x_o0_r);
    x_o0_i = cast(x_o0_i,'like',T.x_o0_i);

    %%%%%%%%debugging :
    a_x_r_delayed_8 = x_delayed_8_r';
    a_x_delayed_8_i = x_delayed_8_i';
    a_x_r_extended_8 = x_r_extended_8';
    
    a_x_e0_r = x_e0_r';
    a_x_e0_i = x_e0_i';
    a_x_o0_r = x_o0_r';
    a_x_o0_i = x_o0_i';
    %%%%%%%%% stage 1 %%%%%%%%%%%%%%

    [mul_xo0_r, mul_xo0_im] = rotator(x_o0_r, x_o0_i, [W_r;W_r;W_r], [W_i;W_i;W_i],T.mul_xo0_r,T.mul_xo0_im);
    mul_xo0_r = cast(mul_xo0_r,'like',T.mul_xo0_r);
    mul_xo0_im = cast(mul_xo0_im,'like',T.mul_xo0_im);
    mul_xo0_r_delayed_4 = cast([zeros(N/4,1);mul_xo0_r],'like',T.mul_xo0_r_delayed_4); %%len = N(1 + 1/2 + 1/4)
    mul_xo0_i_delayed_4 = cast([zeros(N/4,1);mul_xo0_im],'like',T.mul_xo0_i_delayed_4);
    x_e0_r_extended_4 = cast([x_e0_r; zeros(N/4,1)],'like',T.x_e0_r_extended_4);
    x_e0_i_extended_4 = cast([x_e0_i; zeros(N/4,1)],'like',T.x_e0_i_extended_4);
    sel_1_0 = zeros(7*N/4,1);
    sel_1_1 = zeros(7*N/4,1);
    %%%debug:
    a_mul_xo0_r = mul_xo0_r';
    a_mul_xo0_im = mul_xo0_im';
    a_mul_xo0_r_delayed_4 = mul_xo0_r_delayed_4';
    a_mul_xo0_i_delayed_4 = mul_xo0_i_delayed_4';
    a_x_e0_r_extended_4 = x_e0_r_extended_4';
    a_x_e0_i_extended_4 = x_e0_i_extended_4';
    for i = (0:7*N/4 - 1)
        sel_1_0(i+1) = logical(mod(floor(i/4),2));
        sel_1_1(i+1) = logical(mod(floor(i/4) + 1,2));
    end
   
    
    [x_1_r0,x_1_i0] = mux(x_e0_r_extended_4,x_e0_i_extended_4, mul_xo0_r_delayed_4, mul_xo0_i_delayed_4, sel_1_0);
    x_1_r0 = cast(x_1_r0, 'like',T.x_1_r0);
    x_1_i0 = cast(x_1_i0, 'like', T.x_1_i0);
    [x_1_r1,x_1_i1] = mux(x_e0_r_extended_4,x_e0_i_extended_4, mul_xo0_r_delayed_4, mul_xo0_i_delayed_4, sel_1_1);
    x_1_r1 = cast(x_1_r1,'like',T.x_1_r1);
    x_1_i1 = cast(x_1_i1, 'like', T.x_1_i1);

    x_1_r0_delayed_4 = cast([zeros(N/4,1);x_1_r0],'like',T.x_1_r0_delayed_4); %% len = N(1+1)
    x_1_i0_delayed_4 = cast([zeros(N/4,1);x_1_i0],'like',T.x_1_i0_delayed_4);

    x_1_r1_extended_4 = cast([x_1_r1;zeros(N/4,1)],'like',T.x_1_r1_extended_4);
    x_1_i1_extended_4 = cast([x_1_i1;zeros(N/4,1)],'like',T.x_1_i1_extended_4);

    [x_e1_r, x_e1_i, x_o1_r, x_o1_i] = R2(x_1_r0_delayed_4, x_1_i0_delayed_4, x_1_r1_extended_4, x_1_i1_extended_4,T.x_e1_r,T.x_e1_i, T.x_o1_r, T.x_o1_i) ;
    x_e1_r = cast(x_e1_r, 'like', T.x_e1_r);
    x_e1_i = cast(x_e1_i, 'like', T.x_e1_i);
    x_o1_r = cast(x_o1_r, 'like',T.x_o1_r);
    x_o1_i = cast(x_o1_i, 'like', T.x_o1_i);
    %%%%debugging:
    a_x_1_r0 = x_1_r0';
    a_x_1_r1 = x_1_r1';

    a_x_1_r0_delayed_4 = x_1_r0_delayed_4';
    a_x_1_i0_delayed_4 = x_1_i0_delayed_4';

    a_x_1_r1_extended_4 = x_1_r1_extended_4';


    a_x_e1_r = x_e1_r';
    a_x_e1_i = x_e1_i';
    a_x_o1_r = x_o1_r';
    a_x_o1_i = x_o1_i';
    
    %%%%%%%% stage 2 %%%%%%%%%%%%%%%
    W_r_1 = zeros(2*N,1);
    W_i_1 = zeros(2*N,1);
    for i = (1:2*N)
        W_r_1(i) = W_r(mod(2*i-1,N/2));
        W_i_1(i) = W_i(mod(2*i-1,N/2));
    end
    W_r_1 = cast(W_r_1,'like',T.W_r_1);
    W_i_1 = cast(W_i_1,'like',T.W_i_1);

    [mul_xo1_r, mul_xo1_i] = rotator(x_o1_r,x_o1_i,W_r_1,W_i_1,T.mul_xo1_r,T.mul_xo1_i);
    mul_xo1_r = cast(mul_xo1_r,'like',T.mul_xo1_r);
    mul_xo1_i = cast(mul_xo1_i,'like',T.mul_xo1_i);

    mul_xo1_r_delayed_2 = cast([zeros(N/8,1);mul_xo1_r],'like',T.mul_xo1_r_delayed_2);  %len = N(2+1/8)
    mul_xo1_i_delayed_2 = cast([zeros(N/8,1);mul_xo1_i],'like',T.mul_xo1_i_delayed_2);
    x_e1_r_extended_2 = cast([x_e1_r; zeros(N/8,1)],'like',T.x_e1_r_extended_2);
    x_e1_i_extended_2 = cast([x_e1_i; zeros(N/8,1)],'like',T.x_e1_i_extended_2);

    sel_2_0 = zeros(2*N + N/8,1);
    sel_2_1 = zeros(2*N + N/8,1);
 
    for i = (0:17*N/8 - 1)
        sel_2_0(i+1) = logical(mod(floor(i/2),2));
        sel_2_1(i+1) = logical(mod(floor(i/2)+1,2));
    end
    [x_2_r0,x_2_i0] = mux(x_e1_r_extended_2, x_e1_i_extended_2, mul_xo1_r_delayed_2, mul_xo1_i_delayed_2, sel_2_0);
    x_2_r0 = cast(x_2_r0,'like',T.x_2_r0);
    x_2_i0 = cast(x_2_i0, 'like', T.x_2_i0);

    [x_2_r1,x_2_i1] = mux(x_e1_r_extended_2, x_e1_i_extended_2, mul_xo1_r_delayed_2, mul_xo1_i_delayed_2, sel_2_1);
    x_2_r1 = cast(x_2_r1,'like',T.x_2_r1);
    x_2_i1 = cast(x_2_i1,'like',T.x_2_i1);

    x_2_r1_extended_2 = cast([x_2_r1; zeros(N/8,1)],'like',T.x_2_r1_extended_2); %len = N(2+1/4)
    x_2_i1_extended_2 = cast([x_2_i1; zeros(N/8,1)],'like',T.x_2_i1_extended_2);
    x_2_r0_delayed_2 = cast([zeros(N/8,1); x_2_r0],'like',T.x_2_r0_delayed_2);
    x_2_i0_delayed_2 = cast([zeros(N/8,1); x_2_i0],'like',T.x_2_i0_delayed_2);
    
    [x_e2_r, x_e2_i, x_o2_r, x_o2_i] = R2(x_2_r0_delayed_2, x_2_i0_delayed_2, x_2_r1_extended_2, x_2_i1_extended_2,T.x_e2_r,T.x_e2_i, T.x_o2_r, T.x_o2_i); 
    x_e2_r = cast(x_e2_r,'like',T.x_e2_r);
    x_e2_i = cast(x_e2_i,'like',T.x_e2_i);
    x_o2_r = cast(x_o2_r,'like',T.x_o2_r);
    x_o2_i = cast(x_o2_i,'like',T.x_o2_i);
    %%% debug
    a_x_e2_r = x_e2_r';
    a_x_e2_i = x_e2_i';
    a_x_o2_r = x_o2_r';
    a_x_o2_i = x_o2_i';

    %%%%%%%% stage 3 %%%%%%%%%%%%%%%%
    W_r_2 = zeros(9*N/4,1);
    W_i_2 = zeros(9*N/4,1);
    sel_3 = zeros(9*N/4,1);
    for i = (1:9*N/4)
        W_r_2(i) = W_r(mod(4*i-3,N/2));
        W_i_2(i) = W_i(mod(4*i-3,N/2));
        sel_3(i) = logical(mod(i-1,2));
    end
    W_r_2 = cast(W_r_2,'like',T.W_r_2);
    W_i_2 = cast(W_i_2,'like',T.W_i_2);

    

    [mul_xo2_r, mul_xo2_i] = trivial_rotator(x_o2_r,x_o2_i,sel_3,T.mul_xo2_r,T.mul_xo2_i);
    mul_xo2_r = cast(mul_xo2_r,'like',T.mul_xo2_r);
    mul_xo2_i = cast(mul_xo2_i,'like',T.mul_xo2_i);

    mul_xo2_r_delayed_1 = cast([zeros(N/16,1);mul_xo2_r],'like',T.mul_xo2_r_delayed_1);  %len = N(2+1/4 + 1/16)
    mul_xo2_i_delayed_1 = cast([zeros(N/16,1);mul_xo2_i],'like',T.mul_xo2_i_delayed_1);
    x_e2_r_extended_1 = cast([x_e2_r; zeros(N/16,1)],'like',T.x_e2_r_extended_1);
    x_e2_i_extended_1 = cast([x_e2_i; zeros(N/16,1)],'like',T.x_e2_i_extended_1);

    sel_3_0 = zeros(2*N + N/4 + N/16,1);
    sel_3_1 = zeros(2*N + N/4 + N/16,1);
 
    for i = (0:2*N + 5*N/16 - 1)
        sel_3_0(i+1) = logical(mod(i,2));
        sel_3_1(i+1) = logical(mod(i+1,2));
    end

    [x_3_r0, x_3_i0] = mux(x_e2_r_extended_1, x_e2_i_extended_1, mul_xo2_r_delayed_1, mul_xo2_i_delayed_1, sel_3_0);
    x_3_r0 = cast(x_3_r0,'like',T.x_3_r0);
    x_3_i0 = cast(x_3_i0,'like',T.x_3_i0);

    [x_3_r1, x_3_i1] = mux(x_e2_r_extended_1, x_e2_i_extended_1, mul_xo2_r_delayed_1, mul_xo2_i_delayed_1, sel_3_1);
    x_3_r1 = cast(x_3_r1,'like',T.x_3_r1);
    x_3_i1 = cast(x_3_i1,'like',T.x_3_i1);

    x_3_r1_extended_1 = cast([x_3_r1; zeros(N/16,1)],'like',T.x_3_r1_extended_1); %len = N(2+3/8)
    x_3_i1_extended_1 = cast([x_3_i1; zeros(N/16,1)],'like',T.x_3_i1_extended_1);
    x_3_r0_delayed_1 = cast([zeros(N/16,1); x_3_r0],'like',T.x_3_r0_delayed_1);
    x_3_i0_delayed_1 = cast([zeros(N/16,1); x_3_i0],'like',T.x_3_i0_delayed_1);


    [x_e3_r, x_e3_i, x_o3_r, x_o3_i] = R2(x_3_r0_delayed_1, x_3_i0_delayed_1, x_3_r1_extended_1, x_3_i1_extended_1,T.x_e3_r,T.x_e3_i, T.x_o3_r, T.x_o3_i); 
    x_e3_r = cast(x_e3_r,'like',T.x_e3_r);
    x_e3_i = cast(x_e3_i,'like',T.x_e3_i);
    x_o3_r = cast(x_o3_r,'like',T.x_o3_r);
    x_o3_i = cast(x_o3_i,'like',T.x_o3_i);

    a_x_e3_r = x_e3_r(N:end)';
    a_x_e3_i = x_e3_i(N:end)';
    a_x_o3_r = x_o3_r(N:end)';
    a_x_o3_i = x_o3_i(N:end)';

    %%%%%%%% stage 4 %%%%%%%%%%%%%%%%
    x_e3_r_extended_8 = cast([x_e3_r; zeros(N/2,1)],'like',T.x_e3_r_extended_8); %% len = len = N(2+7/8)
    x_e3_i_extended_8 = cast([x_e3_i; zeros(N/2,1)],'like',T.x_e3_i_extended_8);
    x_o3_r_delayed_8 = cast([zeros(N/2,1); x_o3_r],'like',T.x_o3_r_delayed_8);
    x_o3_i_delayed_8 = cast([zeros(N/2,1); x_o3_i],'like',T.x_o3_i_delayed_8);
    sel = zeros(N*(2+7/8),1);
    
    for i = (0:N*(2+7/8) - 1)
        sel(i+1) = logical(mod(floor((i+1)/8),2));        
    end
    a_sel = sel';
    [X_r, X_i] = mux(x_e3_r_extended_8,  x_e3_i_extended_8, x_o3_r_delayed_8,  x_o3_i_delayed_8,sel);
    X_r = cast(X_r,'like',T.X_r);
    X_i = cast(X_i,'like',T.X_i);