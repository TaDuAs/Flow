classdef PhysicalConstants
    properties (Constant)
        kB = physconst('Boltzmann')*10^21 % Boltzmann constant [pN*nm/K], N*m/K=10^12pN*10^9nm/K = 10^21pN*nm/K
        RT = 298; % Room Temprature [K]
    end
end

