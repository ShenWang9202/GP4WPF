[m,~] = size(MassMatrix)
MassMatrixIndexCell = cell(m,2);
[RowPos,ColPos] = find(MassMatrix == 1);
[m,~] = size(RowPos);
for i = 1:m
    MassMatrixIndexCell(RowPos(i),1) = {[MassMatrixIndexCell{RowPos(i),1},ColPos(i)]};
end

[RowNeg,ColNeg] = find(MassMatrix == -1);
[m,~] = size(RowNeg);
for i = 1:m
    MassMatrixIndexCell(RowNeg(i),2) = {[MassMatrixIndexCell{RowNeg(i),2},ColNeg(i)]};
end

MassMatrixIndexCell
%% Generate Energy Matrix

% for pipe
EnergyPipeMatrix = -MassEnergyMatrix(PipeIndex,:);

[m,~] = size(EnergyPipeMatrix);
EnergyPipeMatrixIndex = zeros(m,2);
[RowPos,ColPos] = find(EnergyPipeMatrix == 1);
[m,~] = size(RowPos);
for i = 1:m
    EnergyPipeMatrixIndex(RowPos(i),1) = ColPos(i);
end

[RowNeg,ColNeg] = find(EnergyPipeMatrix == -1);
[m,~] = size(RowNeg);
for i = 1:m
    EnergyPipeMatrixIndex(RowNeg(i),2) = ColNeg(i);
end

% for Pump
EnergyPumpMatrix = -MassEnergyMatrix(PumpIndex,:);

[m,~] = size(EnergyPumpMatrix);
EnergyPumpMatrixIndex = zeros(m,2);
[RowPos,ColPos] = find(EnergyPumpMatrix == 1);
[m,~] = size(RowPos);
for i = 1:m
    EnergyPumpMatrixIndex(RowPos(i),1) = ColPos(i);
end

[RowNeg,ColNeg] = find(EnergyPumpMatrix == -1);
[m,~] = size(RowNeg);
for i = 1:m
    EnergyPumpMatrixIndex(RowNeg(i),2) = ColNeg(i);
end

% for valve

% FCV
EnergyFCVValveMatrix = -MassEnergyMatrix(FCVValveIndex,:);


[m,~] = size(EnergyFCVValveMatrix);
EnergyValveMatrixIndex = zeros(m,2);
[RowPos,ColPos] = find(EnergyFCVValveMatrix == 1);
[m,~] = size(RowPos);
for i = 1:m
    EnergyValveMatrixIndex(RowPos(i),1) = ColPos(i);
end

[RowNeg,ColNeg] = find(EnergyFCVValveMatrix == -1);
[m,n] = size(RowNeg);
for i = 1:m
    EnergyValveMatrixIndex(RowNeg(i),2) = ColNeg(i);
end
% PRV
EnergyPRVValveMatrix = -MassEnergyMatrix(PRVValveIndex,:);


[m,~] = size(EnergyPRVValveMatrix);
EnergyValveMatrixIndex = zeros(m,2);
[RowPos,ColPos] = find(EnergyPRVValveMatrix == 1);
[m,~] = size(RowPos);
for i = 1:m
    EnergyValveMatrixIndex(RowPos(i),1) = ColPos(i);
end

[RowNeg,ColNeg] = find(EnergyPRVValveMatrix == -1);
[m,n] = size(RowNeg);
for i = 1:m
    EnergyValveMatrixIndex(RowNeg(i),2) = ColNeg(i);
end

MassEnergyMatrix4GP = struct('MassMatrixIndexCell',{MassMatrixIndexCell},...
    'EnergyPipeMatrixIndex',EnergyPipeMatrixIndex,'EnergyPumpMatrixIndex',EnergyPumpMatrixIndex,...
    'EnergyValveMatrixIndex',EnergyValveMatrixIndex);

