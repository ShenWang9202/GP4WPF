clc;
clear;
close all;
TestCase = 0;
base = 1.001;

if(TestCase == 0)
    %inpname='zeroflowfail.inp';
    %inpname='ZerosFlow8node.inp';
    inpname='zeroflow.inp';
        acc = 5;
end

if(TestCase == 1)
    %inpname='Anytown2.inp';
    inpname='AnytownModify2.inp';
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
        acc = 3;
end


[d,IndexInVar,InitialParameter,SettingsNStatus,ForConstructA,ForConstructb,Variable_Symbol_Table,Solution] = PrepareA(inpname,TestCase);
%load('forctown')
BarSolution=[];
BarSolution=[BarSolution Solution(:,1)];

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
    X0(IndexInVar.PumpFlowIndex) = 0;%InitialParameter.PipeFLowAverage(IndexInVar.PumpFlowIndex)*LPS2GMP;
    X0(IndexInVar.PipeFlowIndex) = 0;%InitialParameter.PipeFLowAverage(IndexInVar.PipeFlowIndex)*LPS2GMP;%(-1+rand(1,1)*(2));
    X0(IndexInVar.FCVValveFlowIndex) = 0;%InitialParameter.PipeFLowAverage(IndexInVar.FCVValveFlowIndex)*LPS2GMP;
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
    tic
   % while (IterateError > 0.1 & index < 200)
    while (IterateError > 0.05)
        DEMAND=demand;
        [A,b,C_estimate_b] = constructA_b(ForConstructA,ForConstructb,DEMAND,X0,base,IndexInVar,FCVValveDynamicStatus,FCVValveSettings);
        %W = inv(A'*A)*A'*b;
        %W = inv(A)*b;
        C_estimate = [C_estimate;C_estimate_b];
        W = A\b;
        W= [W;Solution(IndexInVar.PumpSpeedIndex,i)];
        Wsolution = [Wsolution W];
        X0 = W;
%         if(index>4 & mod(index,4)==0)
%             tendency = Wsolution(:,index) - Wsolution(:,index-2);
%             % TO DO  this 1 here should be decide the program automatically.
%             % -  0.01* index
%             X0 = X0 + acc * tendency(:,1);
%         end
        if(ForConstructA.FCVValveCount)
            FCVValveDynamicStatus = UpdateValveStatus(IndexInVar,FCVValveDynamicStatus,FCVValveSettings,W);
            ValveDynamicStatus = [ValveDynamicStatus; FCVValveDynamicStatus];
        end
        DeltaError = abs(Wsolution(flowindex,end)-Wsolution(flowindex,end-1));
        DeltaError = sum(DeltaError);
        FlowSum = sum(abs(Wsolution(flowindex,end)));
        IterateError = norm(Wsolution(:,end)-Wsolution(:,end-1));
        %IterateError = DeltaError/FlowSum;
        Error = [Error;IterateError];
        index = index + 1;
    end
end
toc
BarSolution=[BarSolution Wsolution(:,end)];
i=1;
Solution1(IndexInVar.JunctionHeadIndex) = Solution(IndexInVar.JunctionHeadIndex,i)*M2FT;
Solution1(IndexInVar.ReservoirHeadIndex) = Solution(IndexInVar.ReservoirHeadIndex,i)*M2FT;
Solution1(IndexInVar.TankHeadIndex) = Solution(IndexInVar.TankHeadIndex,i)*M2FT;
Solution1(IndexInVar.PumpSpeedIndex) = Solution(IndexInVar.PumpSpeedIndex,i);
Solution1(IndexInVar.PumpFlowIndex) = Solution(IndexInVar.PumpFlowIndex,i)*LPS2GMP;
Solution1(IndexInVar.PipeFlowIndex) =  Solution(IndexInVar.PipeFlowIndex,i)*LPS2GMP;
Solution1(IndexInVar.FCVValveFlowIndex) =  Solution(IndexInVar.FCVValveFlowIndex,i)*LPS2GMP;


ErrorWithEpanet = [];
[~,n] = size(Wsolution)
for i= 1:n
    ErrorWithEpanet = [ErrorWithEpanet;norm(Wsolution(:,i)-Solution1')];
end


figure;
plot(C_estimate','DisplayName','C_estimate')

% plot convergence and C_P
fontsize = 40;
figure1 = figure;
% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

pl1=plot(log10(ErrorWithEpanet),'LineWidth',5);
% Create xlabel
xlabel('Iteration','Interpreter','latex');

% Create ylabel
ylabel('Error','Interpreter','latex');

box(axes1,'on');
% Set the remaining axes properties
set(axes1,'FontSize',40,'TickLabelInterpreter','latex','YTick',[-1 1 3 4]);
% Create legend
legend1 = legend([pl1],'$\log_{10}(||\boldmath \xi_{\mathrm{SE}}-\boldmath \xi_{\mathrm{EPANET}}||)$');
set(legend1,'Interpreter','latex','FontSize',50,'FontName','Helvetica Neue',...
    'Location','best');
set(gca,'FontSize',40,'TickLabelInterpreter','latex','YTick',[-1  4]);
hold off
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 18 6])
print(figure1,'errorEPANET','-depsc2','-r300');

