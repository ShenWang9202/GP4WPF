MCSolution()

d2 = demand_MC(2,:);
d3 = demand_MC(5,:);
r = corrcoef(d2,d3);

demand_MC1 = demand_MC';
corrcoef(demand_MC1)


MCSolution1=MCSolution(1:17,:)';
Rel=corrcoef(MCSolution1)