clc;
clear;
close all;
TestCase = 19;
base = 1.001;
TotalTestTime = 100;
if(TestCase == 1)
    inpname='Anytown2.inp';
    %inpname='AnytownModify2.inp';
        acc = 5;
end

if(TestCase == 3)
    %inpname='tutorial5node.inp';
    inpname='ctownwithoutanyvalve.inp';
        acc = 3;
end


if(TestCase == 4)
    %inpname='tutorial5node.inp';
    inpname='tutorial8nodefcv100.inp';
    acc = 3;
end

if(TestCase == 5)
    %inpname='tutorial5node.inp';
    inpname='tutorial8node.inp';
    acc = 3;
end

if(TestCase == 6)
    %inpname='tutorial5node.inp';
    inpname='tutorial_lps_2PUMPS.inp';
       acc = 3;
end

if(TestCase == 17)
    %inpname='tutorial5node.inp';
    inpname='BAK1.inp';
    acc = 1;
end

if(TestCase == 18)
    %inpname='tutorial5node.inp';
    inpname='PES1.inp';
    acc = 1;
end

if(TestCase == 19)
    %inpname='tutorial5node.inp';
    inpname='EXN1.inp';
    acc = 3;
end

if(TestCase == 20)
    %inpname='tutorial5node.inp';
    inpname='NPCL1.inp';
       acc = 4;
end

if(TestCase == 21)
    %inpname='tutorial5node.inp';
    inpname='OBCL1.inp';
    acc = 1;
end


if(TestCase == 22)
    %inpname='tutorial5node.inp';
    inpname='tutorial_lps_valves.inp';
        acc = 3;
end
if(TestCase == 23)
    %inpname='tutorial5node.inp';
    inpname='Threenodes-gp.inp';
        acc = 1;
end


[d,IndexInVar,InitialParameter,SettingsNStatus,ForConstructA,ForConstructb,Variable_Symbol_Table,Solution] = PrepareA(inpname,TestCase);
%load('forctown')
BarSolution=[];
BarSolution=[BarSolution Solution(:,1)];

failTimes = [];

Demand_known=InitialParameter.Demand_known;
[m,n] = size(Demand_known);
Error_All = cell(n,1);
Relative_Error_All = [];
IterateError_All = [];
XSolution = [];
ValveDynamicStatus = [];
C_estimate = [];
M2FT = InitialParameter.M2FT;
LPS2GMP = InitialParameter.LPS2GMP;
NumberofX= ForConstructA.NumofX;

FCVValveDynamicStatus = SettingsNStatus.FCVValveDynamicStatus;
% FCVValveDynamicStatus = 2; if we know it is active, no need to calculate
% the status according to the overall network status.
FCVValveSettings = SettingsNStatus.FCVValveSettings;
FCVValveSettings = FCVValveSettings*LPS2GMP;
flowindex = ForConstructb.q_pipe_start_index:ForConstructb.q_pump_end_index;



PumpEquation = IndexInVar.PumpEquation;
PumpMax = []
PumpMin = []
if ~isempty(PumpEquation)
h0_pump = PumpEquation(:,1);
r_pump = -PumpEquation(:,2);
nu_pump = PumpEquation(:,3);
PumpMax = (h0_pump./r_pump).^(1./nu_pump);
PumpMin = 0;
end

 Headloss_pipe_R = PipeCoeff(ForConstructb)


[~,nSolution] = size(Solution)
if(nSolution == 1)
    PipeMax = abs(Solution(IndexInVar.PipeFlowIndex,:));
else
    PipeMax = max(abs(Solution(IndexInVar.PipeFlowIndex,:)));
