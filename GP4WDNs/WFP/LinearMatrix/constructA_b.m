function [A,b,C_estimate_b] = constructA_b(ForConstructA,ForConstructb,Demand,X0,base,IndexInVar,FCVValveDynamicStatus,FCVValveSettings)

%% construct A
A = [];
b = [];
% demand part
DemandA_part1 = zeros(ForConstructA.JunctionCount,ForConstructA.h_end_index);
DemandA = [DemandA_part1 ForConstructA.MassMatrix];

A = [A;DemandA];
b = [b;Demand'];

% fixed tank part

TankHeadIndex = ForConstructA.TankHeadIndex;
[~,m] = size(TankHeadIndex);
[~,n] = size(DemandA);
TankA = zeros(m,n);
for i=1:m
    TankA(i,TankHeadIndex(i)) = 1;
end

A = [A; TankA];
b = [b; X0(TankHeadIndex)];

% fixed reservoir part

ReservoirHeadIndex = ForConstructA.ReservoirHeadIndex;
[~,m] = size(ReservoirHeadIndex);
[~,n] = size(DemandA);
ReservoirA = zeros(m,n);
for i=1:m
    ReservoirA(i,ReservoirHeadIndex(i)) = 1;
end

A = [A; ReservoirA];
b = [b; X0(ReservoirHeadIndex)];

% pipe part
FlowCount=ForConstructA.PipeCount+ForConstructA.PumpCount+ForConstructA.FCVValveCount;
PipeA_part2 =  zeros(ForConstructA.PipeCount,FlowCount);
for i=1:ForConstructA.PipeCount
    PipeA_part2(i,i) = -1;
end
PipeA = [ForConstructA.EnergyPipeMatrix PipeA_part2];

A = [A; PipeA];
C_estimate_b = CEstimateLinear_b(ForConstructb,X0);
b = [b;C_estimate_b];
% pump part
% getting initial values
PumpA_part2 = [];
PumpA=[];
C_1M =[];
PumpEquation = ForConstructb.PumpEquation;
if(~isempty(PumpEquation))
    h0_vector = PumpEquation(:,1);
    r_vector = PumpEquation(:,2);
    w_vector = PumpEquation(:,3);
    
    s = X0(ForConstructb.s_start_index:ForConstructb.s_end_index);
    q_pump = X0(ForConstructb.q_pump_start_index:ForConstructb.q_pump_end_index);
    for xxx=1:ForConstructA.PumpCount
        if(q_pump(xxx)<0)
            q_pump(xxx) = 0;
        end
    end
    
    
    C_1M = -h0_vector.*(s.^2);
    C_2M = -r_vector.* q_pump.^(w_vector-1).* s.^(2-w_vector);
    
    
    PumpA_part2 =  zeros(ForConstructA.PumpCount,FlowCount);
    for i=1:ForConstructA.PumpCount
        PumpA_part2(i,ForConstructA.PipeCount+i) = -C_2M(i);
    end
    PumpA = [ForConstructA.EnergyPumpMatrix PumpA_part2];
end

A = [A; PumpA];
b = [b;C_1M];




% FCV valve part
EnergyFCVValveMatrix = ForConstructA.EnergyFCVValveMatrix;
HeadCount = ForConstructA.JunctionCount+ForConstructA.ReservoirCount+ForConstructA.TankCount;
FlowCount = ForConstructA.PipeCount+ForConstructA.PumpCount+ForConstructA.FCVValveCount;
FCVMinorLossCoeff = ForConstructA.FCVMinorLossCoeff;
FCVValveFlowIndex = IndexInVar.FCVValveFlowIndex;
FCVA_part2 = [];
for i = 1:ForConstructA.FCVValveCount
    if(FCVValveDynamicStatus(i) == 1) % open status; should add head loss = 0;
        FCVA_part2 = zeros(1,FlowCount);
        if(FCVMinorLossCoeff(i)) % not zero
            FCVA_part2(i,ForConstructA.PipeCount+ForConstructA.PumpCount+i) = -1;
        else % losscoeff is 0
            ; % do nothing
        end
        FCVA1 = [EnergyFCVValveMatrix(i,:) FCVA_part2];
        A = [A;FCVA1];
        FCV_estimate_b = FCVEstimate_b(ForConstructb,X0);
        if(FCVMinorLossCoeff(i)) % not zero
            b = [b;FCV_estimate_b];
        else % losscoeff is 0
            b = [b;0];
        end
        
    else % active status: should add q = q_set constraints
        FCVA2 = zeros(1,HeadCount + FlowCount);
        FCVA2(FCVValveFlowIndex(i)) = 1;
        A = [A;FCVA2];
        b = [b;FCVValveSettings(i)];
    end
end

