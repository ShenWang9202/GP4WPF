
%% The following data is running in the lab for ctown with valves long time ago 
% X_500=load('Ctown_500.mat','X');
% X_500 = X_500.X;
% X_1000=load('Ctown_500_1000.mat','X');
% X_1000 = X_1000.X;
% Solution=load('Ctown_500_1000.mat','Solution');
% Solution = Solution.Solution;
% 
% load Ctown_500_1000.mat IndexInVar M2FT LPS2GMP
% 
% X = [X_500 X_1000];
%% Running PurelinearModeling first to get Wsolution from GP, and Solution from EPANET
X = Wsolution;
GP =[];
GP = [GP ;X(IndexInVar.JunctionHeadIndex,:)/M2FT];
GP = [GP ;X(IndexInVar.ReservoirHeadIndex,:)/M2FT];
GP = [GP ;X(IndexInVar.TankHeadIndex,:)/M2FT];
GP = [GP ;X(IndexInVar.PipeFlowIndex,:)/LPS2GMP];
GP = [GP ;X(IndexInVar.FCVValveFlowIndex,:)/LPS2GMP];
GP = [GP ;X(IndexInVar.PumpFlowIndex,:)/LPS2GMP];
GP = [GP ;X(IndexInVar.PumpSpeedIndex,:)];

EPANET = Solution(:,1);

[m,n]=size(GP);
EN = [];
ER = [];
REERROR = [];
for i = 1:n
    er = GP(:,i)-EPANET;
    reer = er./EPANET;
    REERROR = [REERROR reer];
    ER = [ER er];
    error = norm(GP(:,i)-EPANET);
    EN = [EN log(error)/log(10)];
end


%% plot Eculide Norm
fontsize = 60;
figure1 = figure;
% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

pl1=plot(EN,'LineWidth',5);
set(axes1,'FontSize',fontsize,'TickLabelInterpreter','latex');
% Create xlabel
xlabel('Iteration','Interpreter','latex','FontSize',fontsize);

% Create ylabel
ylabel('$\log_{10}(\boldmath \mathrm{EN})$','Interpreter','latex','FontSize',fontsize-5);

box(axes1,'on');
% Set the remaining axes properties

% Create legend
% legend1 = legend([pl1],'$\log_{10}(||\boldmath \xi_{\mathrm{GP-LP}}-\boldmath \xi_{\mathrm{EPANET}}||)$');
% set(legend1,'Interpreter','latex','FontSize',fontsize+5,'FontName','Helvetica Neue',...
%     'Location','best');
hold off
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 18 6])
print(figure1,'errorEPANET','-depsc2','-r300');


%% plot absolute error distribution

error_distr = abs(EPANET - GP(:,end));

figure2 = figure;

% Create axes
%axes2 = axes('Parent',figure2);
h1=histogram(error_distr,'Normalization','probability','FaceColor',[0 0.4470 0.7410],'BinWidth',0.06);
h1.Data
set(gca, 'TickLabelInterpreter', 'latex','fontsize',fontsize);
xlabel('Absolute Error','FontSize',fontsize,'interpreter','latex');
%ylim([0 700])
ylabel('Frequency','FontSize',fontsize-5,'interpreter','latex');

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 18 6])
print(figure2,'error_distribution','-depsc2','-r300');