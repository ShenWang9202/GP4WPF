clc;
clear;
close all;
TestCase = 5;

if(TestCase == 1)
    inpname='tutorial8node.inp';
end

if(TestCase == 5)
    %inpname='tutorial5node.inp';
    %inpname='tutorial8node.inp';
    inpname='tutorial_lps_prv.inp';
end

if(TestCase == 7)
   inpname='Threenodes-gp.inp';
   %inpname='tutorial4price19_copy.inp';
end

[d,InitialParameter,SettingsNStatus,IndexInVar,...
    MassEnergyMatrix4GP,Variable_Symbol_Table,Solution]=Prepare(inpname,TestCase);

BarSolution=[];
BarSolution=[BarSolution Solution(:,1)];

%% sufficient scenario.
Demand_known=InitialParameter.Demand_known;
[m,n] = size(Demand_known);
Error_All = cell(n,1);
Relative_Error_All = [];
IterateError_All = [];
XSolution = [];

M2FT = InitialParameter.M2FT;
LPS2GMP = InitialParameter.LPS2GMP;
NumberofX = IndexInVar.NumberofX;
for i = 1:1
    %% initial conditions
    X0 = zeros(IndexInVar.NumberofX,1);
    %     X0(JunctionHeadIndexInVar) = Solution(JunctionHeadIndexInVar,i);
    X0(IndexInVar.ReservoirHeadIndex) = Solution(IndexInVar.ReservoirHeadIndex,i)*M2FT;
    X0(IndexInVar.TankHeadIndex) = Solution(IndexInVar.TankHeadIndex,i)*M2FT;
    X0(IndexInVar.PumpSpeedIndex) = Solution(IndexInVar.PumpSpeedIndex,i);
    %     X0(IndexInVar.PumpFlowIndex) = Solution(IndexInVar.PumpFlowIndex,i)*LPS2GMP;
    %     X0(IndexInVar.PumpFlowIndex) = Solution(IndexInVar.PumpFlowIndex,i)*LPS2GMP;
    %     X0(IndexInVar.ValveFlowIndex) = Solution(IndexInVar.ValveFlowIndex,i)*LPS2GMP;
    X0(IndexInVar.PumpFlowIndex) = InitialParameter.PipeFLowAverage(IndexInVar.PumpFlowIndex)*LPS2GMP;
    X0(IndexInVar.PipeFlowIndex) = InitialParameter.PipeFLowAverage(IndexInVar.PipeFlowIndex)*LPS2GMP;
    X0(IndexInVar.ValveFlowIndex) = InitialParameter.PipeFLowAverage(IndexInVar.ValveFlowIndex)*LPS2GMP;
    % make sure the flow of pump is greater than 0; can not be negative
    %X0(IndexInVar.PumpFlowIndex) = 1;% make sure the flow of pump is greater than 0; can not be negative
    X0
    Wsolution = [];
    Wsolution = [Wsolution;X0];
    C_estimate = [];
    Error =[];
    demand = Demand_known(:,i)';
    index = 1;
    IterateError = 10;
    while (IterateError > 0.1)
        DEMAND=demand;
        
        cvx_begin
        variables W(NumberofX)
        % objective function is the box volume
        minimize( 0) % suppose delta_h2  is much more accurate.
        subject to
        % conservation of mass;
        [CvxExpMass,DemandVector] = FlowConstLinear(W,MassEnergyMatrix4GP.MassMatrixIndexCell,DEMAND,IndexInVar);
        %DemandVector
        CvxExpMass == DemandVector
        % Tank 
        [CvxExpFixed,FixedValueVector] = FixedTankConstLinear(W,X0,IndexInVar);
        %  Reservoir
        CvxExpFixed == FixedValueVector;
        [CvxExpFixed,FixedValueVector] = FixedReservoirConstLinear(W,X0,IndexInVar);
        %FixedValueVector;
        CvxExpFixed == FixedValueVector;
        % pump
        % Flow through Pumps are non-negatvie
        ind = 1;
        for j = IndexInVar.PumpFlowIndex
            if(SettingsNStatus.PumpStatus(ind)==1) % if the pump is open
                W(j) >= 0
            end
            if(SettingsNStatus.PumpStatus(ind)==0)
                W(j) == 0
            end
            ind = ind + 1;
        end
        % speed
        ind = 1;
        for j = IndexInVar.PumpSpeedIndex
            if(SettingsNStatus.PumpStatus(ind)==1)
                W(j) == 1
            end
            if(SettingsNStatus.PumpStatus(ind)==0)
                W(j) == 0
            end
            ind = ind +1;
        end
        
        % pump model
        [CvxExpPump,ZeorVector] = PressurePumpConstLinear(W,MassEnergyMatrix4GP.EnergyPumpMatrixIndex,X0,SettingsNStatus.PumpStatus,IndexInVar);
        CvxExpPump == ZeorVector
        
        % Pipe head loss
        
        [CvxExpHeadLoss,CEstimateVetor] = PressurePipeConstLinear(W,MassEnergyMatrix4GP.EnergyPipeMatrixIndex,X0,d,IndexInVar);
        C_estimate = [C_estimate CEstimateVetor];
        CvxExpHeadLoss == CEstimateVetor
        cvx_end
        
        % cvx end
        Wsolution = [Wsolution W];
        X0 = W;
        if(mod(index,4)==0)
            tendency = Wsolution(:,index) - Wsolution(:,index-2);
            % TO DO  this 1 here should be decide the program automatically.
            acc = 3;%1 + 0.2* index;
            X0 = X0 + acc * tendency(:,1);
        end
        IterateError = norm(Wsolution(:,end)-Wsolution(:,end-1));
        Error = [Error;IterateError];
        index = index + 1;
    end
end

BarSolution=[BarSolution Wsolution(:,end)];
i=1;
Solution1(IndexInVar.JunctionHeadIndex) = Solution(IndexInVar.JunctionHeadIndex,i)*M2FT;
Solution1(IndexInVar.ReservoirHeadIndex) = Solution(IndexInVar.ReservoirHeadIndex,i)*M2FT;
Solution1(IndexInVar.TankHeadIndex) = Solution(IndexInVar.TankHeadIndex,i)*M2FT;
Solution1(IndexInVar.PumpSpeedIndex) = Solution(IndexInVar.PumpSpeedIndex,i);
Solution1(IndexInVar.PumpFlowIndex) = Solution(IndexInVar.PumpFlowIndex,i)*LPS2GMP;
Solution1(IndexInVar.PipeFlowIndex) =  Solution(IndexInVar.PipeFlowIndex,i)*LPS2GMP;
Solution1(IndexInVar.ValveFlowIndex) =  Solution(IndexInVar.ValveFlowIndex,i)*LPS2GMP;


ErrorWithEpanet = [];
[~,n] = size(Wsolution)
for i= 1:n
    ErrorWithEpanet = [ErrorWithEpanet;norm(Wsolution(:,i)-Solution1')];
end

