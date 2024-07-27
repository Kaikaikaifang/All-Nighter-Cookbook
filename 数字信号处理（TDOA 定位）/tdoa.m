%% 编写时间：2023年11月
clc
clear
close all

%% 基本参数配置
c = 3e8; % 电磁目标信号传播速度，光速
u1 = [500, 300, 50]; %目标1坐标
u2 = [100, 140, 250]; %目标2坐标，按照学号编制
J = [600, 500, 800]; %干扰源坐标

x = [300, 400, 300, 350, -100, 200];
y = [100, 150, 500, 200 -100, -300];
z = [150, 100, 200, 100 -100, -200];
so = [x; y; z]; % 传感器的真实位置

fc_center = 6.6e7; %中心频率
fc = [6.5e7, 6.65e7, 6.6e7]; %各信号源的载波频率
B = [3e5, 1e5, 2e5]; %各信号源的带宽
fs = [3.2e7, 4e7, 4.8e7, 5.6e7, 6.4e7, 1.08e8]; %各传感器采样频率
Fs = 1.2096e9; % Sampling frequency (120.96 MHz)
T = 0.012;
dt = 1 / Fs;
t = 0:dt:T - dt;
num = length(t); % 载波信号总点数

M = size(so, 2); % 传感器的个数
D = size(so, 1); % 定位的维数

%% 各种辐射源信号模拟生成
%% Signal 1: QPSK
alpha1 = 0.5; %目标信号1的成型滤波器滚降系数
span = 6; % 根据经验选择的 span 值，可以根据需要进行调整
sps = Fs / B(1); % 设置为符号周期内的样本数
data1 = randi([0 3], 1, round(T * B(1))); % Random QPSK data
qpskSignal = pskmod(data1, 4, pi / 4);
%scatterplot(qpskSignal); % 显示星座图
b = rcosdesign(alpha1, span, sps);
Sig1 = upfirdn(qpskSignal, b, sps); %成型滤波
%qpsk_recover=upfirdn(Sig1,b,1,sps);  %此时默认上采样为1，即不进行上采样
carrier = cos(2 * pi * fc(1) * t); %载波
Sig1_carrier = Sig1(1:num) .* carrier;
carrier = cos(2 * pi * (fc(1) - fc_center) * t); %载波
Sig1 = Sig1(1:num) .* carrier;

%% Signal 2: 16QAM
alpha2 = 0.75; %目标信号2的成型滤波器滚降系数
sps = Fs / B(2); % 设置为符号周期内的样本数
data2 = randi([0 15], 1, round(T * B(2))); % Random 16QAM data
qam16Signal = qammod(data2, 16);
%scatterplot(qam16Signal);
b = rcosdesign(alpha2, span, sps);
Sig2 = upfirdn(qam16Signal, b, sps); %成型滤波
%qam_recover=upfirdn(Sig2,b,1,sps);
carrier = cos(2 * pi * fc(2) * t); %载波
Sig2_carrier = Sig2(1:num) .* carrier;
carrier = cos(2 * pi * (fc(2) - fc_center) * t); %载波
Sig2 = Sig2(1:num) .* carrier;

%% Interference Signal: BPSK
alpha3 = 0.35; %干扰信号的成型滤波器滚降系数
sps = Fs / B(3); % 设置为符号周期内的样本数
data3 = randi([0 1], 1, round(T * B(3))); % Random BPSK data
bpskSignal = pskmod(data3, 2, 0);
%scatterplot(bpskSignal);
b = rcosdesign(alpha3, span, sps);
Sig3 = upfirdn(bpskSignal, b, sps); %成型滤波
%bpsk_recover=upfirdn(Sig3,b,1,sps);  %此时默认上采样为1，即不进行上采样
carrier = cos(2 * pi * fc(3) * t); %载波
Sig3_carrier = Sig3(1:num) .* carrier;
carrier = cos(2 * pi * (fc(3) - fc_center) * t); %载波
Sig3 = Sig3(1:num) .* carrier;

