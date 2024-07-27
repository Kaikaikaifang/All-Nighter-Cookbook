%%
%一阶RC低通滤波器仿真
%1、分析了一阶RC滤波器的幅值衰减特性和相移特性
%2、分析了一阶RC滤波器的频域特性
%3、使用lsim对系统进行仿真
%4、使用FFT对原始输入信号和滤波器输出信号进行分析
%传递函数：Gs=100000/(s+100000)
%%
%对输出信号及采样频率等进行初始值设定
clc
clear
close all
A = 1; % A 幅度值
fs = 5000000; % fs 采样频率
F = 10000; % F 信号频率，10kHz
N = 10000; % N 采样点数
dt = 1 / fs; %时间间隔
t = 0:dt:(N - 1) * dt; %时间向量

%对输入正弦信号的频率进行设定
F1 = 2000;
F2 = 10000;
F3 = 30000;
F4 = 100000;
F5 = 200000;
F6 = 500000;
F7 = 15900;
F8 = 10000;
%%
%选取输入信号
Freq = 7; %波形选择

switch Freq
    case 1
        y = A * sin(2 * pi * F1 * t);
    case 2
        y = A * sin(2 * pi * F2 * t);
    case 3
        y = A * sin(2 * pi * F3 * t);
    case 4
        y = A * sin(2 * pi * F4 * t);
    case 5
        y = A * sin(2 * pi * F5 * t);
    case 6
        y = A * sin(2 * pi * F6 * t);
    case 7
        y = A * sin(2 * pi * F7 * t);
    case 8
        y = A * square(2 * pi * F8 * t, 50)
    otherwise
end

%%
%绘制输入信号的时域、频域波形
figure(1);
subplot(2, 1, 1);
plot(t, y);
title('15.9kHz输入信号时域波形'); %对原始图像进行时域画图
xlabel('时间/s');
ylabel('电压/v');
h = fft(y, 10000); %快速傅里叶变换
h_d = abs(fftshift(h)); %使频域图像中间为零
f = (-N / 2:N / 2 - 1) * fs / N; %将取得时间上的点转化为频率上的点
subplot(2, 1, 2);
plot(f, h_d / 10000); %画原始图像频域上图
axis([-3 * 10 ^ 4 3 * 10 ^ 4 0 1]);
title('输入信号的频域波形');
xlabel('频率/hz');
ylabel('幅度')
%%
%对低通滤波器进行初值设定，同时绘制幅频特性
r = 1 * 10 ^ 3; %电阻阻值（Ω）
c = 10 * 10 ^ (-9); %电容（f）
w = 2 * pi * f; %角频率

Func = tf(1, [r * c, 1]); %系统的传递函数
figure(2);
bode(Func); %系统的波特图
title('低通滤波器特性图');
%%
%信号通过滤波器并绘制输出信号的时域、频域波形
[yout, tout] = lsim(Func, y, t); %滤波后信号图像
figure(3);
subplot(2, 1, 1);
plot(tout, yout);
title('输出信号的时域波形');
xlabel('时间/s');
ylabel('电压/v');
q = fft(yout);
q_d = abs(fftshift(q));
subplot(2, 1, 2);
plot(f, q_d / 10000);
title('输出信号的频域波形');
axis([-3 * 10 ^ 4 3 * 10 ^ 4 0 1]);
xlabel('频率/hz');
ylabel('幅度');
%%
%输入、输出信号的自相关函数
figure(4)
subplot(2, 1, 1);
[Rx, maxlags] = xcorr(y, 'unbiased'); %输入信号的自相关

if fs > 10000 %调整时间轴单位及标签,便于观测波形
    plot(maxlags / fs * 1000, Rx / max(Rx));
else
    plot(maxlags / fs, Rx / max(Rx));
end

title('输入信号自相关函数');
xlabel('时间/s');
ylabel('R(t)');
subplot(2, 1, 2);
[Rx1, maxlags1] = xcorr(yout, 'unbiased'); %输出信号的自相关

if fs > 10000 %调整时间轴单位及标签,便于观测波形
    plot(maxlags1 / fs * 1000, Rx1 / max(Rx));
else
    plot(maxlags1 / fs, Rx1 / max(Rx));
end

title('输出信号自相关函数');
xlabel('时间/s');
ylabel('R(t)');
%%
%绘制输入、输出信号的功率谱
figure(5);
subplot(2, 1, 1);
ypsd = h_d .* conj(h_d);
plot(f, ypsd);
axis([-2 * 10e4 2 * 10e4, 0 5 * 10e6]);
title('输入信号功率谱');
xlabel('频率/Hz');
ylabel('W/Hz');
subplot(2, 1, 2);
youtpsd = q_d .* conj(q_d);
plot(f, youtpsd);
axis([-2 * 10e4 2 * 10e4, 0 3 * 10e6]);
title('输出信号功率谱');
xlabel('频率/Hz');
ylabel('W/Hz');
