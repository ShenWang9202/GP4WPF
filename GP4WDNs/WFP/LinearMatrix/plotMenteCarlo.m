function plotMenteCarlo(Deterministic,MonteCarlo,IndexInVar,Variable_Symbol_Table)
% Wasserstein
%figure
for i = IndexInVar.JunctionHeadIndex
    figure
    plotMenteCarloEach(Variable_Symbol_Table{i,1},MonteCarlo(i,:),Deterministic(i));
end


for i = IndexInVar.PumpFlowIndex
    figure
    plotMenteCarloEach(Variable_Symbol_Table{i,1},MonteCarlo(i,:),Deterministic(i));
end

for i = IndexInVar.PipeFlowIndex
    figure
    plotMenteCarloEach(Variable_Symbol_Table{i,1},MonteCarlo(i,:),Deterministic(i));
end

for i = IndexInVar.ValveFlowIndex
    figure
    plotMenteCarloEach(Variable_Symbol_Table{i,1},MonteCarlo(i,:),Deterministic(i));
end

end