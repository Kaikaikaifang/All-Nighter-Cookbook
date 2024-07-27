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
data1 = randi([0 1], 1, round(T * B(1))); % Random QPSK data
%scatterplot(qpskSignal); % 显示星座图
b = rcosdesign(alpha1, span, sps);
Sig1 = upfirdn(data1, b, sps); %成型滤波