%% 各定位传感器采集信号模拟生成
% 计算真实距离
[d1, d2, dn] = get_distance(u1, u2, so, J);
signals = [Sig1; Sig2; Sig3];
% 传感器采样信号
[sensor1_received_signal_origin] = receive_signal(1, [d1(1), d2(1), dn(1)], signals, Fs, fs(1));
[sensor2_received_signal_origin] = receive_signal(2, [d1(2), d2(2), dn(2)], signals, Fs, fs(2));
[sensor3_received_signal_origin] = receive_signal(3, [d1(3), d2(3), dn(3)], signals, Fs, fs(3));
[sensor4_received_signal_origin] = receive_signal(4, [d1(4), d2(4), dn(4)], signals, Fs, fs(4));
[sensor5_received_signal_origin] = receive_signal(5, [d1(5), d2(5), dn(5)], signals, Fs, fs(5));
[sensor6_received_signal] = receive_signal(6, [d1(6), d2(6), dn(6)], signals, Fs, fs(6));
% 采样信号上采样至相同采样频率 (1.08e8)
sensor1_received_signal = resample(sensor1_received_signal_origin, fs(6), fs(1));
sensor2_received_signal = resample(sensor2_received_signal_origin, fs(6), fs(2));
sensor3_received_signal = resample(sensor3_received_signal_origin, fs(6), fs(3));
sensor4_received_signal = resample(sensor4_received_signal_origin, fs(6), fs(4));
sensor5_received_signal = resample(sensor5_received_signal_origin, fs(6), fs(5));

%% 滤波
%% 设计面向目标信号1的滤波器
% 在混叠信号中将各传感器的目标1信号进行独立性抽取，得到6组数据
n_1 = 2048;
n_2 = 512;
b1_1 = fir1(n_1, [abs(fc_center - fc(1)) - B(1) abs(fc_center - fc(1)) + B(1)] / (fs(6) / 2));
b1_2 = fir1(n_2, [abs(fc_center - fc(1)) - B(1) abs(fc_center - fc(1)) + B(1)] / (fs(6) / 2));
target1_sensor1_signal = filter(b1_2, 1, filter(b1_1, 1, sensor1_received_signal));
target1_sensor1_signal = target1_sensor1_signal(n_1 + n_2:end);
target1_sensor2_signal = filter(b1_2, 1, filter(b1_1, 1, sensor2_received_signal));
target1_sensor2_signal = target1_sensor2_signal(n_1 + n_2:end);
target1_sensor3_signal = filter(b1_2, 1, filter(b1_1, 1, sensor3_received_signal));
target1_sensor3_signal = target1_sensor3_signal(n_1 + n_2:end);
target1_sensor4_signal = filter(b1_2, 1, filter(b1_1, 1, sensor4_received_signal));
target1_sensor4_signal = target1_sensor4_signal(n_1 + n_2:end);
target1_sensor5_signal = filter(b1_2, 1, filter(b1_1, 1, sensor5_received_signal));
target1_sensor5_signal = target1_sensor5_signal(n_1 + n_2:end);
target1_sensor6_signal = filter(b1_2, 1, filter(b1_1, 1, sensor6_received_signal));
target1_sensor6_signal = target1_sensor6_signal(n_1 + n_2:end);
%plot_spectrum(target1_sensor6_signal, fs(6), 'test');
target1_signals = [target1_sensor1_signal; target1_sensor2_signal; target1_sensor3_signal; target1_sensor4_signal; target1_sensor5_signal; target1_sensor6_signal];
%% 设计面向目标信号2的滤波器
% 在混叠信号中将各传感器的目标2信号进行独立性抽取，得到6组数据
b2_1 = fir1(n_1, [abs(fc_center - fc(2)) - B(2) abs(fc_center - fc(2)) + B(2)] / (fs(6) / 2));
b2_2 = fir1(n_2, [abs(fc_center - fc(2)) - B(2) abs(fc_center - fc(2)) + B(2)] / (fs(6) / 2));
target2_sensor1_signal = filter(b2_2, 1, filter(b2_1, 1, sensor1_received_signal));
target2_sensor1_signal = target2_sensor1_signal(n_1 + n_2:end);
target2_sensor2_signal = filter(b2_2, 1, filter(b2_1, 1, sensor2_received_signal));
target2_sensor2_signal = target2_sensor2_signal(n_1 + n_2:end);
target2_sensor3_signal = filter(b2_2, 1, filter(b2_1, 1, sensor3_received_signal));
target2_sensor3_signal = target2_sensor3_signal(n_1 + n_2:end);
target2_sensor4_signal = filter(b2_2, 1, filter(b2_1, 1, sensor4_received_signal));
target2_sensor4_signal = target2_sensor4_signal(n_1 + n_2:end);
target2_sensor5_signal = filter(b2_2, 1, filter(b2_1, 1, sensor5_received_signal));
target2_sensor5_signal = target2_sensor5_signal(n_1 + n_2:end);
target2_sensor6_signal = filter(b2_2, 1, filter(b2_1, 1, sensor6_received_signal));
target2_sensor6_signal = target2_sensor6_signal(n_1 + n_2:end);
target2_signals = [target2_sensor1_signal; target2_sensor2_signal; target2_sensor3_signal; target2_sensor4_signal; target2_sensor5_signal; target2_sensor6_signal];

