%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  DATE: 7/7/2003
%%%%  WHAT: M-code (script) version of original intrinsic basal ganglia model
%%%%		Parameters are taken from Gurney et al (2001) Bio Cyber, 85, 411-423.
%%%%  AUTHOR: Mark Humphries
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

%%% MODEL PARAMETERS
NUM_CHANNELS = 6;
da_sel = 0.2;     % dopamine level
da_cont = 0.2;

W_SEL = 1;
W_CONT = 1;
W_STN = 1;
W_SEL_GPi = -1;
W_CONT_GPe = -1;
W_STN_GPi = 0.9;
W_STN_GPe = 0.9;
W_GPe_STN = -1;
W_GPe_GPi = -0.3;

e_SEL = 0.2;
e_CONT = 0.2;
e_STN = -0.25;
e_GPe = -0.2;
e_GPi = -0.2;

%%% SIMULATION PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = 5;                      % length of simulation
dt = 0.01;                  % time-step
sim_steps = t / dt;

% activity arrays
a_SEL = zeros(NUM_CHANNELS,1);
a_CONT = zeros(NUM_CHANNELS,1);
a_STN = zeros(NUM_CHANNELS,1);
a_GPe = zeros(NUM_CHANNELS,1);
a_GPi = zeros(NUM_CHANNELS,1);

% output arrays
o_SEL = zeros(NUM_CHANNELS,sim_steps);
o_CONT = zeros(NUM_CHANNELS,sim_steps);
o_STN = zeros(NUM_CHANNELS,sim_steps);
o_GPe = zeros(NUM_CHANNELS,sim_steps);
o_GPi = zeros(NUM_CHANNELS,sim_steps);

%%% SALIENCE INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ch1_onset = 1;
ch1_size = 0.4;

ch2_onset = 2;
ch2_size = 0.6;

transient_onset = 3;
transient_off = 4;
transient_size = 0.2;

c = zeros(NUM_CHANNELS,1);

%%% ARTIFICAL UNIT PARAMETERS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k = 25;                     % gain
m = 1;                      % slope

decay_constant = exp(-k*dt);    

tic
%%% SIMULATE MODEL
for steps = 2:sim_steps
    
    %% calculate salience changes
    if steps * dt == ch1_onset
        c(1) = ch1_size;
    end
    if steps * dt == ch2_onset
        c(2) = ch2_size;
    end
    if steps * dt == transient_onset
        c(1) = c(1) + transient_size;
    end
    if steps * dt == transient_off
        c(1) = ch1_size;
    end
    
    %% STRIATUM D1
    u_SEL = c .* W_SEL .* (1 + da_sel);
    a_SEL = (a_SEL - u_SEL) * decay_constant + u_SEL;
    o_SEL(:,steps) = ramp_output(a_SEL,e_SEL,m)';    

    %% STRIATUM D2
    u_CONT = c .* W_CONT .* (1 - da_cont);
    a_CONT = (a_CONT - u_CONT) * decay_constant + u_CONT;
    o_CONT(:,steps) = ramp_output(a_CONT,e_CONT,m)';    

    %% STN
    u_STN = c .* W_STN + o_GPe(:,steps-1) .* W_GPe_STN;
    a_STN = (a_STN - u_STN) * decay_constant + u_STN;
    o_STN(:,steps) = ramp_output(a_STN,e_STN,m)'; 
    
    %% GPe
    u_GPe = sum(o_STN(:,steps)) .* W_STN_GPe + o_CONT(:,steps) .* W_CONT_GPe;
    a_GPe = (a_GPe - u_GPe) * decay_constant + u_GPe;
    o_GPe(:,steps) = ramp_output(a_GPe,e_GPe,m)';     

    %% GPi
    u_GPi = sum(o_STN(:,steps)) .* W_STN_GPi + o_GPe(:,steps) .* W_GPe_GPi + o_SEL(:,steps) .* W_SEL_GPi;
    a_GPi = (a_GPi - u_GPi) * decay_constant + u_GPi;
    o_GPi(:,steps) = ramp_output(a_GPi,e_GPi,m)';
end

toc

figure(1)
clf
plot(o_GPi(1,:),'r')
hold on
plot(o_GPi(2,:),'b')
