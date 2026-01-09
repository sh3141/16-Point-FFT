function T = fft_dt_table(dt,L)
   %%%FM_rtl = fimath('RoundingMethod','Zero','OverflowAction','Wrap');

    switch dt 
        case 'double'
            T.x_r = double([]);
            T.x_i = double([]);
            T.W_r = double([]);
            T.W_i = double([]);
            %%%% stage 0 %%%%%
            T.x_delayed_8_r = double([]);
            T.x_delayed_8_i = double([]);
            T.x_r_extended_8 = double([]);
            T.x_i_extended_8 = double([]);
            T.x_e0_r = double([]);
            T.x_e0_i = double([]);
            T.x_o0_r = double([]);
            T.x_o0_i = double([]);
            %%%% stage 1 %%%%%
            T.mul_xo0_r = double([]);
            T.mul_xo0_im = double([]);       
            T.mul_xo0_r_delayed_4 = double([]); 
            T.mul_xo0_i_delayed_4 = double([]);
            T.x_e0_r_extended_4 = double([]);
            T.x_e0_i_extended_4 = double([]);
            T.x_1_r0 = double([]);
            T.x_1_i0 = double([]);
            T.x_1_r1 = double([]);
            T.x_1_i1 = double([]);
            
    
            T.x_1_r0_delayed_4 = double([]);
            T.x_1_i0_delayed_4 = double([]);

            T.x_1_r1_extended_4 = double([]);
            T.x_1_i1_extended_4 = double([]);

            T.x_e1_r = double([]);
            T.x_e1_i = double([]);
            T.x_o1_r = double([]);
            T.x_o1_i = double([]);
            %%%%%%%% stage 2 %%%%%%%%%%%%%%%
            T.W_r_1 = double([]);
            T.W_i_1 = double([]);
            T.mul_xo1_r = double([]);
            T.mul_xo1_i = double([]);
            
            T.mul_xo1_r_delayed_2 = double([]);
            T.mul_xo1_i_delayed_2 = double([]);
            T.x_e1_r_extended_2 = double([]);
            T.x_e1_i_extended_2 = double([]);

            T.x_2_r0 = double([]);
            T.x_2_i0 = double([]);
            T.x_2_r1 = double([]);
            T.x_2_i1 = double([]);
            
            T.x_2_r1_extended_2 = double([]);
            T.x_2_i1_extended_2 = double([]);
            T.x_2_r0_delayed_2 = double([]);
            T.x_2_i0_delayed_2 = double([]);
            T.x_e2_r = double([]);
            T.x_e2_i = double([]);
            T.x_o2_r = double([]);
            T.x_o2_i = double([]);
            
            %%%%%%%% stage 3 %%%%%%%%%%%%%%%%
            T.W_r_2 = double([]);
            T.W_i_2 = double([]);
            T.mul_xo2_r = double([]);
            T.mul_xo2_i = double([]);
            
            T.mul_xo2_r_delayed_1 = double([]);
            T.mul_xo2_i_delayed_1 = double([]);
            T.x_e2_r_extended_1 = double([]);
            T.x_e2_i_extended_1 = double([]);

            T.x_3_r0 = double([]);
            T.x_3_i0 = double([]);
            T.x_3_r1 = double([]);
            T.x_3_i1 = double([]);
            
            T.x_3_r1_extended_1 = double([]);
            T.x_3_i1_extended_1 = double([]);
            T.x_3_r0_delayed_1 = double([]);
            T.x_3_i0_delayed_1 = double([]);

            T.x_e3_r = double([]);
            T.x_e3_i = double([]);
            T.x_o3_r = double([]);
            T.x_o3_i = double([]);
            %%%%%%%% stage 4 %%%%%%%%%%%%%%%%
            T.x_e3_r_extended_8 = double([]);
            T.x_e3_i_extended_8 = double([]);
            T.x_o3_r_delayed_8 = double([]);
            T.x_o3_i_delayed_8 = double([]);
            T.X_r = double([]);
            T.X_i = double([]);
        case 'single'
            T.x_r = single([]);
            T.x_i = single([]);
            T.W_r = single([]);
            T.W_i = single([]);
            %%%% stage 0 %%%%%
            T.x_delayed_8_r = single([]);
            T.x_delayed_8_i = single([]);
            T.x_r_extended_8 = single([]);
            T.x_i_extended_8 = single([]);
            T.x_e0_r = single([]);
            T.x_e0_i = single([]);
            T.x_o0_r = single([]);
            T.x_o0_i = single([]);
            %%%% stage 1 %%%%%
            T.mul_xo0_r = single([]);
            T.mul_xo0_im = single([]);       
            T.mul_xo0_r_delayed_4 = single([]); 
            T.mul_xo0_i_delayed_4 = single([]);
            T.x_e0_r_extended_4 = single([]);
            T.x_e0_i_extended_4 = single([]);
            T.x_1_r0 = single([]);
            T.x_1_i0 = single([]);
            T.x_1_r1 = single([]);
            T.x_1_i1 = single([]);
            
    
            T.x_1_r0_delayed_4 = single([]);
            T.x_1_i0_delayed_4 = single([]);

            T.x_1_r1_extended_4 = single([]);
            T.x_1_i1_extended_4 = single([]);

            T.x_e1_r = single([]);
            T.x_e1_i = single([]);
            T.x_o1_r = single([]);
            T.x_o1_i = single([]);
            %%%%%%%% stage 2 %%%%%%%%%%%%%%%
            T.W_r_1 = single([]);
            T.W_i_1 = single([]);
            T.mul_xo1_r = single([]);
            T.mul_xo1_i = single([]);
            
            T.mul_xo1_r_delayed_2 = single([]);
            T.mul_xo1_i_delayed_2 = single([]);
            T.x_e1_r_extended_2 = single([]);
            T.x_e1_i_extended_2 = single([]);

            T.x_2_r0 = single([]);
            T.x_2_i0 = single([]);
            T.x_2_r1 = single([]);
            T.x_2_i1 = single([]);
            
            T.x_2_r1_extended_2 = single([]);
            T.x_2_i1_extended_2 = single([]);
            T.x_2_r0_delayed_2 = single([]);
            T.x_2_i0_delayed_2 = single([]);
            T.x_e2_r = single([]);
            T.x_e2_i = single([]);
            T.x_o2_r = single([]);
            T.x_o2_i = single([]);
            
            %%%%%%%% stage 3 %%%%%%%%%%%%%%%%
            T.W_r_2 = single([]);
            T.W_i_2 = single([]);
            T.mul_xo2_r = single([]);
            T.mul_xo2_i = single([]);
            
            T.mul_xo2_r_delayed_1 = single([]);
            T.mul_xo2_i_delayed_1 = single([]);
            T.x_e2_r_extended_1 = single([]);
            T.x_e2_i_extended_1 = single([]);

            T.x_3_r0 = single([]);
            T.x_3_i0 = single([]);
            T.x_3_r1 = single([]);
            T.x_3_i1 = single([]);
            
            T.x_3_r1_extended_1 = single([]);
            T.x_3_i1_extended_1 = single([]);
            T.x_3_r0_delayed_1 = single([]);
            T.x_3_i0_delayed_1 = single([]);

            T.x_e3_r = single([]);
            T.x_e3_i = single([]);
            T.x_o3_r = single([]);
            T.x_o3_i = single([]);
            %%%%%%%% stage 4 %%%%%%%%%%%%%%%%
            T.x_e3_r_extended_8 = single([]);
            T.x_e3_i_extended_8 = single([]);
            T.x_o3_r_delayed_8 = single([]);
            T.x_o3_i_delayed_8 = single([]);
            T.X_r = single([]);
            T.X_i = single([]);
        case 'fixed'
            T.x_r = fi([],1,L,L-2);
            T.x_i = fi([],1,L,L-2);
            T.W_r = fi([],1,L,L-2);
            T.W_i = fi([],1,L,L-2);
            %%%% stage 0 %%%%%
            T.x_delayed_8_r = fi([],1,L,L-2);
            T.x_delayed_8_i = fi([],1,L,L-2);
            T.x_r_extended_8 = fi([],1,L,L-2);
            T.x_i_extended_8 = fi([],1,L,L-2);
            T.x_e0_r = fi([],1,L,L-3);
            T.x_e0_i = fi([],1,L,L-3);
            T.x_o0_r = fi([],1,L,L-3);
            T.x_o0_i = fi([],1,L,L-3);
            %%%% stage 1 %%%%%
            T.mul_xo0_r = fi([],1,L,L-3);
            T.mul_xo0_im = fi([],1,L,L-3);       
            T.mul_xo0_r_delayed_4 = fi([],1,L,L-3); 
            T.mul_xo0_i_delayed_4 = fi([],1,L,L-3);
            T.x_e0_r_extended_4 = fi([],1,L,L-3);
            T.x_e0_i_extended_4 = fi([],1,L,L-3);
            T.x_1_r0 = fi([],1,L,L-3);
            T.x_1_i0 = fi([],1,L,L-3);
            T.x_1_r1 = fi([],1,L,L-3);
            T.x_1_i1 = fi([],1,L,L-3);
          
    
            T.x_1_r0_delayed_4 = fi([],1,L,L-3);
            T.x_1_i0_delayed_4 = fi([],1,L,L-3);

            T.x_1_r1_extended_4 = fi([],1,L,L-3);
            T.x_1_i1_extended_4 = fi([],1,L,L-3);

            T.x_e1_r = fi([],1,L,L-4);
            T.x_e1_i = fi([],1,L,L-4);
            T.x_o1_r = fi([],1,L,L-4);
            T.x_o1_i = fi([],1,L,L-4);
            %%%%%%%% stage 2 %%%%%%%%%%%%%%%
            T.W_r_1 = fi([],1,L,L-2);
            T.W_i_1 = fi([],1,L,L-2);
            T.mul_xo1_r = fi([],1,L,L-4);
            T.mul_xo1_i = fi([],1,L,L-4);
            
            T.mul_xo1_r_delayed_2 = fi([],1,L,L-4);
            T.mul_xo1_i_delayed_2 = fi([],1,L,L-4);
            T.x_e1_r_extended_2 = fi([],1,L,L-4);
            T.x_e1_i_extended_2 = fi([],1,L,L-4);

            T.x_2_r0 = fi([],1,L,L-4);
            T.x_2_i0 = fi([],1,L,L-4);
            T.x_2_r1 = fi([],1,L,L-4);
            T.x_2_i1 = fi([],1,L,L-4);
            
            T.x_2_r1_extended_2 = fi([],1,L,L-4);
            T.x_2_i1_extended_2 = fi([],1,L,L-4);
            T.x_2_r0_delayed_2 = fi([],1,L,L-4);
            T.x_2_i0_delayed_2 = fi([],1,L,L-4);
            T.x_e2_r = fi([],1,L,L-5);
            T.x_e2_i = fi([],1,L,L-5);
            T.x_o2_r = fi([],1,L,L-5);
            T.x_o2_i = fi([],1,L,L-5);
            
            %%%%%%%% stage 3 %%%%%%%%%%%%%%%%
            T.W_r_2 = fi([],1,L,L-2);
            T.W_i_2 = fi([],1,L,0);
            T.mul_xo2_r = fi([],1,L,L-5);
            T.mul_xo2_i = fi([],1,L,L-5);
            
            T.mul_xo2_r_delayed_1 = fi([],1,L,L-5);
            T.mul_xo2_i_delayed_1 = fi([],1,L,L-5);
            T.x_e2_r_extended_1 = fi([],1,L,L-5);
            T.x_e2_i_extended_1 = fi([],1,L,L-5);

            T.x_3_r0 = fi([],1,L,L-5);
            T.x_3_i0 = fi([],1,L,L-5);
            T.x_3_r1 = fi([],1,L,L-5);
            T.x_3_i1 = fi([],1,L,L-5);
            
            T.x_3_r1_extended_1 = fi([],1,L,L-5);
            T.x_3_i1_extended_1 = fi([],1,L,L-5);
            T.x_3_r0_delayed_1 = fi([],1,L,L-5);
            T.x_3_i0_delayed_1 = fi([],1,L,L-5);

            T.x_e3_r = fi([],1,L,L-6);
            T.x_e3_i = fi([],1,L,L-6);
            T.x_o3_r = fi([],1,L,L-6);
            T.x_o3_i = fi([],1,L,L-6);
            %%%%%%%% stage 4 %%%%%%%%%%%%%%%%
            T.x_e3_r_extended_8 = fi([],1,L,L-6);
            T.x_e3_i_extended_8 = fi([],1,L,L-6);
            T.x_o3_r_delayed_8 = fi([],1,L,L-6);
            T.x_o3_i_delayed_8 = fi([],1,L,L-6);
            T.X_r = fi([],1,L,L-(32-26));
            T.X_i = fi([],1,L,L-(32-26));
    end