% TDOA 定位
%% 以传感器1为参考节点，计算其他传感器相对于传感器1的到达时间差
% 目标 1
dt1 = cal_dt(target1_sensor1_signal, target1_signals, fs(6));
estimated_r_1 = c * dt1;
true_r_1 = d1 - d1(1);
dr1 = estimated_r_1 - true_r_1;
% 目标 2
dt2 = cal_dt(target2_sensor1_signal, target2_signals, fs(6));
estimated_r_2 = c * dt2;
true_r_2 = d2 - d2(1);
dr2 = estimated_r_2 - true_r_2;
%% 定位目标坐标估计
max_iterations = 1024; % 最大迭代次数
convergence_threshold = 1e-1; % 收敛判断阈值
% 估计目标 1 的坐标
u1_estimated = collaborative_localization(M, so, estimated_r_1(2:end), max_iterations, convergence_threshold);
fprintf("已定位目标1坐标：(x y z) = (%.4f %.4f %.4f)\n目标1实际坐标：(x y z) = (%d %d %d)\n", u1_estimated(1), u1_estimated(2), u1_estimated(3), u1(1), u1(2), u1(3));
% 估计目标 2 的坐标
u2_estimated = collaborative_localization(M, so, estimated_r_2(2:end), max_iterations, convergence_threshold);
fprintf("已定位目标2坐标：(x y z) = (%.4f %.4f %.4f)\n目标2实际坐标：(x y z) = (%d %d %d)\n", u2_estimated(1), u2_estimated(2), u2_estimated(3), u2(1), u2(2), u2(3));

%% 绘图
%% 绘制定位前场景图
figure(1);
plot3(x, y, z, "xr", u1(1), u1(2), u1(3), "og", u2(1), u2(2), u2(3), "squareb", J(1), J(2), J(3), "*k");
grid on;
axis equal;
xlabel('x');
ylabel('y');
zlabel('z');
legend("感知节点阵列", "信号源1", "信号源2", "干扰源", 'Location', 'northeast', 'NumColumns', 1);
title('定位前场景图');

%% 绘制定位后场景图
figure(2);
plot3(x, y, z, "xr", u1(1), u1(2), u1(3), "og", u2(1), u2(2), u2(3), "squareb", J(1), J(2), J(3), "*k", u1_estimated(1), u1_estimated(2), u1_estimated(3), "diamondg", u2_estimated(1), u2_estimated(2), u2_estimated(3), "diamondb");
grid on;
axis equal;
xlabel('x');
ylabel('y');
zlabel('z');
legend("感知节点阵列", "信号源1", "信号源2", "干扰源", "定位1", "定位2", 'Location', 'northeast', 'NumColumns', 1);
title('定位后场景图');

%% 绘制 IQ 波形图以及频谱图
figure(3);
subplot(3, 1, 1);
plot_iq(Sig1_carrier, Fs, '定位目标1信号 IQ 波形图');
subplot(3, 1, 2);
plot_iq(Sig2_carrier, Fs, '定位目标2信号 IQ 波形图');
subplot(3, 1, 3);
plot_iq(Sig3_carrier, Fs, '干扰信号 IQ 波形图');

