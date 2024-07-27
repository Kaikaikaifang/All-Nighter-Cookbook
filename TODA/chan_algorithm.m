function out = chan_algorithm(BSN, BS, R)
    %% TDOA CHAN 算法
    % input:
    %   BSN: 基站数量
    %   BS: 基站坐标
    %   R: 接收信号到达距离差
    % output:
    %   out: 估计位置

    % 噪声功率：
    Q = eye(BSN - 1); % (BSN-1,BSN-1)

    % 第一次LS：
    K1 = 0;

    for i = 1:BSN - 1
        K(i) = BS(1, i + 1) ^ 2 + BS(2, i + 1) ^ 2 + BS(3, i + 1) ^ 2; % x^2+y^2+z^2, K(1,BSN-1)
    end

    % Ga (BSN-1,4)
    for i = 1:BSN - 1
        Ga(i, 1) = -BS(1, i + 1);
        Ga(i, 2) = -BS(2, i + 1);
        Ga(i, 3) = -BS(3, i + 1); % 新增
        Ga(i, 4) = -R(i);
    end

    % h (1,BSN-1) 论文中转置就好
    for i = 1:BSN - 1
        h(i) = 0.5 * (R(i) ^ 2 - K(i) + K1);
    end

    % 由（14b）给出B的估计值：(4,1)
    Za0 = pinv(Ga' * pinv(Q) * Ga) * Ga' * pinv(Q) * h';

    % 利用这个粗略估计值计算B：(BSN-1,BSN-1)
    B = eye(BSN - 1);

    for i = 1:BSN - 1
        B(i, i) = sqrt((BS(1, i + 1) - Za0(1)) ^ 2 + (BS(2, i + 1) - Za0(2)) ^ 2 + (BS(3, i + 1) - Za0(3)) ^ 2); % 第三项
    end

    % FI: (BSN-1,BSN-1)
    FI = B * Q * B;

    % 第一次LS结果：(BSN-1,1)
    Za1 = pinv(Ga' * pinv(FI) * Ga) * Ga' * pinv(FI) * h';

    if Za1(4) < 0 % Za1(3)改为Za1(4)
        Za1(4) = abs(Za1(4));
        %     Za1(4) = 0;
    end

    % 第二次LS：
    % 第一次LS结果的协方差：(4,4)
    CovZa = pinv(Ga' * pinv(FI) * Ga);

    % sB：
    sB = eye(4); % (4,4)

    for i = 1:4
        sB(i, i) = Za1(i);
    end

    % sFI：
    sFI = 4 * sB * CovZa * sB; % (4,4)

    % sGa：
    sGa = [1, 0, 0; 0, 1, 0; 0, 0, 1; 1, 1, 1]; % 改掉 (4,3)

    % sh
    sh = [Za1(1) ^ 2; Za1(2) ^ 2; Za1(3) ^ 2; Za1(4) ^ 2]; % 多了第四项 (4,1)

    % 第二次LS结果：
    Za2 = pinv(sGa' * pinv(sFI) * sGa) * sGa' * pinv(sFI) * sh; % (3,1)

    Za = sqrt(Za2);
    out = abs(Za);
end