end
PipeMin = -PipeMax;
SolutionCell = cell(1,TotalTestTime);
InitialValue = [];
Finalsolution = [];
for j= 1:TotalTestTime
for i = 1:1
    %% initial conditions
    X0 = zeros(NumberofX,1);
    %     X0(JunctionHeadIndexInVar) = Solution(JunctionHeadIndexInVar,i);
    X0(IndexInVar.ReservoirHeadIndex) = Solution(IndexInVar.ReservoirHeadIndex,i)*M2FT;
    X0(IndexInVar.TankHeadIndex) = Solution(IndexInVar.TankHeadIndex,i)*M2FT;
    X0(IndexInVar.PumpSpeedIndex) = Solution(IndexInVar.PumpSpeedIndex,i);
    %     X0(IndexInVar.PumpFlowIndex) = Solution(IndexInVar.PumpFlowIndex,i)*LPS2GMP;
    %     X0(IndexInVar.PumpFlowIndex) = Solution(IndexInVar.PumpFlowIndex,i)*LPS2GMP;
    %     X0(IndexInVar.FCVValveFlowIndex) = Solution(IndexInVar.FCVValveFlowIndex,i)*LPS2GMP;
    X0(IndexInVar.PumpFlowIndex) = ((PumpMax-PumpMin).*rand  + PumpMin)*LPS2GMP;
    X0(IndexInVar.PipeFlowIndex) = ((PipeMax-PipeMin).*rand  + PipeMin)*LPS2GMP;
    if j ==1
    X0(IndexInVar.PumpFlowIndex) = 0;
    X0(IndexInVar.PipeFlowIndex) = 0;
    end
    X0(IndexInVar.FCVValveFlowIndex) =0;%InitialParameter.PipeFLowAverage(IndexInVar.FCVValveFlowIndex)*LPS2GMP;
    % make sure the flow of pump is greater than 0; can not be negative
    %X0(IndexInVar.PumpFlowIndex) = 1;% make sure the flow of pump is greater than 0; can not be negative
    
    X0 = real(X0);
    Wsolution = [];
    X0
    disp('testing...')
    j
    Wsolution = [Wsolution;real(X0)];
    C_estimate = [];
    Error =[];
    demand = Demand_known(:,i)';
    index = 1;
    IterateError = 10;
    tic
   % while (IterateError > 0.1 & index < 200)
    while (IterateError > 0.25 &  index < 5000 )
        DEMAND=demand;
        [A,b,C_estimate_b] = constructA_b(ForConstructA,ForConstructb,DEMAND,X0,base,IndexInVar,FCVValveDynamicStatus,FCVValveSettings);
        %W = inv(A'*A)*A'*b;
        %W = inv(A)*b;
        C_estimate = [C_estimate;C_estimate_b];
        W = A\b;
        W= [W;Solution(IndexInVar.PumpSpeedIndex,i)];
        Wsolution = [Wsolution W];
        X0 = W;
%         if(index>3 & mod(index,4)==0)
%             tendency = Wsolution(:,index) - Wsolution(:,index-2);
%             % TO DO  this 1 here should be decide the program automatically.
%             % -  0.01* index
%             X0 = X0 + acc * tendency(:,1);
%         end
        if(ForConstructA.FCVValveCount)
            FCVValveDynamicStatus = UpdateValveStatus(IndexInVar,FCVValveDynamicStatus,FCVValveSettings,W);
            ValveDynamicStatus = [ValveDynamicStatus; FCVValveDynamicStatus];
        end
%         DeltaError = abs(Wsolution(flowindex,end)-Wsolution(flowindex,end-1));
%         DeltaError = sum(DeltaError);
%         FlowSum = sum(abs(Wsolution(flowindex,end)));
        IterateError = norm(Wsolution(:,end)-Wsolution(:,end-1));
        %IterateError = DeltaError/FlowSum;
        Error = [Error;IterateError];
        index = index + 1;
    end
    if(index >=5000)
        failTimes = [failTimes j];
    end
end
SolutionCell{1,j} = Wsolution([3,flowindex],1:end);
InitialValue = [InitialValue Wsolution(:,1)];
Finalsolution = [Finalsolution Wsolution(:,end)];


end
toc