figure(4);
subplot(3, 1, 1);
plot_spectrum(Sig1_carrier, Fs, '定位目标1信号频谱图(fc1=6.5e7)');
subplot(3, 1, 2);
plot_spectrum(Sig2_carrier, Fs, '定位目标2信号频谱图(fc2=6.65e7)');
subplot(3, 1, 3);
plot_spectrum(Sig3_carrier, Fs, '干扰信号频谱图(fc3=6.6e7)');

%% 绘制各传感器接收信号 IQ 波形图以及频谱图
figure(5);
subplot(3, 2, 1);
plot_iq(sensor1_received_signal_origin, fs(1), 'Sensor 1 接收信号 IQ 波形图');
subplot(3, 2, 2);
plot_iq(sensor2_received_signal_origin, fs(2), 'Sensor 2 接收信号 IQ 波形图');
subplot(3, 2, 3);
plot_iq(sensor3_received_signal_origin, fs(3), 'Sensor 3 接收信号 IQ 波形图');
subplot(3, 2, 4);
plot_iq(sensor4_received_signal_origin, fs(4), 'Sensor 4 接收信号 IQ 波形图');
subplot(3, 2, 5);
plot_iq(sensor5_received_signal_origin, fs(5), 'Sensor 5 接收信号 IQ 波形图');
subplot(3, 2, 6);
plot_iq(sensor6_received_signal, fs(6), 'Sensor 6 接收信号 IQ 波形图');

figure(6);
subplot(3, 2, 1);
plot_spectrum(sensor1_received_signal_origin, fs(1), 'Sensor 1 接收信号频谱图');
subplot(3, 2, 2);
plot_spectrum(sensor2_received_signal_origin, fs(2), 'Sensor 2 接收信号频谱图');
subplot(3, 2, 3);
plot_spectrum(sensor3_received_signal_origin, fs(3), 'Sensor 3 接收信号频谱图');
subplot(3, 2, 4);
plot_spectrum(sensor4_received_signal_origin, fs(4), 'Sensor 4 接收信号频谱图');
subplot(3, 2, 5);
plot_spectrum(sensor5_received_signal_origin, fs(5), 'Sensor 5 接收信号频谱图');
subplot(3, 2, 6);
plot_spectrum(sensor6_received_signal, fs(6), 'Sensor 6 接收信号频谱图');

% 传感器 1 接收信号上采样及滤波后 IQ 波形图以及频谱图（以传感器 1 为例，其他传感器同理）
figure(7);
subplot(3, 2, 1);
plot_iq(sensor1_received_signal, fs(6), 'Sensor 1 上采样(3.2e7->1.08e8)信号 IQ 波形图');
subplot(3, 2, 2);
plot_spectrum(sensor1_received_signal, fs(6), 'Sensor 1 上采样信号频谱图');
subplot(3, 2, 3);
plot_iq(target1_sensor1_signal, fs(6), '目标1信号(由 Sensor 1 滤波得到)IQ 波形图');
subplot(3, 2, 4);
plot_spectrum(target1_sensor1_signal, fs(6), '目标1信号(由 Sensor 1滤波得到)频谱图');
subplot(3, 2, 5);
plot_iq(target2_sensor1_signal, fs(6), '目标2信号(由 Sensor 1 滤波得到)IQ 波形图');
subplot(3, 2, 6);
plot_spectrum(target2_sensor1_signal, fs(6), '目标2信号(由 Sensor 1 滤波得到)频谱图');

