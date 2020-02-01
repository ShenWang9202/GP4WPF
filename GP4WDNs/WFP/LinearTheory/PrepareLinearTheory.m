function  [d,IndexInVar,InitialParameter,ForConstructA,ForConstructb,Variable_Symbol_Table,Solution]=PrepareA(inpname,TestCase)
d=epanet(inpname);
% d.plot('nodes','yes','links','yes','highlightnode',{'1','8'},'highlightlink',{'7'},'fontsize',8);

Velocity=[];
Pressure=[];
T=[];
Demand=[];
Head=[];
Flows=[];
TankVolume=[];
HeadLoss = [];
LinkSettings = [];
LinkStatus = [];
% Another way to Simulate all
d.openHydraulicAnalysis;
d.initializeHydraulicAnalysis;
tstep=1;
d.getTimeHydraulicStep
while (tstep>0)
    t=d.runHydraulicAnalysis;   %current simulation clock time in seconds.
    Velocity=[Velocity; d.getLinkVelocity];
    Pressure=[Pressure; d.getNodePressure];
    Demand=[Demand; d.getNodeActualDemand];
    TankVolume=[TankVolume; d.getNodeTankVolume];
    HeadLoss=[HeadLoss; d.getLinkHeadloss];
    Head=[Head; d.getNodeHydaulicHead];
    Flows=[Flows; d.getLinkFlows];
    T=[T; t];
    LinkSettings = [LinkSettings;d.getLinkSettings];
    LinkStatus = [LinkStatus;d.getLinkStatus];
    tstep=d.nextHydraulicAnalysisStep;
end
d.closeHydraulicAnalysis

%% Get Solution from EPANET
[m,n] = size(T);

%PipeIndex = d.getLinkPipeIndex; This method would miss the CVPIPE, e.g
%P446 in CTOWN
% So there is a bug in getLinkPipeIndex and getLinkPipeNameID functions,
% these two funcitons missed CVPIPE type.

% xxIndex means the index of original epanet 
% xxHeadIndex means the head index in my own variables
% xxFlowIndex means the flow index in my own variables

NodeJunctionIndex = d.getNodeJunctionIndex;
NodeIndex = d.getNodeIndex;
ReservoirIndex = d.getNodeReservoirIndex;
TankIndex = d.getNodeTankIndex;

PipeIndex = 1:d.getLinkPipeCount;
PumpIndex = d.getLinkPumpIndex;

ValveIndex = d.getLinkValveIndex;

FCVValveIndex = [];
PRVValveIndex = [];

LinkTypeNameCell = d.getLinkType;
[mlink,nLink] = size(LinkTypeNameCell);
for i = (max(PumpIndex)+1):nLink
    linkString = LinkTypeNameCell{1,i};
    if(strcmp(linkString,'FCV'))
        FCVValveIndex = [FCVValveIndex i];
    elseif(strcmp(linkString,'PRV'))
        PRVValveIndex = [PRVValveIndex i];
    end
end

% Pump and Valve Status
PumpStatus = LinkStatus(:,PumpIndex);
FCVValveStatus = LinkStatus(:,FCVValveIndex);
PRVValveStatus = LinkStatus(:,PRVValveIndex);
% Settings for all types of links
PipeRoughness = LinkSettings(:,PipeIndex);
PumpSpeed = LinkSettings(:,PumpIndex); % take effect when pumpstatus is open
FCVValveSettings = LinkSettings(1,FCVValveIndex);
PRVValveSettings = LinkSettings(1,PRVValveIndex);
PumpSpeedNew = PumpSpeed .* PumpStatus;
%result =xor(PumpSpeedNew,PumpStatus)


% Generate Solution for later validation.
Solution = [];
for i = 1:m
    Solution = [Solution; [Head(i,:) Flows(i,:) PumpSpeedNew(i,:)]];
end
Solution = Solution';
%% Generate Demand for NodeJuncion;
Demand_known = [];
saved_temp_index = [];
Demand_NodeJunction = Demand(:,NodeJunctionIndex);
[m,n] = size(Demand_NodeJunction);
Demand_known = [Demand_known;Demand_NodeJunction(1,:)];
saved_temp_index = [saved_temp_index 1];
distance_demand = 0;
for i = 2:m
    distance_demand = norm(Demand_NodeJunction(i,:) - Demand_known(end,:));
    if(distance_demand >= 0)
        Demand_known = [Demand_known;Demand_NodeJunction(i,:)];
        saved_temp_index = [saved_temp_index i];
    end
end
Demand_known = Demand_known';
% find corresponding Solution
Solution = Solution(:,saved_temp_index);
FCVValveStatus = FCVValveStatus';
FCVValveStatus = FCVValveStatus(:,saved_temp_index);

PRVValveStatus = PRVValveStatus';
PRVValveStatus = PRVValveStatus(:,saved_temp_index);

PumpStatus = PumpStatus';
PumpStatus = PumpStatus(:,saved_temp_index);


