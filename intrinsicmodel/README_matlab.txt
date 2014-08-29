MATLAB version of the intrinsic basal ganglia model

Files:
intrinsic_model_ZOH.m
GPR_engine.m
ramp_output.m
DA_ramp_output.m


Notes:

(1) intrinsic_model_ZOH.m is a MATLAB script that replicates the
    Simulink version

(2) GPR_engine.m is a MATLAB function that encapsulates multiple
    versions of the model: read its Help comments for full details.
 
(3) ramp_output.m and DA_ramp_output.m are two different forms of the
    piece-wise linear output function. The latter is a modified form
    given in (Humphries, 2003) that captures the effects of dopamine
    on striatal neuron output.


References:

Gurney, K., Prescott, T. J. & Redgrave, P. (2001). A computational
model of action selection in the basal ganglia I: A new functional
anatomy. Biological Cybernetics, 85, 401-410.

Gurney, K., Prescott, T. J. & Redgrave, P. (2001). A computational
model of action selection in the basal ganglia II: Analysis and
simulation of behaviour. Biological Cybernetics, 85, 411-423.

Humphries, M.D. (2003). High level modeling of dopamine mechanisms in
striatal neurons. Technical Report ABRG 3. Dept. Psychology University
of Sheffield, UK.
