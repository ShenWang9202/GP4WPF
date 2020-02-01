function Plot3nodeWFPJournal1(SolutionCell)
%plot 3d line colormap
%https://www.mathworks.com/matlabcentral/answers/254696-how-to-assign-gradual-color-to-a-3d-line-based-on-values-of-another-vector
[~,SizeSolution] = size(SolutionCell);
fontsize = 30;
[Q1,Q2] = meshgrid(0:10:1500,-1000:10:1000);
PumpEquation = [393.7008 -3.828806522496852e-06 2.59;];
h0_vector = PumpEquation(:,1);
r_vector = PumpEquation(:,2);
w_vector = PumpEquation(:,3);
R2=1.145323502901834e-05;
 
Z = 700 + h0_vector + r_vector * (Q1).^w_vector - R2*abs(Q2).^(1.852);
CO(:,:,1) = zeros(25); % red
CO(:,:,2) = ones(25).*linspace(0.5,0.6,25); % green
CO(:,:,3) = ones(25).*linspace(0,1,25); % blue
figure1 = figure;
surf(Q1,Q2,Z,'FaceColor','r','FaceAlpha',0.3,'EdgeColor','none')
%% mass conservation
hold on
Q1_B = 100 + Q2;
surf(Q1_B,Q2,Z,'FaceColor','b','FaceAlpha',0.3,'EdgeColor','none')


%%
 hold on
[Q1,Q2] = meshgrid(0:10:1500,-1000:10:1000);
Z =  906 + zeros(size(Q1));
surf(Q1,Q2,Z,'FaceColor','k','FaceAlpha',0.3,'EdgeColor','none')


%% GP solution
allpoint = [];
initialpoint = [];
Marksize = [];
Marksize_initialpoint = [];
Color_d = [];
colormap(jet)
DOTColor = [];
for i = 1:SizeSolution
Wsolution =  SolutionCell{1,i};
q_2 = Wsolution(2,:);%[0,139.371771755347,315.323245947144,468.822366283594,590.069254846570,677.084951217945,734.756312170602,770.807577002844,792.477402477317,805.185792937270,812.528857317602,816.734935873529,819.132045226590,820.494253928177,821.267084422918,821.705129065146,821.953283402468,822.093821685532,822.173399747678,822.218455488304,822.243963884725,822.258405066543,822.266580573668,822.271208882784];
q_1 = Wsolution(3,:);%[908.473942683293,239.371771755347,415.323245947144,568.822366283594,690.069254846570,777.084951217945,834.756312170602,870.807577002844,892.477402477317,905.185792937270,912.528857317602,916.734935873529,919.132045226590,920.494253928177,921.267084422918,921.705129065146,921.953283402468,922.093821685532,922.173399747678,922.218455488304,922.243963884726,922.258405066543,922.266580573668,922.271208882784];
z_f =  Wsolution(1,:);
dot1=[q_1;q_2;z_f]';
color_d= ((dot1(:,1)-922.27).^2+(dot1(:,2)-822.27).^2).^(0.5);
DOTColor = [DOTColor max(color_d)];
end
maxColor = max(DOTColor);

for i = 1:40
Wsolution =  SolutionCell{1,i};
q_2 = Wsolution(2,:);%[0,139.371771755347,315.323245947144,468.822366283594,590.069254846570,677.084951217945,734.756312170602,770.807577002844,792.477402477317,805.185792937270,812.528857317602,816.734935873529,819.132045226590,820.494253928177,821.267084422918,821.705129065146,821.953283402468,822.093821685532,822.173399747678,822.218455488304,822.243963884725,822.258405066543,822.266580573668,822.271208882784];
q_1 = Wsolution(3,:);%[908.473942683293,239.371771755347,415.323245947144,568.822366283594,690.069254846570,777.084951217945,834.756312170602,870.807577002844,892.477402477317,905.185792937270,912.528857317602,916.734935873529,919.132045226590,920.494253928177,921.267084422918,921.705129065146,921.953283402468,922.093821685532,922.173399747678,922.218455488304,922.243963884726,922.258405066543,922.266580573668,922.271208882784];
z_f =  Wsolution(1,:);
%dot=[q_1;q_2;z_f]';
dot1=[q_1;q_2;z_f]';
allpoint = [allpoint;dot1];
initialpoint = [initialpoint;dot1(1,:)];
%plot3(dot(:,1),dot(:,2),dot(:,3),'Marker','o','MarkerSize',10);
%p = plot3(dot(:,1),dot(:,2),dot(:,3),'DisplayName','Iteration process','MarkerSize',3,...
%     'Marker','diamond',...
%     'LineWidth',2);
%use distance as color
color_d= ((dot1(:,1)-922.27).^2+(dot1(:,2)-822.27).^2).^(0.5);
minMarkSize = 50;
maxMarkSize = 200;
marksize = minMarkSize + (maxMarkSize - minMarkSize)/maxColor .* color_d;
Marksize = [Marksize;marksize];
Marksize_initialpoint = [Marksize_initialpoint;marksize(1,:)];
Color_d = [Color_d;color_d];
patch([dot1(:,1); nan],[dot1(:,2); nan],[dot1(:,3); nan],[color_d; nan],...
    'LineWidth',4,...
    'FaceColor','none','EdgeColor','interp')
