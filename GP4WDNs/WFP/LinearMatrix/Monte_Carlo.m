% Assume that each demand follow a normal distribution function, and we
% would like to see the the distribution of the states.
clc;
clear;
close all;
TestCase = 5;
base = 1.001;
if(TestCase == 1)
    %inpname='Anytown2.inp';
    inpname='AnytownModify2.inp';
    acc = 5;
end

if(TestCase == 3)
    %inpname='tutorial5node.inp';
    inpname='ctownwithoutanyvalve.inp';
    acc = 2;
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



[d,IndexInVar,InitialParameter,ForConstructA,ForConstructb,Variable_Symbol_Table,Solution] = PrepareA(inpname,TestCase);
%load('forctown')
BarSolution=[];
BarSolution=[BarSolution Solution(:,1)];

%% sufficient scenario.
Demand_known=InitialParameter.Demand_known;
[m,n] = size(Demand_known);
Error_All = cell(n,1);
Relative_Error_All = [];
IterateError_All = [];
XSolution = [];
MCSolution = [];

M2FT = InitialParameter.M2FT;
LPS2GMP = InitialParameter.LPS2GMP;
NumberofX= ForConstructA.NumofX;

MC_times = 500;

demand_I=[];
HeadIndex = IndexInVar.JunctionHeadIndex;
FlowIndex = [IndexInVar.PumpFlowIndex IndexInVar.PipeFlowIndex IndexInVar.ValveFlowIndex];
Variance=[];
demand_MC=[];
DemandIndex=[];
for i = 1:1
    demand_I = Demand_known(:,i)';
    [demand_MC,DemandIndex,Variance] = GenerateMCDemand(demand_I,MC_times,HeadIndex);
    for mt=1:MC_times % Monte Carlo 100 times.
        DEMAND=demand_MC(mt,:);
        %% initial conditions
        X0 = zeros(NumberofX,1);
        %     X0(JunctionHeadIndexInVar) = Solution(JunctionHeadIndexInVar,i);
        X0(IndexInVar.ReservoirHeadIndex) = Solution(IndexInVar.ReservoirHeadIndex,i)*M2FT;
        X0(IndexInVar.TankHeadIndex) = Solution(IndexInVar.TankHeadIndex,i)*M2FT;
        X0(IndexInVar.PumpSpeedIndex) = Solution(IndexInVar.PumpSpeedIndex,i);
        %     X0(IndexInVar.PumpFlowIndex) = Solution(IndexInVar.PumpFlowIndex,i)*LPS2GMP;
        %     X0(IndexInVar.PumpFlowIndex) = Solution(IndexInVar.PumpFlowIndex,i)*LPS2GMP;
        %     X0(IndexInVar.ValveFlowIndex) = Solution(IndexInVar.ValveFlowIndex,i)*LPS2GMP;
        X0(IndexInVar.PumpFlowIndex) = sum(Demand_known(:,i));%InitialParameter.PipeFLowAverage(IndexInVar.PumpFlowIndex)*LPS2GMP;
        X0(IndexInVar.PipeFlowIndex) = 0;%;InitialParameter.PipeFLowAverage(IndexInVar.PipeFlowIndex)*LPS2GMP*rand(1,1);%(-1+rand(1,1)*(2));
        X0(IndexInVar.ValveFlowIndex) = InitialParameter.PipeFLowAverage(IndexInVar.ValveFlowIndex)*LPS2GMP;
        % make sure the flow of pump is greater than 0; can not be negative
        %X0(IndexInVar.PumpFlowIndex) = 1;% make sure the flow of pump is greater than 0; can not be negative
        X0
        Wsolution = [];
        Wsolution = [Wsolution;X0];
        C_estimate = [];
        Error =[];
        index = 1;
        IterateError = 10;
        % while (IterateError > 0.1 & index < 200)
        while (IterateError > 0.1)% & index < 200)
            [A,b] = constructA_b(ForConstructA,ForConstructb,DEMAND,X0,base);
            W = inv(A'*A)*A'*b;
            %W = inv(A)*b;
            %W = A\b;
            W= [W;Solution(IndexInVar.PumpSpeedIndex,i)];
            Wsolution = [Wsolution W];
            X0 = W;
            if(mod(index,4)==0)
                tendency = Wsolution(:,index) - Wsolution(:,index-2);
                % TO DO  this 1 here should be decide the program automatically.
                % -  0.01* index
                X0 = X0 + acc * tendency(:,1);
            end
            IterateError = norm(Wsolution(:,end)-Wsolution(:,end-1));
            Error = [Error;IterateError];
            index = index + 1;
        end
        MCSolution = [MCSolution Wsolution(:,end)];
    end
end



deterministic = Solution(:,1);


% 
% ID_Index =  strings(1,NumberofX);
% for i = 1:NumberofX
%     ID_Index(i) = Variable_Symbol_Table{i,1};
% end
ID_Index = Variable_Symbol_Table(:,1);
demand_MC = demand_MC';
save('MonteCarloDemand.mat','DemandIndex','demand_MC','-v7');

save('MonteCarloData.mat','deterministic','HeadIndex','FlowIndex','ID_Index','MCSolution','-v7');

% call PlotMonteCarlo to plot the result (python version) .


% Matlab version

%plotMenteCarlo(Solution(:,1),MCSolution,IndexInVar,Variable_Symbol_Table);