% 目标信号 1 IQ 波形图及频谱图
figure(8);
subplot(3, 2, 1);
plot_iq(target1_sensor1_signal, fs(6), '目标1信号(由 Sensor 1 滤波得到)IQ 波形图');
subplot(3, 2, 2);
plot_spectrum(target1_sensor1_signal, fs(6), '目标1信号(由 Sensor 1 滤波得到)频谱图');
subplot(3, 2, 3);
plot_iq(target1_sensor2_signal, fs(6), '目标1信号(由 Sensor 2 滤波得到)IQ 波形图');
subplot(3, 2, 4);
plot_spectrum(target1_sensor2_signal, fs(6), '目标1信号(由 Sensor 2 滤波得到)频谱图');
subplot(3, 2, 5);
plot_iq(target1_sensor3_signal, fs(6), '目标1信号(由 Sensor 3 滤波得到)IQ 波形图');
subplot(3, 2, 6);
plot_spectrum(target1_sensor3_signal, fs(6), '目标1信号(由 Sensor 3 滤波得到)频谱图');
% 目标信号 2 IQ 波形图及频谱图
figure(9);
subplot(3, 2, 1);
plot_iq(target2_sensor4_signal, fs(6), '目标2信号(由 Sensor 4 滤波得到)IQ 波形图');
subplot(3, 2, 2);
plot_spectrum(target2_sensor4_signal, fs(6), '目标2信号(由 Sensor 4 滤波得到)频谱图');
subplot(3, 2, 3);
plot_iq(target2_sensor5_signal, fs(6), '目标2信号(由 Sensor 5 滤波得到)IQ 波形图');
subplot(3, 2, 4);
plot_spectrum(target2_sensor5_signal, fs(6), '目标2信号(由 Sensor 5 滤波得到)频谱图');
subplot(3, 2, 5);
plot_iq(target2_sensor6_signal, fs(6), '目标2信号(由 Sensor 6 滤波得到)IQ 波形图');
subplot(3, 2, 6);
plot_spectrum(target2_sensor6_signal, fs(6), '目标2信号(由 Sensor 6 滤波得到)频谱图');

% 互相关运算结果波形图
figure(10);
plot_xcorr(target1_sensor1_signal, target1_signals, "目标1信号互相关运算结果波形图");
figure(11);
plot_xcorr(target2_sensor1_signal, target2_signals, "目标2信号互相关运算结果波形图");

%% 表格
column_name = ["Sensor 1"; "Sensor 2"; "Sensor 3"; "Sensor 4"; "Sensor 5"; "Sensor 6"];
row_name = ["目标1定位距离差(m)"; "目标1真实距离差(m)"; "目标1TDOA测量误差(m)"; "目标2定位距离差(m)"; "目标2真实距离差(m)"; "目标2TDOA测量误差(m)"];
table_data = [estimated_r_1; true_r_1; dr1; estimated_r_2; true_r_2; dr2];
set(figure(12), 'position', [200 200 450 330]);
uitable(gcf, 'Data', table_data, 'Position', [20 20 400 290], 'Columnname', column_name, 'Rowname', row_name);
column_name = ["x", "y", "z"];
row_name = ["目标1定位坐标", "目标1真实坐标", "目标1坐标误差", "目标2定位坐标", "目标2真实坐标", "目标2坐标误差"];
table_data = [u1_estimated; u1; u1_estimated - u1; u2_estimated; u2; u2_estimated - u2];
set(figure(13), 'position', [200 200 450 330]);
uitable(gcf, 'Data', table_data, 'Position', [20 20 400 290], 'Columnname', column_name, 'Rowname', row_name);

