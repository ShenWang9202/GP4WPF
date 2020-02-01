% syms x y z a
% expr = [ x*y, x*z, a*x, y^2, y*z, a*y, z^2, a*z];
% result = (x+y+z)*(a+y+z);
% expand(result)
% [cxy, txy] = coeffs(result,expr)

load('MonteCarloDemand.mat')
load('MonteCarloData.mat')

LoopMatrix = [];
LoopMatrix = [LoopMatrix;
    0	-1	0	1	-1	0	0	0 0;
    0	0	-1	0	1	0	-1	0 0;
    1 0 0 1 0 0 0 1 -1;];

flowsdf = MCSolution(9:17,:);
cov(flowsdf')

A = [];
b = [];
% demand part
MassMatrix = ForConstructA.MassMatrix;
A = [A;MassMatrix];
qsolution = [552.219238281250;151.369583129883;55.1064071655273;325.849609375000;21.2631797790527;98.6304168701172;-44.8935928344727;227.219207763672];
LoopMatrix = ForConstructA.LoopMatrix;
K_pipe = KEstimateLinear(ForConstructb,qsolution);

PumpEquation = IndexInVar.PumpEquation;
h0 = PumpEquation(1);
r0 = -8.9200e-07;%PumpEquation(2);
nu = PumpEquation(3);

K_pump = 0.3;%h0/((h0/(-r0))^(1/nu));
K_estimate = [K_pipe K_pump];
[m,~] = size(LoopMatrix);
for i = 1:m
    LoopMatrix(i,:) = LoopMatrix(i,:).*K_estimate;
end

A = [A;LoopMatrix];

vv = sym('q',[1 NumberofX])
combination = [];

for i = 1:NumberofX
    for j = i:NumberofX
        combination = [combination vv(i)*vv(j)] ;
    end
end

expMatrix = [];
for i = 1:NumberofX
    Ai = A(i,:);
    expMatrix=[expMatrix vv*Ai'];
end

[m,n_d]=size(demand_MC);
PesudoDemand = zeros(NumberofX,n_d);
for i = 1:m
    PesudoDemand(i,:) = demand_MC(i,:);
end
B = [];

expression = [];
for i = 1:NumberofX
    for j = i:NumberofX
        expression = [expression expMatrix(i)*expMatrix(j)] ;
        cov_value = cov(PesudoDemand(i,:),PesudoDemand(j,:));
        B = [B;cov_value(1,2)];
    end
end

AnalysisMatrix = zeros(45,45);

[~,n] = size(expression);
for i = 1:n
    result = expression(i);
    [cxy, txy] = coeffs(result,vv);
    [~,m] = size(cxy);
    for j = 1:m
        ind = find(combination == txy(j));
        AnalysisMatrix(i,ind) = cxy(j);
    end
end
% 
% A= [-1 1 0 0 0 0 0 0 1];
% e1 =  vv * A'
% result = e1*e1;
% expand(result)
% [cxy, txy] = coeffs(result,vv)
% 
% find(combination == txy(4))
AnalysisSolution = AnalysisMatrix\B;

Covar = zeros(9,9);
ind = 1;
for i = 1:NumberofX
    for j = i:NumberofX
         Covar(i,j)   = AnalysisSolution(ind);
         if(i~=j)
            Covar(j,i) = Covar(i,j);
         end
        ind = ind+1;
    end
end



Headloss_pipe_R = REstimateLinear(ForConstructb,qsolution);

K_pipe = [];
[m,~] = size(qsolution);
for i = 1:m
    K_pipe = [K_pipe Headloss_pipe_R(i)*abs(qsolution(i))^(0.852)];
end







