clear all;
% 相关参数
A=50;       % A 幅度值
fs=5000000; % fs 采样频率
L=100;%一个码元的采样点数
Rb=fs/L;%码元速率
number=127;%基带信号位数
fc=2*Rb; %载波频率

N=number*100*1;   % N 采样个数
dt=1/fs;    %时间间隔
t=0:dt:(N-1)*dt;    %时间向量
%信源产生

%基带信号
baseband=[];
for i=1:N
    if mod(i,L)==1%到了一个新码元
        baseband(i)=fix(2*rand);
    else
        baseband(i)=baseband(i-1);
    end
end

%载波信号
carrier=A*cos(2*pi*fc*t);%载波

Tlabel='时间/s';

No=wgn(1,N,1);%白噪声产生

signal_power = mean(carrier.^2);
noise_power = mean(No.^2);
SNR = signal_power / noise_power;
SNR_dB = 10 * log10(SNR);


%模拟信源信号
figure(1)
subplot(211)
t1=t(1:10000);
baseband1=baseband(1:10000);
plot(t1,baseband1)
axis([0,0.002,-0.5,1.5]);
title('基带信号波形');
xlabel(Tlabel);
ylabel('幅度/V');

%信号频谱
subplot(212)
t1=t(1:1000);
carrier1=carrier(1:1000);
plot(t1,carrier1);
title('载波波形');
xlabel(Tlabel);
ylabel('幅值/V');

%生成BPSK信号
doublebaseband=(baseband-0.5).*2;
BPSKsignal=doublebaseband.*carrier;

%BPSK信号加噪声
BPSKwithnoise=BPSKsignal+No;

%自相关
figure(2)
[Rx,maxlags]=xcorr(BPSKsignal,'unbiased');  %信号的自相关
if fs>10000  %调整时间轴单位及标签,便于观测波形
    plot(maxlags/fs*1000,Rx/max(Rx));
    xlabel('时延差/ms');
else
    plot(maxlags/fs,Rx/max(Rx));
    xlabel('时延差/s');
end
title('BPSK加噪自相关');
ylabel('R(τ)');
ylim([-1,1]);
   
%频谱
figure(3)
freq=fft(BPSKwithnoise,N)*2/N;%做离散傅里叶
freq_d=abs(fftshift(freq));
w=(-N/2:1:N/2-1)*fs/N; %双边  
plot(w,freq_d);
title('BPSK加噪频谱');
xlabel('频率/Hz');
ylabel('幅值/V');

%功率谱
figure(4)
ypsd=freq_d.*conj(freq_d);
plot(w,ypsd);
title('BPSK加噪功率谱');
xlabel('频率/Hz');
ylabel('W/Hz');

%BPSK加噪输出图像
figure(5)
t1=t(1:500);
BPSKsignal1=BPSKsignal(1:500);
plot(t1,BPSKsignal1)
title('BPSK输出图像');
xlabel('时间/s');
ylabel('幅值/V');

%BPSK加噪输出图像
figure(6)
t1=t(1:500);
BPSKwithnoise1=BPSKwithnoise(1:500);
plot(t1,BPSKwithnoise1)
title('BPSK加噪输出图像');
xlabel('时间/s');
ylabel('幅值/V');

%求均值和方差
aver=mean(BPSKwithnoise);
v=var(BPSKwithnoise);

fprintf("均值为%d，方差为%d\n",aver,v)