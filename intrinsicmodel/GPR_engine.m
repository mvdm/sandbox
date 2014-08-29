function [winner,A,O,step_counter] = GPR_engine(saliences,DA_sel,DA_cont,dt,tolerance,max_steps,theta,varargin)

% GPR_ENGINE solution engine for the Gurney, Prescott & Redgrave (2001a,b) BG model 
%
%	GPR_ENGINE(S,DA1,DA2,DT,TOLERANCE,MAX_STEPS,THETA) where S is an array of salience values for the actions
%       represented on the BG channels (the number of channels is implicitly defined by the length of the 
%       salience array). Dopamine levels in the selection and control pathway are set by the values of DA1 and DA2.
%       The time-step is DT, and the model is run until either the change in activation of all units is less than TOLERANCE
%       or MAX_STEPS has been reached. If the output of any GPi channel is below THETA then that channel is considered
%       selected. Returns: an array of the winning action(s) (channel(s)), or the empty matrix [] if no winner
%
%	GPR_ENGINE(...,SWITCH) where SWITCH = 'hard' enforces hard switching so that a maximum of one selection is 
%       made. When more than one GPi unit's output is below THETA then the channel of the lowest is returned, else [] is returned.
%       Where SWITCH = 'gate', returns a vector containing the proportion
%       of output below THETA for each channel, where 0 indicates that the
%       output is above THETA, and 1 indicates no output.
%       
%
%   [W,nA,nO,STEPS] = GPR_ENGINE(...,A,O) are the matrices of activations A and outputs O of
%   all the units from the previous competition. By column: [SD1 SD2 STN
%   GPe GPi]. W is the array of winner(s) if any. Specifying nA and nO returns the corresponding matrices from
%   the current simulation to re-use as arguments for the next one. Put
%   SWITCH = [] if no need to specify this parameter. Will also return
%   STEPS, the number of steps to convergence.
%
%   GPR_ENGINE(...,FLAG) any combination of the following options creates (set A=[], O=[] if not required):
%       'g': includes the connections from the Gurney et al. (2004) Network
%       paper too
%
%       'd': includes the new DA model from my technical report: Humphries, M.D. (2003). High level 
%	    modeling of dopamine mechanisms in striatal neurons. ABRG 3. Dept. Psychology University of Sheffield, UK.
%
%   Note#1: it is critical that saliences are input at time zero! This
%   condition ensures that striatal cells have non-zero activation changes,
%   and thus convergence does not occur on the first time-step.
%
%   Note#2: includes weights of additional connections from Gurney et al
%   (2004) Network paper
%
%   Note#3: if used, the parameters for the new DA model are taken from the
%   optimally-performing model as described in the technical report. However, this
%   included a slightly elevated dopamine level for the GPR model (DA=0.3)
%   which should be specified in this function call if required.
%
%   Note#4: the model is solved using a zero-order hold method. As tau = 1/k = 0.04, 
%   so DT < 0.04 is required to at least ensure the possibility of an accurate simulation. 
%
%   Author: Mark Humphries 21/1/2005

%%% MODEL PARAMETERS
NUM_CHANNELS = length(saliences);

%% weight values as defined by GPR
W_SEL = 1;
W_CONT = 1;
W_STN = 1;
W_SEL_GPi = -1;
W_CONT_GPe = -1;
W_STN_GPi = 0.9;
W_STN_GPe = 0.9;
W_GPe_STN = -1;
W_GPe_GPi = -0.3;

%% additional weights are zero by default
W_GPi_GPi = 0;
W_GPe_GPe = 0;
W_SEL_GPe = 0;

%% thresholds as defined by GPR
e_SEL = 0.2;
e_CONT = 0.2;
e_STN = -0.25;
e_GPe = -0.2;
e_GPi = -0.2;

%%% INITIALISE ARRAYS
% activity arrays
A = zeros(NUM_CHANNELS,5);
old_A = zeros(NUM_CHANNELS,5);
delta_a = ones(NUM_CHANNELS,5);

% output arrays
O = zeros(NUM_CHANNELS,5); % 1 = SD1, 2 = SD2, 3 = STN, 4 = GPe, 5 = GPi

%%% Optional parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set defaults
type = 'soft';
blnNewDA = 0;
gain_DA_sel = DA_sel;      
gain_DA_cont = DA_cont;

