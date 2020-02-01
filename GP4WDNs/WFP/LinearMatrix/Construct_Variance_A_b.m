function [A,b] = Construct_Variance_A_b(MassEnergyMatrixStruct,ForConstructA,Variance,K_pipe,K_pump)

%% Construct A and b matrix

%     variable =
%     [ variance of head of Junction;
%       variance of head of reservior;
%       variance of head of tank;
%       variance of flow of pipe;
%       variance of flow of pump;
%       variance of flow of valve;
%    ]
MassMatrix = MassEnergyMatrixStruct.MassMatrix;
EnergyPipeMatrix = MassEnergyMatrixStruct.EnergyPipeMatrix;
EnergyPumpMatrix = MassEnergyMatrixStruct.EnergyPumpMatrix;
EnergyValveMatrix = MassEnergyMatrixStruct.EnergyValveMatrix;

% Construct the A matrix for demand
Variance_Demand_A = MassMatrix;
DemandA_part1 = zeros(ForConstructA.JunctionCount,ForConstructA.h_end_index);
DemandA = [DemandA_part1 Variance_Demand_A];

% Construct the A matrix for pipes
% pipe part
FlowCount=ForConstructA.PipeCount+ForConstructA.PumpCount+ForConstructA.ValveCount;
PipeA_part2 =  zeros(ForConstructA.PipeCount,FlowCount);
for i=1:ForConstructA.PipeCount
    PipeA_part2(i,i) = -1*(K_pipe(i))^2;
end
PipeA = [EnergyPipeMatrix PipeA_part2];

% Construct the A matrix for pumps

PumpA_part2 =  zeros(ForConstructA.PumpCount,FlowCount);
for i=1:ForConstructA.PumpCount
    PumpA_part2(i,ForConstructA.PipeCount+i) = (K_pump(i))^2;
end
PumpA = [EnergyPumpMatrix PumpA_part2];

% Construct the A matrix for valves TODO

% fixed tank part

TankHeadIndex = ForConstructA.TankHeadIndex;
[~,m] = size(TankHeadIndex);
[~,n] = size(DemandA);
TankA = zeros(m,n);
for i=1:m
    TankA(i,TankHeadIndex(i)) = 1;
end

% fixed reservoir part

ReservoirHeadIndex = ForConstructA.ReservoirHeadIndex;
[~,m] = size(ReservoirHeadIndex);
[~,n] = size(DemandA);
ReservoirA = zeros(m,n);
for i=1:m
    ReservoirA(i,ReservoirHeadIndex(i)) = 1;
end

% construct A done

A = [DemandA;PipeA;PumpA;TankA;ReservoirA];



%% construnct b

% demand part 
b = [];
b = [b;Variance];

VarianceofLinearization = zeros(ForConstructA.NumofX-ForConstructA.JunctionCount,1);

b = [b;VarianceofLinearization];
end