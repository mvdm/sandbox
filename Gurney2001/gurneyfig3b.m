%% Gurney fig3b project


%% Parameters
params.numChans = 4;
params.posW = 0.45;
params.negW = -1.35;
W = ones(params.numChans);
epsilon = -0.1;
m = 1;

%% weight matrix

weights = W*params.posW;
negpos = eye(4);
inds = find(negpos == 1);
weights(inds) = params.negW;

%% input matrix

x = [.27, .77, .35, .83];

%% activation

a = x*weights;

%% output

y = piecewise(a, epsilon, m);
