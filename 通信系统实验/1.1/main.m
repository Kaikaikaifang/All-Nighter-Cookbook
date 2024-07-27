clc
clear
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FileName:            main.m
%  Description:         DBPSK 系统仿真
%  Author:              季开放
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 参数
Rb=64000;         %符号速率，单位bit/s
Fc=Rb*5;          %载波频率，单位Hz,载波频率配置需为Rb的整数倍,同时能被采样率整除
Fs=Fc*16;         %采样频率
dt=1/Fs;

%% 建立输入模拟信号ych1
t = 0:1/Fs:(30720-1)/Fs;
yCh1=-sin(2*pi*1500*t)+8*cos(2*pi*3000*t)+2*sin(2*pi*6000*t);
% 归一化
ma = max(yCh1);
mi = min(yCh1);
m = max(ma, abs(mi));
yCh1=yCh1./m;
% 输入信号时域波形图及频谱
figure(1)
subplot(2,1,1)
t=0:dt:(length(yCh1)-1)*dt;
plot(t,yCh1);
title('输入信号波形');
xlabel('时间/s');
ylabel('幅值/V');
subplot(2, 1, 2)
[realf, realy] = FFTtoReal(yCh1, Fs);
plot(realf(1:50),realy(1:50));
title('输入信号频谱');
xlabel('频率/Hz');
ylabel('幅值/V');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PCM 13 折线编码
sampleVal=32000; %32k 抽样率
[sampleData,a13_moddata]=PCM_13Encode(yCh1,Fs,sampleVal);
%           sampleData	抽样后数据
%           a13_moddata 编码后的bit流数据
figure(2)
dt1=1/sampleVal;
t1=0:dt1:(length(sampleData)-1)*dt1;
subplot(2,1,1)
plot(t1,sampleData);
title('输入信号抽样（抽样率 32k）后的波形');
subplot(2,1,2)
plot(t1(1:30), a13_moddata(1:30));
ylim([-0.1, 1.1])
title('PCM 编码后的 bit 流数据');
xlabel('时间/s');
ylabel('幅值/V');


%% DBPSK调制
Sample_Num = Fs/Rb;

modulated_data = pskmod(a13_moddata, 2, pi);
modulated_data = repmat(modulated_data, Sample_Num, 1);
modulated_data = reshape(modulated_data, 1, []);
t=0:1/(Fs):(length(modulated_data)-1)*(1/(Fc*16));
carrier=cos(2*Fc*pi*t);%Fc 载波频率
dbpsk=modulated_data.*carrier;

figure(3)
plot(t(1:1000), real(modulated_data(1:1000)))
ylim([-1.1, 1.1])
title('数字信号');
xlabel('时间/s');
ylabel('幅值/V');

figure(4)
subplot(3, 1, 1)
plot(t(1:100), carrier(1:100))
ylim([-1.1, 1.1])
title('载波信号');
xlabel('时间/s');
ylabel('幅值/V');

subplot(3, 1, 2)
plot(t(1:1000), real(dbpsk(1:1000)));
ylim([-1.1, 1.1]);
title('DBPSK 已调信号');
xlabel('时间/s');
ylabel('幅值/V');

[realf, realy] = FFTtoReal(dbpsk, Fs);

subplot(3, 1, 3)
plot(realf,realy);
title('DBPSK 已调信号频谱');
xlabel('频率/Hz');
ylabel('幅值/V');

%% 加噪
Snr=10;         %信噪比
dbpsk_noise=awgn(dbpsk,Snr);
figure(5)
subplot(2,1,1)
plot(t(1:100), real(dbpsk_noise(1:100)));
ylim([-1.8, 1.8]);
title('DBPSK 加噪信号');
xlabel('时间/s');
ylabel('幅值/V');

%% DBPSK解调
% 接收端采样
fs_rec = Fs;
received_signal = dbpsk_noise(1:Fs/fs_rec:end);
% 生成接收端的时间向量
t_received = 0:1/Fs:(length(received_signal)-1)/Fs;
% 频谱搬移
demodulated_data = received_signal .* cos(2*Fc*pi*t_received);
% 使用低通滤波器进行滤波
cutoff_frequency = 2*Rb; % 低通滤波器截止频率
filter_order = 50; % 滤波器阶数
% 设计低通滤波器
lpf = fir1(filter_order, cutoff_frequency/(Fs/2));
% 进行滤波
demodulated_data_filtered = filter(lpf, 1, demodulated_data);
% 解调后的信号二值化
demod_dbpsk_d = pskdemod(demodulated_data_filtered, 2, pi);
demod_dbpsk=demod_dbpsk_d(1:Sample_Num:end);
subplot(2,1,2)
plot(t1(1:30), demod_dbpsk(1:30));
ylim([-0.1, 1.1]);
title('DBPSK 解调信号');
xlabel('时间/s');
ylabel('幅值/V');

%% PCM 13折线解码
figure(6);
[output] = PCM_13Decode([demod_dbpsk(2:end), demod_dbpsk(1)]);
subplot(2, 1, 1)
dt1=1/sampleVal;
t1=0:dt1:(length(output)-1)*dt1;
plot(t1,output);
title('PCM 解码输出波形');
xlabel('时间/s');
ylabel('幅值/V');
[realf, realy] = FFTtoReal(output, sampleVal);
subplot(2, 1, 2)
plot(realf,realy);
title('输出信号频谱');
xlabel('频率/Hz');
ylabel('幅值/V');

eyediagram(real(demodulated_data_filtered), Sample_Num*2);
%% 调用DA输出函数
%CH1_data=dataBit(1:30720);
%CH2_data=dbpsk(1:30720);
%CH1_data=yCh1(1:30720);
%CH2_data=yCh1(1:30720);
%CH1_data=output;
%CH2_data=output;
%N=length(CH1_data);
%divFreq=30720000/Fs-1;
%divFreq=30720000/sampleVal-1;%分频值
%isGain=1;
%DA_OUT(CH1_data,CH2_data,divFreq,N,isGain);%调用此函数之前，确保XSRP开启及线连接正常