%% Generate Mass and Energy Matrice
NodeNameID = d.getNodeNameID; % the Name of each node   head of each node
LinkNameID = d.getLinkNameID; % the Name of each pipe   flow of each pipe

NodesConnectingLinksID = d.getNodesConnectingLinksID; %
[m,n] = size(NodesConnectingLinksID);
NodesConnectingLinksIndex = zeros(m,n);

for i = 1:m
    for j = 1:n
        NodesConnectingLinksIndex(i,j) = find(strcmp(NodeNameID,NodesConnectingLinksID{i,j}));
    end
end
%NodesConnectingLinksIndex
% Generate MassEnergyMatrix
[m1,n1] = size(NodeNameID);
[m2,n2] = size(LinkNameID);
MassEnergyMatrix = zeros(n2,n1);

for i = 1:m
    MassEnergyMatrix(i,NodesConnectingLinksIndex(i,1)) = -1;
    MassEnergyMatrix(i,NodesConnectingLinksIndex(i,2))= 1;
end
% Display
%MassEnergyMatrix


%% Generate Mass Matrix
% For nodes like source or tanks shouldn't have mass equations.
MassMatrix = MassEnergyMatrix(:,NodeJunctionIndex)';


%% Generate Loop Matrix

LoopMatrix = [];
LoopMatrix = [LoopMatrix;
    0	-1	0	1	-1	0	0	0 0;
    0	0	-1	0	1	0	-1	0 0;
    1 0 0 1 0 0 0 1 -1;];

%% Find the index for variable.
% variable =
% [ head of Junction;
%   head of reservior;
%   head of tank;
%   flow of pipe;
%   flow of pump;
%   flow of valve;
%   speed of pump;]


JunctionHeadIndex = NodeJunctionIndex;
ReservoirHeadIndex = ReservoirIndex;
TankHeadIndex = TankIndex;
ReservoirHead = Head(ReservoirIndex,1);




% count of each element
PipeCount = d.getLinkPipeCount;
PumpCount = d.getLinkPumpCount;
ValveCount = d.getLinkValveCount;
FlowCount = PipeCount + PumpCount + ValveCount;

JunctionCount = d.getNodeJunctionCount;
ReservoirCount = d.getNodeReservoirCount;
TankCount = d.getNodeTankCount;
HeadCount = JunctionCount + ReservoirCount + TankCount;

PipeFlowIndex = PipeIndex ;
PumpFlowIndex = PumpIndex ;
ValveFlowIndex = ValveIndex;
FCVValveFlowIndex = FCVValveIndex;
PRVValveFlowIndex = PRVValveIndex;

[~,FCVValveCount] = size(FCVValveIndex);
[~,PRVValveCount] = size(PRVValveIndex);

% total count.
NumberofX = FlowCount;

%% Calculate accurate pumpequation coefficiencies

% The paramter of pump curve from EPANET, BUT the  r_vector is not accurate, we
% need to calibrate them via the solution provide by EPANET.
PumpEquation = [];
if(TestCase == 1) %AnytownModify
    PumpEquation = [300 -3.9549e-06 1.91;]; %3.9549e-06 -4.059E-06
end
if(TestCase == 2) %BWSN_TestCase_1
    PumpEquation = [445.00 -1.947E-05 2.28;
        740.00 -8.382E-05 1.94;
        ];
end
if(TestCase == 3) %ctown
    PumpEquation = [229.659 -0.005969 1.36;
        229.659 -0.005969 1.36;
        295.28 -0.0001146 2.15;
        393.7 -3.746E-006 2.59;
        295.28 -0.0001146 2.15;
        295.28 -4.652E-005 2.41;
        ];
end
if(TestCase == 4 )
    PumpEquation = [393.7008 -3.8253E-006 2.59;];
    %PumpEquation = [200*0.3048 -0.01064 2;];
end

if(TestCase == 5 )
    PumpEquation = [393.7008 -3.8253E-006 2.59;];
    %PumpEquation = [200*0.3048 -0.01064 2;];
end
if(TestCase == 6 )
    PumpEquation = [200 -5.952E-6 2;
        200 -5.952E-6 2;];
    %PumpEquation = [200*0.3048 -0.01064 2;];
end

if(TestCase == 21)
    PumpEquation = [45 -2.357E-6 2.54;];
end

if(TestCase == 22 )
    %PumpEquation = [393.7008 -3.8253E-006 2.59;];
    PumpEquation = [200 -0.01064 2;];
end
if(TestCase == 23 )
    PumpEquation = [393.7008 -3.8253E-006 2.59;];
    %PumpEquation = [200*0.3048 -0.01064 2;];
end

if(TestCase == 24 )
    PumpEquation = [393.7008 -892E-007 3.08;];
    %PumpEquation = [200*0.3048 -0.01064 2;];
