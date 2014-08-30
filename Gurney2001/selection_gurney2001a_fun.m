function [S Yo] = selection_gurney2001a_fun(x, params)
% function [S Yo D] = fun_thr(y, param)
% INPUT =
% x = vectors of INTPUT salience value (see Gurney et al 2001a)
% params = structure that contain thresholds (thr_large and thr_small) 
% params.numChans = 4;
% params.posW = 0.45;
% params.negW = -1.35;
% params.chanIDs = 1:params.numChans;
% params.W = ones(params.numChans);
% params.epsilon = -0.1;
% params.m = 1;
% params.thr_large = 0.1; % theta thr   
% params.thr_small = 0; 
% OUTPUT =
% S = Selected channel (bool)
% Yo = indeterminate set (bool)
% JC in mvdm 29/08/2014


%% weight matrix
Wmat = ones(params.numChans);
weights_matrice = Wmat * params.posW;
negpos = eye(params.numChans);
inds = find(negpos == 1);
weights_matrice(inds) = params.negW;

%% Calculate Activation
a = x*weights_matrice;

%% Calculate output
y = piecewise(a, params.epsilon, params.m);

%% Calculate the Selected bool 

thr_l = params.thr_large;
thr_s = params.thr_small;

S=zeros(1,length(y));
S(y>thr_l) = 1;

Yo = zeros(1,length(y));
Yo(y>thr_s & y<thr_l) = 1;

end