%     'MarkerSize',3,...
%     'Marker','diamond',...
%// modified jet-colormap
% cd = [uint8(jet(5000)*255) uint8(ones(5000,1))]';
% set(p.Edge, 'ColorBinding','interpolated', 'ColorData',cd)
hold on
end
scatter3(allpoint(:,1),allpoint(:,2),allpoint(:,3),Marksize,Color_d,'filled');
hold on
scatter3(initialpoint(:,1),initialpoint(:,2),initialpoint(:,3),Marksize_initialpoint-5,'x','w','MarkerFaceColor','w','LineWidth',3);
hold on

colorbar
%view([51.7 38.0000000000001]);
%view([74.5 31.6000000000001]);
% view([126.5 15.6000000000001]);
% view([76.9 57.2]);
view([105.7 19.6]);



lgd = legend('Surface (32a) ','Surface (32b)','Surface (32c)');
set(lgd,...
    'Position',[0.145003897798564 0.873349674262252 0.810663657010408 0.0811111089918348],...
    'Orientation','horizontal',...
    'Interpreter','latex');
lgd.FontSize = fontsize+2;

% lgd = legend('$s=0.8$','$s=1.0$','Location','North','Interpreter','Latex');
% lgd.FontSize = fontsize-3;
% title('$h^{M} = s^2 (h_0 - r (q/s)^{\nu})$','interpreter','latex')
set(lgd,'box','off')
% set(lgd,'Interpreter','Latex');

set(gca, 'TickLabelInterpreter', 'latex','fontsize',fontsize);
xlabel('$q_{12}$','FontSize',fontsize+10,'interpreter','latex')
ylabel('$q_{23}$','FontSize',fontsize+10,'interpreter','latex')
zlabel('$h_{3}$','Rotation',0,'FontSize',fontsize+10,'interpreter','latex')

xlim([-800 1500])
ylim([-1000 1100])



annotation(figure1,'textbox',...
    [0.752773650528795 0.535984848484849 0.187397289642145 0.213499780809908],...
    'String',{'Final value','$q_{12}: 922.27$','$q_{23}: 822.27$'},...
    'Interpreter','latex',...
    'FontSize',fontsize,...
    'FitBoxToText','off',...
    'BackgroundColor',[1 1 1]);

% Create textarrow
annotation(figure1,'textarrow',[0.652182029040765 0.746794871794872],...
    [0.506807359307359 0.668560606060606],'Color',[1 1 1],'LineWidth',5);

% Create textarrow
% annotation(figure1,'textarrow',[0.283969592984463 0.205128205128205],...
%     [0.35827922077922 0.257575757575758],'LineWidth',5);

% Create textbox
% annotation(figure1,'textbox',...
%     [0.0178373381089385 0.0511363636363637 0.187501470925969 0.213396101817622],...
%     'String',{'Initial value','$q_{12}: 908.47$','$q_{23}: 0$'},...
%     'Interpreter','latex',...
%     'FontSize',24,...
%     'FitBoxToText','off',...
%     'BackgroundColor',[1 1 1]);


set(gcf,'PaperUnits','inches','PaperPosition',[0 0 15 8])
print(figure1,'3nodes3D','-depsc2','-r300');
%view([-242.3 44.4000000000001]);
%view([48.9 14.8]);
%view([164.1 21.2]);
%view([-5.49999999999991 46.8]);
%view([-13.1 30.8]);

initialpoint
end