function [received_signal, reached_signal] = receive_signal(n, distance, signals, Fs, fs)
    %% 传感器采样信号
    % input:
    % n: 传感器编号
    % distance: 传感器到信号源的距离
    % signals: 信号源信号
    % Fs: 信号源信号采样频率
    % fs: 传感器采样频率
    % output:
    % qpsk_sig: 采样后的QPSK信号
    % qam_sig: 采样后的16QAM信号
    % bpsk_sig: 采样后的BPSK信号
    fc = [6.5e7, 6.65e7, 6.6e7]; %各信号源的载波频率
    T = 0.01;
    dt = 1 / fs;
    t = 0:dt:T - dt;
    num = length(t);
    delay_t = distance / 3e8;
    delay_num = ceil(delay_t * Fs);
    max_delay_num = max(delay_num);

    % 下面计算各个辐射信号在各个定位传感器的接收功率强度，按照自由空间衰落模型进行计算
    Pow = 30; %所有三个信号辐射功率均为1W，等价于30dBmW;
    qpsk_sig = scale_pow(signals(1, delay_num(1):end - max_delay_num + delay_num(1)), Pow - calculate_FSPL(distance(1) / 1e3, fc(1) / 1e6));
    qam_sig = scale_pow(signals(2, delay_num(2):end - max_delay_num + delay_num(2)), Pow - calculate_FSPL(distance(2) / 1e3, fc(2) / 1e6));
    bpsk_sig = scale_pow(signals(3, delay_num(3):end - max_delay_num + delay_num(3)), Pow - calculate_FSPL(distance(3) / 1e3, fc(3) / 1e6));
    % 噪声信号
    Noise_pow = -90; %所有传感器背景噪声的接收功率均为-90dBmW;
    rng(n); % Seed for reproducibility
    Noise_sig = sqrt(10 ^ (Noise_pow / 10)) * randn(1, length(qpsk_sig)); % 传感器噪声
    %% 信号叠加
    reached_signal = qpsk_sig + qam_sig + bpsk_sig + Noise_sig;

    received_signal = resample(reached_signal, fs, Fs);
    received_signal = received_signal(1:num);
end

function [d1, d2, dn] = get_distance(u1, u2, so, J)
    %% 获取各传感器到信号源的距离
    % input:
    % u1: 信号源1坐标
    % u2: 信号源2坐标
    % so: 传感器坐标
    % output:
    % d1: 传感器到信号源1的距离
    % d2: 传感器到信号源2的距离
    % dn: 传感器到干扰源的距离
    d1 = sqrt(sum((so - u1') .^ 2));
    d2 = sqrt(sum((so - u2') .^ 2));
    dn = sqrt(sum((so - J') .^ 2));
end

function signal = scale_pow(signal, Pow)
    %% 修改信号功率
    % input:
    % signal: 信号
    % Pow: 信号功率
    % output:
    % signal: 修改后的信号
    current_power_dBmW = 10 * log10(mean(abs(signal) .^ 2));
    % Calculate the scaling factor to achieve the desired power
    scaling_factor = 10 ^ ((Pow - current_power_dBmW) / 10);
    % Scale the signal to the desired power level
    signal = signal * sqrt(scaling_factor);
end

function fspl_dB = calculate_FSPL(distance, frequency)
    %% 计算自由空间传播损耗
    % input:
    % distance: 传播距离 (km)
    % frequency: 信号频率 (MHz)
    % output:
    % fspl_dB: 自由空间传播损耗
    fspl_dB = 20 * log10(distance) + 20 * log10(frequency) + 32.45;
end

function dt = cal_dt(refer_signal, signals, fs)
    n = size(signals, 1);
    dt = zeros(1, n);

    for i = 1:n
        [cofs, lags] = xcorr(refer_signal, signals(i, :), 'coeff');
        [~, idx] = max(cofs);
        offset = lags(idx);
        dt(i) = offset / fs;
    end

end

function plot_xcorr(refer_signal, signals, title_str)
    n = size(signals, 1);

    for i = 1:n
        [cofs, lags] = xcorr(refer_signal, signals(i, :), 'coeff');
        subplot(3, 2, i);
        plot(lags, real(cofs));
        title("Sensor " + i + "&1 " + title_str);
    end

end

function plot_spectrum(signal, Fs, title_str)
    N = length(signal);
    f = (Fs / N:Fs / N:N * Fs / N) - Fs / 2; %图形的横轴线频率
    plot(f, 20 * log(fftshift(abs(fft(signal(1:N), N)))));
    title(title_str);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    grid on;
end

function plot_iq(signal, Fs, title_str)
    t = 0:1 / Fs:(length(signal) - 1) / Fs; % 时间向量，采样率为Fs
    I = real(signal);
    Q = imag(signal);
    % 绘制时域 IQ 波形图
    plot(t, I, 'r', 'LineWidth', 2, 'DisplayName', 'I');
    hold on;
    plot(t, Q, 'b', 'LineWidth', 2, 'DisplayName', 'Q');
    title(title_str);
    xlabel('时间（秒）');
    ylabel('幅度');
    legend('show');
    grid on;
end