end
%%
% getting start and end index of flow of pipes
q_pipe_start_index = min(PipeFlowIndex);
q_pipe_end_index = max(PipeFlowIndex);
% getting start and end index of flow of pumps
q_pump_start_index = min(PumpFlowIndex);
q_pump_end_index = max(PumpFlowIndex);
% getting start and end index of flow of fcv
q_fcv_start_index = min(FCVValveFlowIndex);
q_fcv_end_index = max(FCVValveFlowIndex);
% getting start and end index of flow of prv
q_prv_start_index = min(PRVValveFlowIndex);
q_prv_end_index = max(PRVValveFlowIndex);


FlowUnits = d.getFlowUnits;
if(strcmp('LPS',FlowUnits{1})) % convert to gpm
   head_unit_conversion = Constants4WDN.M2FT;
   flow_unit_conversion = Constants4WDN.LPS2GMP;
end
if(strcmp('GPM',FlowUnits{1})) % convert to gpm
    head_unit_conversion = 1;
    flow_unit_conversion = 1;
end

IndexInVar = struct('NumberofX',NumberofX,'JunctionHeadIndex',JunctionHeadIndex,...
    'ReservoirHeadIndex',ReservoirHeadIndex,...
    'TankHeadIndex',TankHeadIndex,'PipeFlowIndex',PipeFlowIndex,...
    'PumpFlowIndex',PumpFlowIndex,...
    'FCVValveFlowIndex',FCVValveFlowIndex,...
    'PRVValveFlowIndex',PRVValveFlowIndex,...
    'PumpEquation',PumpEquation);
%% Variable_Symbol_Table

Variable_Symbol_Table = cell(NumberofX,2);

LinkIndexInVar = d.getLinkIndex;
temp_i = 1;
for i = LinkIndexInVar
    Variable_Symbol_Table{i,1} =  LinkNameID{temp_i};
    temp_i = temp_i + 1;
end

for i = 1:NumberofX
    Variable_Symbol_Table{i,2} =  strcat('W_',int2str(i));
end

%%
%%
%FlowUnits = {'GPM'};

Elevation = d.getNodeElevations;

ReservoirHead = Head(:,ReservoirHeadIndex);
TankHead = Head(:,TankHeadIndex);

FlowUnits = d.getFlowUnits;
if(strcmp('LPS',FlowUnits{1}))
    M2FT = Constants4WDN.M2FT;
    LPS2GMP = Constants4WDN.LPS2GMP;
end

if(strcmp('GPM',FlowUnits{1}))
    M2FT = 1;
    LPS2GMP = 1;
end
Demand_known = Demand_known * LPS2GMP;

FCVValveDynamicStatus =[];
if(~isempty(FCVValveStatus))
    FCVValveDynamicStatus = FCVValveStatus(1);
end

InitialParameter = struct('Elevation',Elevation,...
    'ReservoirHead',ReservoirHead,...
    'TankHead',TankHead,...
    'Demand_known',Demand_known,...
    'M2FT',M2FT,'LPS2GMP',LPS2GMP);

SettingsNStatus = struct('PipeRoughness',PipeRoughness,...
    'PumpStatus',PumpStatus,'PumpSpeed',PumpSpeed,...
    'FCVValveSettings',FCVValveSettings,...
    'FCVValveInitialStatus',FCVValveStatus,...
    'FCVValveDynamicStatus',FCVValveDynamicStatus,...
    'PRVValveSettings',PRVValveSettings,...
    'FlowUnits',FlowUnits);
    %'PRVValveInitialStatus',PRVValveInitialStatus,...
    %     'PRVValveDynamicStatus',PRVValveDynamicStatus,...


ForConstructA = struct('JunctionCount',JunctionCount,...
    'ReservoirCount',ReservoirCount,...
    'TankCount',TankCount,...
    'PipeCount',PipeCount,...
    'PumpCount',PumpCount,...
    'FCVValveCount',FCVValveCount,...
    'ReservoirHeadIndex',ReservoirHeadIndex,...
    'TankHeadIndex',TankHeadIndex,...
    'MassMatrix',MassMatrix,...
    'LoopMatrix',LoopMatrix);

ForConstructb = struct('q_pipe_start_index',q_pipe_start_index,...
    'q_pipe_end_index',q_pipe_end_index,...
    'q_pump_start_index',q_pump_start_index,...
    'q_pump_end_index',q_pump_end_index,...
    'q_fcv_start_index',q_fcv_start_index,...
    'q_fcv_end_index',q_fcv_end_index,...
    'PumpEquation',PumpEquation,...
    'FlowUnits',FlowUnits,...
    'LinkLength',d.getLinkLength,...
    'LinkDiameter',d.getLinkDiameter,...
    'LinkRoughnessCoeff',d.getLinkRoughnessCoeff,...
    'LinkPipeIndex',d.getLinkPipeIndex);

% pump status(open or close) should be viewed as known, and shouldn't be
% placed in Solution, but it is possible that the status of Pumps can be
% variables, so we just viewed them as variables with fixed value now.


