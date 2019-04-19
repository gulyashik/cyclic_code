clear all
close all
gX = [1 0 1 0 0 1 1 0 1 0 1 1 1 1 0 0 1];
r = length(gX) - 1;
DataSize = 8;
DataAndCrcSize = 24;
X_1 = 26;
X_2 = 31;
%----------- Создаем сообщение -------------%
message = randi([0,1],1,DataSize);
%[m, A, Ah] = MessageCreate(DataSize,g,r);

%----------- Моделирование -------------%

index = 1;
SNRdB = -8:8;

for nSNR = 1: length(SNRdB)     
    nAll = 0;
    nDelivered = 0;
    ErrorOnBits = 0;
    ErrorOnBits2 = 0;
    ErrorDecode = 0;
    for N = 1:50
    %for N = 1:100*(nSNR+10)
         disp(N);
        S = -1;
%         n_m = randi([1,2^DataSize]);
%         
%         SNRfr = 10^(nSNR/10);
%         sigma =  sqrt(1/(2*SNRfr));
        while 1
        a = addCRC(message,gX,(length(gX) - 1));
        
        %%ADD 2 ZERO FOR HEMMING
        X = zeros(1,X_1);
        X(3:X_1) = a;
        %%HEMMING CODE
        code_H = encode(X,X_2,X_1,'hamming/binary');
        %%DELETE 2 ZERO AND BPSK
        %code = code_h.*(-2)+1;
        code = code_H(3:length(code_H));
        code_BPSK = zeros(1,length(code));
       
        for j=1:length(code)
            if code(j) == 1
                code_BPSK(j) = 1;                                   
            else
                code_BPSK(j) = -1; 
            end
        end
      %  while 1
            nAll = nAll + 1;
        %%ADD NOIZE
        SNR = 10^(SNRdB(nSNR)/10);
        sigma = sqrt(1/(SNR*2));
      %  code_BPSK2 = code_BPSK ;
        code_BPSK2 = code_BPSK + sigma.*randn(1,length(code_BPSK));   
        %%ADD 2 ZERO
%         code(1) = 0;
%         code(2) = 0;
        %%BPSK DEMODULATION
        code_AfterBPSK = zeros(1,length(code_BPSK2));
        for j=1:length(code_BPSK2)
            if code_BPSK2(j) > 0
                code_AfterBPSK(j) = 1;                                    
            end
            if code_BPSK2(j) < 0
                code_AfterBPSK(j) = 0;                                      
            end
        end
        
        %%ADD 2 ZERO
        code_AddZero = zeros(1,length(code_AfterBPSK)+2);
        code_AddZero(1) = 0;
        code_AddZero(2) = 0;
        code_AddZero(3:length(code_AddZero)) = code_AfterBPSK;
       
        %%HEMMING DEMODULATION
        code_AfterHemingDemodul = decode(code_AddZero,X_2,X_1,'hamming/binary');

        %%DELETE 2 ZERO
            b = code_AfterHemingDemodul(3:length(code_AfterHemingDemodul));
          %  ErrorOnBits2 = ErrorOnBits2 + nnz(gfadd(a,b));
%             b_c = correctError(b);
%             b_res = concatMessage(b_c);
            [res, S] = gfdeconv(b,gX);
            nAll = nAll + 1;
            e = gfadd(b,a);
            ErrorOnBits = ErrorOnBits + nnz(e);
            if (S==0) &(nnz(e)~=0)
                ErrorDecode = ErrorDecode + 1;
            end
            if S == 0
                nDelivered = nDelivered + 1;
                break
            end
        end
    end
    Pe_decode(index) = ErrorDecode/nDelivered;
    Pe_bit(index) = ErrorOnBits/(nAll*(DataSize+r)*31/26);
    Propusk(index) = (DataSize*nDelivered)/(((DataSize+r)*31/26)*nAll)
   % Pe_bit2(index) = ErrorOnBits2/(nAll*(DataSize+r)*31/26);
   % T(index) = (DataSize*nGood)/(((DataSize+r)*7/4)*nAll);
    index = index + 1;
    disp(SNRdB(nSNR));
end



Pe_theor = qfunc(sqrt(2*(10.^(SNRdB./10))));
figure(1)
semilogy(SNRdB,Pe_decode,'r');
legend('Error Decoding');
figure(2)
semilogy(SNRdB, Pe_bit,'r',SNRdB, Pe_theor,'b')
legend('Practical', 'Theoretical');
figure(3)
plot(SNRdB,Propusk,'b')
legend('Propusk')
