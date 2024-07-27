% 功能：一阶 RC 高通滤波器仿真
% 说明：
%    1. dataSourceType = 0 表示正弦波,1 表示三音正弦波,2 表示方波
%    2. 输入信号的频率为 40KHz 的正弦波, 15KHz, 50KHz, 100KHz 的三音正弦波, 20KHz 的方波
%    3. 滤波器的截止频率为 1/(2*pi*R*C) = 1/(2*pi*5.3e+3*1e-9) = 30KHz
%    4. 系统的传递函数为 sys = s/(s+1/RC)
%==========================================================================
close all;

%% 参数设置
% TODO 输入波形选择
dataSourceType = 0;   % 波形类型 0表示正弦波,1表示三音正弦波,2表示方波

params.fs = 5000000; % fs 采样率
params.F = 10000;    % F 频率,小于采样率的一半（奈奎斯特）
params.A = 1;        % A 幅度值
params.N = 5000;     % N 采样个数
params.dt = 1/params.fs;    % 时间间隔
params.t = 0:params.dt:(params.N-1)*params.dt;    % 时间向量
params.freqPixel = params.fs/params.N;     % 频率分辨率,即点与点之间频率单位

%% 输入信号产生
F1 = 40e+3;
F2_1 = 15e+3;
F2_2 = 50e+3;
F2_3 = 100e+3;
F3 = 20e+3;

switch dataSourceType
    case 0
        y = params.A*sin(2*pi*F1*params.t);    % 频率为40khz正弦波
    case 1
        y = params.A*(sin(2*pi*F2_1*params.t)+sin(2*pi*F2_2*params.t)+sin(2*pi*F2_3*params.t)); % 频率为15kHZ, 50kHz, 100kHz的三音正弦波
    case 2
        y = params.A*square(2*pi*F3*params.t,50); % 频率为20KHz的方波
    otherwise
end

% 绘制输入信号的时域和频域波形
figure(1);
subplot(2, 1, 1);
plotTimeDomain(params.t, y, '信号的时域波形', '时间/s', '电压/v');

subplot(2, 1, 2);
[y_fft, f] = plotFrequencyDomain(y, params.fs, params.N, '信号的频域波形', '频率/hz', '电压/v');

%% 滤波器的设置
R = 5.3e+3;  % 电阻值
C = 1e-9;    % 电容值
Fc = 1/(2*pi*R*C);  % 截止频率
w = 2*pi*f;
Para = R*C*1i;

% 预分配数组大小
A = zeros(1, length(f));
P = zeros(1, length(f));

for n = 1:length(f)
    A(n) = abs(1/(1+(1/(Para*w(n)))));  % 幅值衰减系数
    P(n) = angle(1/(1+(1/(Para*w(n))))) * 180 / pi;  % 相移系数
end

% 绘制滤波器的幅值衰减特性和相位特性
figure(2);
subplot(2,1,1);
plot(f/1000,10*log(A),'LineWidth',1.5);  % 幅值曲线
axis([0 100 -100 0]);
xlabel('频率/KHz')
ylabel('幅值/dB')
title('幅频特性');
subplot(2,1,2);
plot(f/1000,P,'LineWidth',1.5);  % 相位曲线
xlabel('频率/KHz')
ylabel('角度/Deg')
axis([0 250 0 100]);
title('相频特性');

% 绘制系统的波特图
Func = tf([1 0],[1 1/(R*C)]);  % 系统的传递函数
figure(3);
bode(Func);  % 系统的波特图
title('频率特性（波特图）');

%% 输出信号
[yout,tout] = lsim(Func,y,params.t);  % 滤波后信号图像

% 绘制输入和输出信号的时域波形
figure(4);
subplot(2, 1, 1);
plotTimeDomain(params.t, y, '输入信号的时域波形', '时间/s', '幅度');
subplot(2, 1, 2);
plotTimeDomain(tout, yout, '输出信号的时域波形', '时间/s', '幅度');

% 绘制输入和输出信号的频域波形
figure(5);
subplot(2, 1, 1);
plotFrequencyDomain(y, params.fs, params.N, '输入信号的频域波形', '频率/Hz', '幅度');
subplot(2, 1, 2);
[yout_fft, ~] = plotFrequencyDomain(yout, params.fs, params.N, '输出信号的频域波形', '频率/Hz', '幅度');

% 绘制输入和输出信号的功率谱
figure(6);
subplot(2, 1, 1);
y_psd = y_fft.*conj(y_fft);
plotPowerSpectrum(f, y_psd, '输入信号的功率谱密度', '频率/Hz', 'W/Hz');
subplot(2, 1, 2);
yout_psd = yout_fft.*conj(yout_fft);
plotPowerSpectrum(f, yout_psd, '输出信号的功率谱密度', '频率/Hz', 'W/Hz');

% 绘制输入和输出信号的自相关函数
figure(7);
subplot(2, 1, 1);
[Rx, maxlags] = xcorr(y,'unbiased');  % 信号的自相关
Rx_max = max(Rx);
plotAutoCorrelation(maxlags/params.fs, Rx/Rx_max, '输入信号的自相关函数', '时间/s', 'R(t)');
subplot(2, 1, 2);
[Rx1, maxlags1] = xcorr(yout,'unbiased');  % 信号的自相关
Rx_max = max(Rx1);
plotAutoCorrelation(maxlags1/params.fs, Rx1/Rx_max, '输出信号的自相关函数', '时间/s', 'R(t)');

%% 绘图函数定义

function plotTimeDomain(t, y, titleStr, xlabelStr, ylabelStr)
plot(t, y);
title(titleStr);
xlabel(xlabelStr);
ylabel(ylabelStr);
end

function [y_fft_shifted, f] = plotFrequencyDomain(y, fs, N, titleStr, xlabelStr, ylabelStr)
y_fft = fft(y, N);
y_fft_shifted = abs(fftshift(y_fft));
f = (-N/2:N/2-1)*fs/N;
plot(f, y_fft_shifted/N);
title(titleStr);
xlabel(xlabelStr);
ylabel(ylabelStr);
axis([-2e+5 2e+5 0 0.8]);
end

function plotPowerSpectrum(f, y_psd, titleStr, xlabelStr, ylabelStr)
plot(f, y_psd);
title(titleStr);
xlabel(xlabelStr);
ylabel(ylabelStr);
axis([-2e+5 2e+5 0 12e+6]);
end

function plotAutoCorrelation(lags, Rx, titleStr, xlabelStr, ylabelStr)
plot(lags, Rx);
title(titleStr);
xlabel(xlabelStr);
ylabel(ylabelStr);
ylim([-1.1 1.1])
end
