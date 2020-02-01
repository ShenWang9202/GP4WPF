function Linear_pump = LinearizePump1(IndexInVar,q_pumpv)
PumpEquation = IndexInVar.PumpEquation;

h0 = PumpEquation(:,1);
r = PumpEquation(:,2);
nu = PumpEquation(:,3);


q_pump_linear = [q_pumpv(1),q_pumpv(2)];


% q_pump_linear = [975,976];
h_pump_linear = [];
for i = 1:2
    h_pump_linear = [h_pump_linear;h0 + r.*(q_pump_linear(i).^nu)];
end
K_pump = (h_pump_linear(1) - h_pump_linear(2))/(q_pump_linear(1) - q_pump_linear(2));
b_pump = h_pump_linear(1) - K_pump * q_pump_linear(1);
% q_pumpv
% K_pump = r*abs(q_pumpv)^(nu-1)
Linear_pump = [K_pump b_pump];
end