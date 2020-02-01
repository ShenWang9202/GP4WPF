function c_estimate = FCVEstimate_b(forConstructb,X0)
q_fcv = X0(forConstructb.q_fcv_start_index:forConstructb.q_fcv_end_index,1);
q_fcv_save = q_fcv;
FlowUnits = forConstructb.FlowUnits;

if(strcmp('LPS',FlowUnits)) % convert to gpm
    D_link = forConstructb.LinkDiameter *Constants4WDN.mm2inch; % inches ; be careful, pump's diameter is 0
end
if(strcmp('GPM',FlowUnits)) % convert to gpm
    D_link = forConstructb.LinkDiameter; % inches ; be careful, pump's diameter is 0
    q_fcv = q_fcv/Constants4WDN.GPM2CFS;
end

diameter_conversion = Constants4WDN.feet2inch;
pi = Constants4WDN.pi;
FCVIndex = forConstructb.FCVValveIndex;
D_link = D_link(FCVIndex)/diameter_conversion;



FCVMinorLossCoeff = forConstructb.FCVMinorLossCoeff;

CrossSectionalArea = pi*(D_link/2).^2;
velocity = q_fcv/CrossSectionalArea;

gravity = Constants4WDN.gravity;
gravity_ft = gravity/Constants4WDN.MperFT;

Headloss_FCV = FCVMinorLossCoeff./(2*gravity_ft).*velocity.^2;
c_estimate = Headloss_FCV - q_fcv_save;
end
