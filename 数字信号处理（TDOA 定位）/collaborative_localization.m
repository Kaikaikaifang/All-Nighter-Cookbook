function Za_collaborative = collaborative_localization(BSN, BS, R, max_iterations, convergence_threshold)
    %% 协作定位算法
    % input:
    %   BSN: 基站个数
    %   BS: 基站坐标
    %   R: 由 tdoa 计算得到的距离差
    %   max_iterations: 最大迭代次数
    %   convergence_threshold: 收敛阈值
    % output:
    %   Za_collaborative: 估计位置

    % 通过Chan算法获取初始位置估计
    Za_init = chan_algorithm(BSN, BS, R);

    % 通过Taylor算法进一步优化位置估计
    Za_collaborative = taylor_algorithm(BS, R, Za_init, max_iterations, convergence_threshold);
    Za_collaborative = Za_collaborative';
end
