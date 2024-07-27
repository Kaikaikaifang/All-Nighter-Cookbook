# -*- coding: UTF-8 -*-
"""
@IDE            : VsCode
@Time           : 2024/06/08
@Project        : 信号检测大作业 - 2
@Introduction   : 仿真 BPSK 信道估计和检测性能
"""
import numpy as np
import matplotlib.pyplot as plt


def simulate_bpsk_channel(N: int, SNR_dB: int, h: float = None):
    """模拟 BPSK 信道

    Args:
        N (int): 信号长度
        SNR_dB (int): 信噪比
        h (float, optional): 衰落系数. Defaults to None.

    Returns:
        (ndarray[int], ndarray[float], float): 发送信号, 接收信号, 衰落系数
    """
    # 1. 生成发送信号 s_k
    # 若 h 为 None 生成 1010... 导频头
    s_k = (
        np.random.choice([-1, 1], N) if h is not None else np.array([1, -1] * (N // 2))
    )

    # 2. 生成信道衰落系数 h
    h = h if h is not None else np.random.rayleigh(scale=np.sqrt(0.5))

    # 3. 生成噪声
    # 3.1 计算信噪比 (功率表示)
    SNR_linear = 10 ** (SNR_dB / 10)
    # 3.2 计算标准差
    sigma_n = np.sqrt(np.mean(s_k**2) / SNR_linear)
    # 3.3 生成独立同分布的高斯噪声
    n_k = np.random.normal(0, sigma_n, N)

    # 4. 生成接收信号
    x_k = h * s_k + n_k

    return s_k, x_k, h


def estimate_h(s_k: np.ndarray, x_k: np.ndarray):
    """估计信道系数

    Args:
        s_k (ndarray): 发送信号
        x_k (ndarray): 接收信号

    Returns:
        float: 估计的信道系数
    """
    # 最大似然估计：最小化误差平方和
    return np.sum(s_k * x_k) / np.sum(s_k * s_k)


def detect_s(x_k: np.ndarray, h_est: float, s_true: np.ndarray):
    """相干检测

    Args:
        x_k (ndarray): 接收信号
        h_est (float): 估计的信道系数

    Returns:
        int: Bit Error Nums (误比特数目)
    """
    # 1. 估计发送信号
    s_est = np.sign(x_k / h_est)
    s_est[s_est == 0] = 1
    # 2. 统计误比特数目
    return np.sum(s_est != s_true)


def simulate_trials(M, SNR_range_dB, N=1000, num_trials=10000):
    """不同信噪比下的 BPSK 信道估计和性能检测仿真

    Args:
        M (int): 导频头长度
        SNR_range_dB (list[int]): 信噪比范围
        N (int, optional): 相干检测性能仿真信号长度. Defaults to 1000.
        num_trials (int, optional): 统计 MSE 与 BER 时的实验次数. Defaults to 10000.

    Returns:
        (list[float], list[float]): 不同信噪比下信道系数的 MSE 和信道的 BER
    """
    mse = []
    ber = []
    # 计算均方误差 (MSE) 和平均误比特率 (BER)
    for SNR_dB in SNR_range_dB:
        errors = []
        nums = 0
        times = 0
        while times < num_trials and nums < N * num_trials / 10:
            # 1. 借助导频头估计信道系数
            s_k, x_k, h_true = simulate_bpsk_channel(M, SNR_dB)

            h_est = estimate_h(s_k, x_k)
            # 2. 计算衰落系数均方误差
            error = (h_est - h_true) ** 2
            errors.append(error)
            # 3. 相干检测性能仿真
            s_k, x_k, _ = simulate_bpsk_channel(N, SNR_dB, h_true)
            # 4. 统计误比特数目
            nums += detect_s(x_k, h_est, s_k)
            times += 1
        mse.append(np.mean(errors))
        ber.append(nums / (times * N))
    return mse, ber


def calculate_crlb(M, SNR_range_dB):
    """计算不同信噪比下的 CRLB

    Args:
        M (int): 导频头长度
        SNR_range_dB (list[int]): 信噪比范围

    Returns:
        list[float]: 不同信噪比下信道系数的 CRLB
    """
    crlb = []
    for SNR_dB in SNR_range_dB:
        SNR_linear = 10 ** (SNR_dB / 10)
        crlb.append(1 / (M * SNR_linear))
    return crlb


def theoretical_ber(SNR_range_dB, variance_h=1, power_s=1):
    """计算理论 BER

    Args:
        SNR_range_dB (list[int]): 信噪比范围
        variance_h (int, optional): 信道系数的方差. Defaults to 1.
        power_s (int, optional): 发送信号的功率. Defaults to 1.

    Returns:
        list[float]: 不同信噪比下的理论 BER
    """
    SNR_linear = 10 ** (SNR_range_dB / 10)
    variance_n = power_s / SNR_linear
    SNR = variance_h / variance_n
    ber = 0.5 * (1 - np.sqrt(SNR / (1 + SNR)))
    return ber


# 参数定义
M_values = [10, 50, 100]
SNR_range_dB = np.linspace(0, 10, 11)

# 设置图表全局样式
plt.rcParams["figure.figsize"] = (10, 6)
# 设置颜色调色板
# custom_palette = ["#899CCB", "#F1C0C4", "#FBE7C0"]
custom_palette = ["#FA7F6F", "#8ECFC9", "#82B0D2"]
plt.rcParams["axes.prop_cycle"] = plt.cycler(color=custom_palette)
# 选择 monospace 字体
plt.rcParams["font.family"] = "monospace"
plt.rcParams["font.monospace"] = "Monaspace Xenon"
# 图表定义
mse_fig = plt.figure()
ber_fig = plt.figure()
markers = ["o", "^", "d"]

# 仿真不同导频头长度下的性能
for i, M in enumerate(M_values):
    mse, ber = simulate_trials(M, SNR_range_dB)
    crlb = calculate_crlb(M, SNR_range_dB)
    # 绘制图表
    plt.figure(mse_fig.number)
    plt.semilogy()
    plt.plot(
        SNR_range_dB,
        mse,
        label=f"M = {M} (MSE)",
        marker=markers[i],
        color=custom_palette[i],
    )
    plt.plot(
        SNR_range_dB,
        crlb,
        label=f"M = {M} (CRLB)",
        linestyle="--",
        marker=markers[i],
        color=custom_palette[i],
    )
    plt.figure(ber_fig.number)
    plt.plot(
        SNR_range_dB,
        ber,
        label=f"M = {M} (Simulated BER)",
        marker=markers[i],
        color=custom_palette[i],
    )

# 理论 BER
theory_ber = theoretical_ber(SNR_range_dB, variance_h=0.5, power_s=1)
plt.figure(ber_fig.number)
plt.plot(
    SNR_range_dB, theory_ber, label="Theoretical BER", linestyle="--", color="black"
)

# 图表设置
plt.figure(mse_fig.number)
plt.xlabel("SNR (dB)")
plt.ylabel("MSE")
plt.title("MSE of BPSK Channel Estimation vs SNR")
plt.legend()
plt.grid()

plt.figure(ber_fig.number)
plt.xlabel("SNR (dB)")
plt.ylabel("BER")
plt.title("BER of BPSK Channel Detection vs SNR")
plt.legend()
plt.grid()
plt.show()