%% Find the index for variable.
% variable =
% [ head of Junction;
%   head of reservior;
%   head of tank;
%   flow of pipe;
%   flow of pump;
%   flow of valve;
%   speed of pump;]

% count of each element
PipeCount = d.getLinkPipeCount;
PumpCount = d.getLinkPumpCount;
ValveCount = d.getLinkValveCount;
FlowCount = PipeCount + PumpCount + ValveCount;

JunctionCount = d.getNodeJunctionCount;
ReservoirCount = d.getNodeReservoirCount;
TankCount = d.getNodeTankCount;
HeadCount = JunctionCount + ReservoirCount + TankCount;

[~,FCVValveCount] = size(FCVValveIndex);
[~,PRVValveCount] = size(PRVValveIndex);

% total count.
NumberofX = FlowCount;
NumberofX = NumberofX + HeadCount;
NumofX = NumberofX;
NumberofX = NumberofX + PumpCount; % speed of pump

% index for each element.
JunctionHeadIndex = NodeJunctionIndex;
ReservoirHeadIndex = ReservoirIndex;
TankHeadIndex = TankIndex;

HeadCount= double(HeadCount);
PipeFlowIndex = PipeIndex +  HeadCount;
PumpFlowIndex = PumpIndex +  HeadCount;
ValveFlowIndex = ValveIndex + HeadCount;

if (isempty(ValveFlowIndex))
    PumpSpeedIndex = (max(PumpFlowIndex)+1):(max(PumpFlowIndex)+ double(PumpCount));
else
    PumpSpeedIndex = (max(ValveFlowIndex)+1):(max(ValveFlowIndex)+ double(PumpCount));
end


FCVValveFlowIndex = FCVValveIndex + HeadCount;
PRVValveFlowIndex = PRVValveIndex + HeadCount;


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
% PumpEquation
% find the head index
%     variable =
%     [ head of Junction;
%       head of reservior;
%       head of tank;
%       flow of pipe;
%       flow of pump;
%       flow of valve;
%       speed of pump;]
% getting start index of head in var
h_start_index = min(NodeIndex);
h_end_index = max(NodeIndex);
% getting end index of head in var
% if(~isempty(TankHeadIndex))
%     h_end_index = max(TankHeadIndex);
% else % without valves, check reservoirs
%     if (~isempty(ReservoirHeadIndex))
%         h_end_index = max(ReservoirHeadIndex);
%     else % without reservoirs, only Junctions
%         h_end_index = max(NodeHeadIndex);
%     end
% end

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
% getting start and end index of speed of pumps
s_start_index = min(PumpSpeedIndex);
s_end_index = max(PumpSpeedIndex);

FlowUnits = d.getFlowUnits;
if(strcmp('LPS',FlowUnits{1})) % convert to gpm
   head_unit_conversion = Constants4WDN.M2FT;
   flow_unit_conversion = Constants4WDN.LPS2GMP;
end
if(strcmp('GPM',FlowUnits{1})) % convert to gpm
    head_unit_conversion = 1;
    flow_unit_conversion = 1;
end

HeadofAllNode = Solution(h_start_index:h_end_index,1)*head_unit_conversion;

SpeedofAllPump = Solution(s_start_index:s_end_index,1);
FlowofAllPump = Solution(q_pump_start_index:q_pump_end_index,1)*flow_unit_conversion;
if(~isempty(PumpEquation))
h0_vector = PumpEquation(:,1);
w_vector = PumpEquation(:,3);

[m,~] = size(EnergyPumpMatrixIndex);
% search for each pump  and update  r_vector
for i = 1:m
%     get the index of junction node connecting pumps.
    DeliveryIndex = EnergyPumpMatrixIndex(i,2);
    SuctionIndex = EnergyPumpMatrixIndex(i,1);
    HeadIncreaseofPump= HeadofAllNode(DeliveryIndex) - HeadofAllNode(SuctionIndex);
    r_vector = (h0_vector(i)-HeadIncreaseofPump/(SpeedofAllPump(i)*SpeedofAllPump(i))) * (SpeedofAllPump(i)/FlowofAllPump(i))^(w_vector(i));
    PumpEquation(i,2)= -r_vector;
