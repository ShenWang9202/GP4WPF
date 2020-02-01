function FCVValveDynamicStatus = UpdateValveStatus(IndexInVar,FCVValveDynamicStatus,FCVValveSettings,Solution)
FCVValveFlow = Solution(IndexInVar.FCVValveFlowIndex);
[~,n] = size(FCVValveFlow);
% Don't consider the case when it is closed.
for i = 1:n
    if(FCVValveFlow(i) >= FCVValveSettings(i))
        FCVValveDynamicStatus(i) = 2;
    else
        FCVValveDynamicStatus(i) = 1;
    end
end
end