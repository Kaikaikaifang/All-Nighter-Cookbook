%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% @project        : 16 QAM
% @file           : AWGN16QAM.m
% @dir            : /src
% @date           : 2024/04/29
% @author         : Kaikai
% @brief          : 16QAM信号高斯信道下的误码率分析
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
close all
clear

%% 参数定义
SNR = 0:1:20; % 信噪比变化范围
N = 10000; % 仿真点数
M = 16; % 16QAM
BER = zeros(1, length(SNR)); % 误码率
SER = zeros(1, length(SNR)); % 符号错误率
% 定义 16QAM 的 I/Q 映射表
iq_map = [
          0.866025 0.500000;
          0.500000 0.866025;
          1.000000 0.000000;
          0.258819 0.258819;
          -0.500000 0.866025;
          0.000000 1.000000;
          -0.866025 0.500000;
          -0.258819 0.258819;
          0.500000 -0.866025;
          0.000000 -1.000000;
          0.866025 -0.500000;
          0.258819 -0.258819;
          -0.866025 -0.500000;
          -0.500000 -0.866025;
          -1.000000 0.000000;
          -0.258819 -0.258819
          ];

% 星座图
for i=1:5:length(SNR)
    data_sig = randi([0, M - 1], 1, N); % 产生随机信号
    qam_sig = qam16mod(data_sig, iq_map); % 16QAM调制
    qam_noise_sig = awgn(qam_sig, SNR(i), 'measured'); % 高斯信道
    scatterplot(qam_noise_sig);
    grid on;
    title(sprintf('SNR = %d', SNR(i)));
end



%% 主循环：不同信噪比下的误码率分析
for i = 1:length(SNR)
    fprintf('SNR = %d dB\n', SNR(i));
    N_0 = 1 / (10 ^ (SNR(i) / 10)); % 计算噪声功率
    N_err = 0; % 计数错误比特数
    N_err_sym = 0; % 计数错误符号数
    times = 0; % 计数仿真次数

    %% 子循环：误码率计算
    while N_err < 50000 && times < 50
        fprintf('times = %d N_err = %d N_err_sym = %d\n', times, N_err, N_err_sym);
        data_sig = randi([0, M - 1], 1, N); % 产生随机信号
        qam_sig = qam16mod(data_sig, iq_map); % 16QAM调制
        qam_noise_sig = awgn(qam_sig, SNR(i), 'measured'); % 高斯信道
        qamde_sig = qam16demod(qam_noise_sig, iq_map); % 16QAM解调
        % 错误数量统计
        [n_error_bits] = biterr(data_sig, qamde_sig); % 计算错误比特数
        N_err = N_err + n_error_bits; % 累计错误比特数
        [n_error_sym] = symerr(data_sig, qamde_sig); % 计算错误符号数
        N_err_sym = N_err_sym + n_error_sym; % 累计错误符号数
        times = times + 1;
    end

    % 计算误码率
    BER(i) = N_err / (times * N * 4);
    SER(i) = N_err_sym / (times * N);
    fprintf('BER = %f SER = %f\n', BER(i), SER(i));
end

%% 绘制图形
% 误码性能曲线
figure(1);
subplot(2, 1, 1);
plot(SNR, BER, [':', '*']);
xlabel('信噪比（dB）'); ylabel('BER');
title('比特错误概率');
subplot(2, 1, 2);
plot(SNR, SER, ['r', ':', 'diamond']);
xlabel('信噪比（dB）'); ylabel('SER');
grid on;
title('符号错误概率');
% 性能对比曲线
figure(2);
plot(SNR, BER, [':', '*'], SNR, SER, [':', 'diamond']);
legend('BER', 'SER'); xlabel('信噪比（dB）'); ylabel('BER/SER');
grid on;
title('性能仿真曲线');
% 星座图
scatterplot(qam_noise_sig);
grid on;
title('16QAM 星座图');

%% 16QAM调制
function [qam_sig] = qam16mod(data_sig, iq_map)
    qam_sig = iq_map(data_sig + 1, 1) + 1i * iq_map(data_sig + 1, 2); % 16QAM调制
end

%% 16QAM解调
function [qamde_sig] = qam16demod(qam_sig, iq_map)
    % 初始化解调后的信号向量
    qamde_sig = zeros(1, length(qam_sig));
    % 解调信号
    for i = 1:length(qam_sig)
        % 计算接收到的I/Q值与映射表中每个点的距离
        distances = sqrt((qam_sig(i) - (iq_map(:, 1) + 1i * iq_map(:, 2))) .^ 2);
        % 找到距离最近的映射点的索引
        [~, closest_point_index] = min(distances);
        % 将索引转换为信号向量中的符号序号
        qamde_sig(i) = closest_point_index - 1;
    end

end
