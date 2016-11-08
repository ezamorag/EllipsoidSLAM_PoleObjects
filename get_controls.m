function u = get_controls(dsl,dsr)
global vehicle
dsl = vehicle.al*dsl;
dsr = vehicle.ar*dsr;
u = [(dsr + dsl)/2; (dsr - dsl)/vehicle.L];