function [A,b,K_estimate] = constructLinearTheory_A_b(ForConstructA,ForConstructb,Demand,X0,IndexInVar,Linear_pump,ReserviorHead,TankHead)

%% construct A b
A = [];
b = [];
% demand part
MassMatrix = ForConstructA.MassMatrix;
A = [A;MassMatrix];
b = [b;Demand'];

LoopMatrix = ForConstructA.LoopMatrix;
K_pipe = KEstimateLinear(ForConstructb,X0);
K_pump = Linear_pump(1);
b_pump = Linear_pump(2);
K_estimate = [K_pipe K_pump];
[m,~] = size(LoopMatrix);
for i = 1:m
    LoopMatrix(i,:) = LoopMatrix(i,:).*K_estimate;
end

A = [A;LoopMatrix];

b = [b;0;0];
b_virtual_loop = ReserviorHead - TankHead + b_pump;
b = [b; b_virtual_loop];
end