% set options
if nargin >= 8 & ~isempty(varargin{1}) type = varargin{1}; end
if nargin >= 9 & ~isempty(varargin{2})
    [rA cA] = size(varargin{2});
    if cA ~= 5 error('Activation matrix must have 5 columns for GPR model'); end
    if rA ~= NUM_CHANNELS error('Activation matrix must have the same number of rows as specified saliences'); end
    A = varargin{2};
end
if nargin >= 10 & ~isempty(varargin{3})
    [rO cO] = size(varargin{3});    
    if cO ~= 5 error('Output matrix must have 5 columns for GPR model'); end
    if rO ~= NUM_CHANNELS error('Output matrix must have the same number of rows as specified saliences'); end
    O = varargin{3};
end
if nargin >= 11 ~isempty(varargin{4})
    if findstr(varargin{4},'g') % include weights from Gurney et al (2004) Network paper
        W_GPi_GPi = -0.2;
		W_GPe_GPe = -0.2;
		W_SEL_GPe = -0.25;   
    end
    if findstr(varargin{4},'d') % include new DA model 
        gain_DA_sel = 0;        % set gain DA to zero
        gain_DA_cont = 0;
        blnNewDA = 1;       % set flag to use new output functions
        % parameter values from tech. report
        e_SEL = 0.1;
        e_CONT = 0.1;       
        gain_SEL = 0.8;
        gain_CONT = 0.8;
        pivot = 0.1;
    end
end

%%% ARTIFICAL UNIT PARAMETERS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k = 25;                     % gain
m = 1;                      % slope

decay_constant = exp(-k*dt);    


%%% SIMULATE MODEL
step_counter = 0;

[row col] = size(saliences);
if row < col
    c = saliences';
else
    c = saliences;
end

int_vec = ones(NUM_CHANNELS,1);

while step_counter < max_steps & sum(sum(delta_a > tolerance)) > 0 
    step_counter = step_counter + 1;
    old_A = A;
    
    %% calculate salience changes
    %% STRIATUM D1
    u_SEL = c .* W_SEL .* (1 + gain_DA_sel);
    A(:,1) = (A(:,1) - u_SEL) * decay_constant + u_SEL;
    
    %% STRIATUM D2
    u_CONT = c .* W_CONT .* (1 - gain_DA_cont);
    A(:,2) = (A(:,2) - u_CONT) * decay_constant + u_CONT;

    %% STN
    u_STN = c .* W_STN + O(:,4) .* W_GPe_STN;
    A(:,3) = (A(:,3) - u_STN) * decay_constant + u_STN;
    
    %% GPe
    temp = (sum(O(:,4)) .* int_vec) - O(:,4);     %% removes own input from each summed value
    u_GPe = sum(O(:,3)) .* W_STN_GPe + O(:,2) .* W_CONT_GPe + O(:,1) .* W_SEL_GPe + temp .* W_GPe_GPe;
    A(:,4) = (A(:,4) - u_GPe) * decay_constant + u_GPe;

    %% GPi
    temp = (sum(O(:,5)) .* int_vec) - O(:,5);     %% removes own input from each summed value    
    u_GPi = sum(O(:,3)) .* W_STN_GPi + O(:,4) .* W_GPe_GPi + O(:,1) .* W_SEL_GPi + temp .* W_GPi_GPi;
    A(:,5) = (A(:,5) - u_GPi) * decay_constant + u_GPi;
    
    %% calculate outputs
    if blnNewDA
        O(:,1) = DA_ramp_output(A(:,1),e_SEL,m,DA_sel,1,gain_SEL,pivot)';    
        O(:,2) = DA_ramp_output(A(:,2),e_CONT,m,DA_cont,2,gain_CONT)';    
    else
        O(:,1) = ramp_output(A(:,1),e_SEL,m)';    
        O(:,2) = ramp_output(A(:,2),e_CONT,m)';    
    end
    
    O(:,3) = ramp_output(A(:,3),e_STN,m)'; 
    O(:,4) = ramp_output(A(:,4),e_GPe,m)';     
    O(:,5) = ramp_output(A(:,5),e_GPi,m)';
    
    delta_a = abs(A - old_A);
end

winner = [];
switch type
case 'soft'
    winner = find(O(:,5) < theta);
case 'hard'
    temp = find(O(:,5) < theta);
    
    if ~isempty(temp) winner = find(O(:,5) == min(O(temp,5))); end
    
    if length(winner) > 1
        winner = [];    % can only return one winner
    end
case 'gate'
    winner = zeros(NUM_CHANNELS,1);
    output = O(:,5); 
    idxs = find(output < theta);
    winner(idxs) = (theta - output(idxs)) / theta;
end


