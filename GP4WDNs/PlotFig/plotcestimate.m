clc;
clear;
close all;
TestCase =1;
base = 1.001;
if(TestCase == 1)
    inpname='Anytown.inp';
end

if(TestCase == 3)
    %inpname='tutorial5node.inp';
    inpname='ctownwithoutanyvalve.inp';
end

if(TestCase == 5)
    %inpname='tutorial5node.inp';
    inpname='tutorial8node.inp';
end

if(TestCase == 6)
    %inpname='tutorial5node.inp';
    inpname='tutorial_lps_2PUMPS.inp';
end



[d,IndexInVar,InitialParameter,ForConstructA,ForConstructb,Variable_Symbol_Table,Solution] = PrepareA(inpname,TestCase);

FlowUnits = d.getFlowUnits;
if(strcmp('LPS',FlowUnits{1})) % convert to gpm
    L_pipe = d.getLinkLength *Constants4WDN.m2feet; % ft
    D_pipe = d.getLinkDiameter *Constants4WDN.mm2inch; % inches ; be careful, pump's diameter is 0
end
if(strcmp('GPM',FlowUnits{1})) % convert to gpm
    L_pipe = d.getLinkLength ; % ft
    D_pipe = d.getLinkDiameter; % inches ; be careful, pump's diameter is 0
end
C_pipe = d.getLinkRoughnessCoeff; % roughness of pipe

diameter_conversion = Constants4WDN.feet2inch;
Volum_conversion = Constants4WDN.GPM2CFS;

PipeIndex = d.getLinkPipeIndex;
L_pipe = L_pipe(PipeIndex);
D_pipe = D_pipe(PipeIndex)/diameter_conversion;
C_pipe = C_pipe(PipeIndex);

Headloss_pipe_R = 4.727 * L_pipe./((C_pipe*Volum_conversion).^(1.852))./(D_pipe.^(4.871));


C_estimate = [];
q_pipe = -3000:1:3000;
[~,n] = size(q_pipe);
[~,m] = size(Headloss_pipe_R);
for i = 1:m
    c_estimate = [];
    for j = 1:n
        c_estimate = [c_estimate ((Headloss_pipe_R(i)*abs(q_pipe(j))^(0.852)-1)*q_pipe(j))];
        %c_estimate = [c_estimate;base^((Headloss_pipe_R(i)*abs(q_pipe(i))^(0.852)))];
    end
    C_estimate = [C_estimate;c_estimate];
end
h = figure;
for i = 1:m
    plot(q_pipe,C_estimate(i,:),'LineWidth',2);
    hold on
end
title(strcat('base=',num2str(base,10)))
xlabel('Flow','FontSize',12)
ylabel('C^{estimate}','FontSize',12)
saveas(h,sprintf('C_estimate_1.png',num2str(base,10)))
%close(h)