end
end

%%
IndexInVar = struct('NumberofX',NumberofX,'JunctionHeadIndex',JunctionHeadIndex,...
    'ReservoirHeadIndex',ReservoirHeadIndex,...
    'TankHeadIndex',TankHeadIndex,'PipeFlowIndex',PipeFlowIndex,...
    'PumpFlowIndex',PumpFlowIndex,...
    'FCVValveFlowIndex',FCVValveFlowIndex,...
    'PRVValveFlowIndex',PRVValveFlowIndex,...
    'PumpSpeedIndex',PumpSpeedIndex,...
    'PumpEquation',PumpEquation);

%% Variable_Symbol_Table

Variable_Symbol_Table = cell(NumberofX,2);
temp_i = 1;
NodeIndexInVar = d.getNodeIndex;
LinkIndexInVar = d.getLinkIndex  + d.getNodeCount;
LinkPumpNameID = d.getLinkPumpNameID;
for i = NodeIndexInVar
    Variable_Symbol_Table{i,1} =  NodeNameID{temp_i};
    temp_i = temp_i + 1;
end

temp_i = 1;
for i = LinkIndexInVar
    Variable_Symbol_Table{i,1} =  LinkNameID{temp_i};
    temp_i = temp_i + 1;
end
% remove speed, not a optimization variable any more.
temp_i = 1;
for i = PumpSpeedIndex
    Variable_Symbol_Table{i,1} = strcat('Speed_',LinkPumpNameID{temp_i});
    temp_i = temp_i + 1;
end

for i = 1:NumberofX
    Variable_Symbol_Table{i,2} =  strcat('W_',int2str(i));
end


%% Initial parameter 
%Elevation
Elevation = d.getNodeElevations;
PipeFLowAverage = mean(Solution,2);
ReservoirHead = Head(:,ReservoirHeadIndex);
TankHead = Head(:,TankHeadIndex);
%%
%FlowUnits = {'GPM'};
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

InitialParameter = struct('Elevation',Elevation,'PipeFLowAverage',PipeFLowAverage,...
    'ReservoirHead',ReservoirHead,'Demand_known',Demand_known,'M2FT',M2FT,'LPS2GMP',LPS2GMP);

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
    'NumofX',NumofX,...
    'h_end_index',h_end_index,...
    'ReservoirHeadIndex',ReservoirHeadIndex,...
    'TankHeadIndex',TankHeadIndex,...
    'MassMatrix',MassMatrix,...
    'EnergyPumpMatrix',EnergyPumpMatrix,...
    'EnergyFCVValveMatrix',EnergyFCVValveMatrix,...
    'EnergyPRVValveMatrix',EnergyPRVValveMatrix,...
    'EnergyPipeMatrix',EnergyPipeMatrix);

ForConstructb = struct('q_pipe_start_index',q_pipe_start_index,...
    'q_pipe_end_index',q_pipe_end_index,...
    'q_pump_start_index',q_pump_start_index,...
    'q_pump_end_index',q_pump_end_index,...
    'q_fcv_start_index',q_fcv_start_index,...
    'q_fcv_end_index',q_fcv_end_index,...
    's_start_index',s_start_index,...
    's_end_index',s_end_index,...
    'PumpEquation',PumpEquation,...
    'FlowUnits',FlowUnits,...
    'LinkLength',d.getLinkLength,...
    'LinkDiameter',d.getLinkDiameter,...
    'LinkRoughnessCoeff',d.getLinkRoughnessCoeff,...
    'LinkPipeIndex',d.getLinkPipeIndex);

% pump status(open or close) should be viewed as known, and shouldn't be
% placed in Solution, but it is possible that the status of Pumps can be
% variables, so we just viewed them as variables with fixed value now.

