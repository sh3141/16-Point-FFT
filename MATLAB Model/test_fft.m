clear; clc; close all;

%%%%parameters%%%
N = 16;
pre_tests = 12;
unit_tests = pre_tests+16;
MAX_VALUE = 1;
MIN_VALUE = -1;
nSeeds = 100;
DATA_WIDTH = 12;
no_of_tests = nSeeds+unit_tests;
error = zeros(no_of_tests,1);
SQNR1 = zeros(no_of_tests,1);
dt = 'fixed';
T = fft_dt_table(dt,DATA_WIDTH);
a = 5
fid_in_r = fopen('D:\FFT_VERIFICATION\inputs_r.txt','w');
fid_in_i = fopen('D:\FFT_VERIFICATION\inputs_i.txt','w');
fid_fixed_r = fopen('D:\FFT_VERIFICATION\expected_fixed_r.txt','w');
fid_fixed_i = fopen('D:\FFT_VERIFICATION\expected_fixed_i.txt','w');

for test = 1: (no_of_tests)
    rng(max(test-unit_tests,1));
    
    %%%%%%% test input %%%%%%%%%%%
    n = (0:(N-1));
    k1 = randi([0,N-1]);
    k2 = randi([0,N-1]);
    
    if(test <= unit_tests)
        switch(test) 
            case 1
                x = MAX_VALUE*ones(N,1) + ((1i)*MAX_VALUE).*ones(N,1);
            case 2
                x =  MAX_VALUE*ones(N,1) + ((1i)*MAX_VALUE).*ones(N,1);
            case 3
                x = MIN_VALUE*ones(N,1) + ((1i)*MIN_VALUE).*ones(N,1);
            case 4
                x = 0.005*ones(N,1) + ((1i)*MIN_VALUE).*ones(N,1);
            case 5
                mask = false(N,1);
                mask(1:N/2) = true;
                x = zeros(N,1);
                x(mask) = (MAX_VALUE*(1+(1i)));
                x(~mask) = (MIN_VALUE*(1+(1i)));
                
            case 6
                mask = true(N,1);
                mask(1:N/2) = false;
                x = zeros(N,1);
                x(mask) = (MAX_VALUE*(1+(1i)));
                x(~mask) = (MIN_VALUE*(1+(1i)));
            case 7
                mask = mod((0:N-1)',2) == 1 ;
                x = zeros(N,1);
                x(mask) = (MAX_VALUE*(1+(1i)));
                x(~mask) = (MIN_VALUE*(1+(1i)));
            case 8
                mask = mod((0:N-1)',2) == 0 ;
                x = zeros(N,1);
                x(mask) = (MAX_VALUE*(1+(1i)));
                x(~mask) = (MIN_VALUE*(1+(1i)));
            case 9
                mask = false(N,1) ;
                mask(4) = true;
                mask(12) = true;
                mask(8) = true;
                mask(16) = true;
                mask(7) = true;
                mask(15) = true;
                x = zeros(N,1);
                x(mask) = (MAX_VALUE*(1+(1i)));
                x(~mask) = (MIN_VALUE*(1+(1i)));
            case 10
                mask = false(N,1) ;
                mask(4) = true;
                mask(12) = true;
                mask(8) = true;
                mask(16) = true;
                mask(7) = true;
                mask(15) = true;
                x = zeros(N,1);
                x(mask) = (MIN_VALUE*(1+(1i)));
                x(~mask) = (MAX_VALUE*(1+(1i)));
                
            case 11
                mask = false(N,1);
                mask(1:N/2) = true;
                x = zeros(N,1);
                val = -(1 - 2.^(-10));
                x(mask) = (MAX_VALUE*(1+(1i)));
                x(~mask) = (val*(1+(1i)));
            case 12
                mask = false(N,1);
                mask(1:N/2) = true;
                x = zeros(N,1);
                val = (1 - 2.^(-10));
                x(mask) = (MIN_VALUE*(1+(1i)));
                x(~mask) = (val*(1+(1i))); %
            otherwise
                x =  MAX_VALUE*ones(N,1) + ((1i)*MAX_VALUE).*ones(N,1);
        end  
        if(test > pre_tests)
            k = (0:(N-1))';
            x = cos((2*pi*(test - pre_tests - 1)).*k/N) + (1i).*sin((2*pi*(test - pre_tests - 1)).*k/N);
        end
    else
        x = (MAX_VALUE-MIN_VALUE)*rand(N,1) + ((1i)*(MAX_VALUE-MIN_VALUE)).*rand(N,1);
        x = x +  MIN_VALUE*ones(N,1) + ((1i)*MIN_VALUE).*ones(N,1);
    end
    %%%%% FFT %%%%%%%%%%%
    x_in_r = cast(real(x),'like',T.x_r);
    x_in_i = cast(imag(x),'like',T.x_i);
    if(test == 1)
        buildInstrumentedMex fft_block -args {x_in_r,x_in_i,T};
    end
    if(strcmp(dt,'fixed'))
        for i = 1:N
            s_x_r = x_in_r(i);
            s_r = s_x_r.hex;
            s_x_i = x_in_i(i);
            s_i = s_x_i.hex;
            fprintf(fid_in_r, '%s\n', s_r);       
            fprintf(fid_in_i, '%s\n', s_i);
        end
    end
    [yr_1,yi_1] = fft_block_mex(x_in_r,x_in_i,T);
    latency = N - 1;
    if(strcmp(dt,'fixed'))
        for k = (latency + 1:N + latency )
            S_X_r = yr_1(k);
            S_r = S_X_r.hex;
            S_X_i = yi_1(k);
            S_i = S_X_i.hex;
            fprintf(fid_fixed_r, '%s\n', S_r);
            fprintf(fid_fixed_i, '%s\n', S_i);
        end
    end  
    %%%%%%% compare results to expected %%%%%%%
    
    y_expected = fft(x,N);
    y = zeros(N,1);
    len = size(y_expected);
    idx = 0:N-1;
    rev_idx = bitrevorder(idx);
    c = 0;
    for i = rev_idx 
        
        a = y_expected(i+1);
        y_r = 0;
        y_i = 0;
        
        if(mod(c,2)==0)
            y_r = yr_1(latency+1+floor(c/2));
            y_i = yi_1(latency+1+floor(c/2));
            
            
        else 
            y_r = yr_1(latency+1+N/2+floor(c/2));
            y_i = yi_1(latency+1+N/2+floor(c/2));
            
            
        end
        %sprintf("at index %i, exp real = %d, exp imag = %d, actual real = %d, actual img = %d",i,real(a),imag(a),y_r,y_i);
        %sprintf("at index %i, error at real = %d, error at imag = %d",i,real(a) - y_r,imag(a) - y_i);
        y(i+1) = y_r  + (1i).*y_i;
        c = c+1;
    end
    
  
    error(test) = abs(mean(double(y) - y_expected));
    sig_power = sum(abs(y_expected(:)).^2);
    q_power = sum(double(abs(y(:) - y_expected(:))).^2); 
    SQNR1(test) = 10*log10(sig_power/q_power);

end
fclose(fid_in_r);
fclose(fid_in_i);
fclose(fid_fixed_r);
fclose(fid_fixed_i);
%%% plot %%%%%%%
figure(1); plot(1:(no_of_tests), error , 'LineWidth',1); grid minor;
xlabel('Seed','FontSize',16); ylabel('Error','FontSize',16);
figure(2); plot(1:(no_of_tests), SQNR1 , 'LineWidth',1); grid minor;
xlabel('Seed','FontSize',16); ylabel('SQNR (dB)','FontSize',16);

showInstrumentationResults fft_block_mex -proposeFL -defaultDT numerictype(1,32)
average_SQNR = mean(SQNR1(unit_tests+1:no_of_tests))
