function plotMenteCarloEach(id,MonteCarloResult,DeterministicResult)
h=histogram(MonteCarloResult);
hold on
title(id)
line([DeterministicResult DeterministicResult],[0  max(h.Values)],'LineWidth',10)
hold off
end


