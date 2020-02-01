% Get the variances of the distribution of each demand(not zero)
Variance
DemandIndex
PumpFlow = deterministic(IndexInVar.PumpFlowIndex);
PipeFlow = deterministic(IndexInVar.PipeFlowIndex);

%% Step 1, if all flows are positive, we can continue on, otherwise, update connection matrix at first.

% We need to update the old A matrix according our WFP solution,
% Since we assume a direction before we solve the WFP, but for two random
% variable, their variables is the sum of the individual one regardless of
% addition or substraction.

% For example,  q12 + q23= d2, if we only list equation according to this,
% we can get sig23^2 + sig23^23 = sig2^2; If the solution is q12 = 100 and
% q23=-50,d2=50, then the previous one is wrong, and the correct one should be sig23^2 = sig23^23 +
% sig2^2, which means sig23^2 - sig23^23 = sig2^2.

% Now if we update the sign according to the solution at first, things can
% always be right. For example, if we know q23=-50, it equats to sig23^2 -
% new_sig23^23 = sig2^2 where new_sig23 = 50;

% Fine the negative index in PipeFlow vector
NegativePipeIndex = find(PipeFlow<0);
MassEnergyMatrixStruct = UpdateConnectionMatrix(d,NegativePipeIndex);


%% Step 2 Get the solution of WFP, and linearizing around the solution

q = PipeFlow;
Headloss_pipe_R = PipeCoeff(ForConstructb);
K_pipe = Headloss_pipe_R.* (abs(q).^(0.852));

q = PumpFlow;
if(~isempty(IndexInVar.PumpEquation))
    h0_vector = IndexInVar.PumpEquation(:,1);
    r_vector = IndexInVar.PumpEquation(:,2);
    w_vector = IndexInVar.PumpEquation(:,3);
    K_pump = r_vector.*w_vector.*(q.^(w_vector-1));
end

b_pump = h0_vector + r_vector*PumpFlow^(w_vector) - K_pump * PumpFlow;
display('verify the headloss from reservoir to tank')
K_pump * PumpFlow + b_pump - K_pipe*PipeFlow 

%% Step 3 Construct A and b

%[A,b] = Construct_Variance_A_b(MassEnergyMatrixStruct,ForConstructA,Variance,K_pipe,K_pump);

A = [1 -2 1;
    (K_pump)^2  -2*K_pump*K_pipe (K_pipe)^2;
    K_pump -(K_pipe+K_pump) K_pipe]
b = [100; 0; 0];
Analysis_Cov = A\b;

Analysis_Cov

%% compare
headandflowIndex = [HeadIndex FlowIndex];
headandflow = MCSolution(headandflowIndex,:);

fitdist(demand_MC','normal')

monteCarlo_cov = cov(headandflow');
fitmethis(headandflow(1,:))

fitdist(headandflow(3,:)','normal')



