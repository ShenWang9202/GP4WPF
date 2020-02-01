% plot flow bar for C-TOWN result in WFP journal, the .mat file is in Ctown
% branch not here.
% clear;
% load('Ctown_500_1000.mat')
% 
% GP =[];



GP(IndexInVar.JunctionHeadIndex) = X(IndexInVar.JunctionHeadIndex,end)/M2FT;
GP(IndexInVar.ReservoirHeadIndex) = X(IndexInVar.ReservoirHeadIndex,end)/M2FT;
GP(IndexInVar.TankHeadIndex) = X(IndexInVar.TankHeadIndex,end)/M2FT;
GP(IndexInVar.PumpFlowIndex) = X(IndexInVar.PumpFlowIndex,end)/LPS2GMP;
GP(IndexInVar.PipeFlowIndex) = X(IndexInVar.PipeFlowIndex,end)/LPS2GMP;
GP(IndexInVar.ValveFlowIndex) = X(IndexInVar.ValveFlowIndex,end)/LPS2GMP;
GP(IndexInVar.PumpSpeedIndex) = X(IndexInVar.PumpSpeedIndex,end);

GP = GP';

EPANET=Solution(:,1);

error_distr = EPANET - GP;

fontsize = 80;
figure2 = figure;

% Create axes
%axes2 = axes('Parent',figure2);
h1=histogram(error_distr,30);
h1.BinWidth = 0.1;
h1.FaceColor = [0.6350 0.0780 0.1840];

xlabel('AE','FontSize',fontsize+3,'interpreter','latex');
ylim([0 700])
ylabel('Instances','FontSize',fontsize+2,'interpreter','latex');

set(gca, 'TickLabelInterpreter', 'latex','fontsize',fontsize);

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 8])
print(figure2,'error_distribution','-depsc2','-r300');
 


