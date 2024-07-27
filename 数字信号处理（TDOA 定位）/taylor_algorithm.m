function Za_taylor = taylor_algorithm(BS, R, Za_init, max_iterations, convergence_threshold)
    %% 梯度下降算法
    % input:
    %   BS - 基站坐标矩阵
    %   R - 基站之间距离差向量
    %   Za_init - 初始位置
    %   max_iterations - 最大迭代次数
    %   convergence_threshold - 收敛阈值
    % output:
    %   Za_taylor - 位置估计

    % 初始位置
    Za_taylor = Za_init;

    % 迭代优化
    for iter = 1:max_iterations
        % 计算梯度
        gradient = compute_gradient(BS, R, Za_taylor);
        learning_rate = cos((pi / 2) * ((iter - 1) / max_iterations)); % 学习率递减
        % 更新位置估计
        Za_taylor = Za_taylor - learning_rate * gradient;
        % 判断是否收敛
        if norm(gradient) < convergence_threshold
            disp(['迭代次数：' num2str(iter) '. 梯度小于阈值，算法收敛，提前停止迭代。']);
            break;
        end

    end

end

function gradient = compute_gradient(BS, R, Za)
    %% 梯度计算
    % input:
    %   BS - 基站坐标矩阵
    %   R - 基站之间距离差向量
    %   Za - 位置估计
    % output:
    %   gradient - 梯度向量

    epsilon = 1e-6; % 微小的扰动值

    % 初始化梯度向量
    gradient = zeros(size(Za));

    % 对每个位置坐标分别计算梯度
    for i = 1:numel(Za)
        % 对每个坐标进行微小扰动
        Za_perturb = Za;
        Za_perturb(i) = Za_perturb(i) + epsilon;

        % 计算扰动后的损失函数值
        loss_perturb = compute_loss(BS, R, Za_perturb);

        % 计算原始损失函数值
        loss_original = compute_loss(BS, R, Za);

        % 计算该坐标的梯度
        gradient(i) = (loss_perturb - loss_original) / epsilon;
    end

end

function loss = compute_loss(BS, R, Za)
    %% 计算损失函数
    % input:
    %   BS - 基站坐标矩阵
    %   R - 基站之间距离差向量
    %   Za - 位置估计
    % output:
    %   loss - 损失函数值

    % 使用TDOA算法计算损失，可以根据具体应用选择其他损失函数
    estimated_distances = compute_distances(BS, Za);
    tmp_r = estimated_distances - estimated_distances(1);
    loss = sum((tmp_r(2:end) - R) .^ 2);
end

function distances = compute_distances(BS, Za)
    % 计算估计距离
    % 输入参数：BS - 基站坐标矩阵，Za - 位置估计
    % 输出：distances - 估计距离向量
    distances = sqrt(sum((BS - Za) .^ 2));
end
