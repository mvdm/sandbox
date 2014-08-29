%% sandbox Gurney

%
%this is a help section
%
%
%
%

%% Parameters

params.numChans = 4;
params.posWeight = .45;
params.negWeight = -1.35;
params.chanIDs = 1:params.numChans;
params.m = 1;
params.epsilon = -.1;

%% build the weight and input matrices
% Weights
W = ones(params.numChans)*params.posWeight;
W(eye(params.numChans)~=0)=params.negWeight;

% inputs
X = [.25 .75 .40 .80];
%% Calculate the Activation 'Y'
Y = X*W;

%% Piecewise linear squashing
output = nan(size(Y));
for ii = 1:length(Y)
    output(ii) = piecewise(Y(ii), params.epsilon, params.m);

end

%% plot the results
figure(1)
%plot the input
subplot(1,3,1)
bar(params.chanIDs, X ,0.5, 'k')
title('Input', 'FontSize', 12)
xlabel('Channel')
ylabel('Signal Level')
ylim([0 1])
set(gca,'YTick',[-0:.25:1])

%plot the activation level
subplot(132)
bar(params.chanIDs, Y,0.5, 'k')
title('Activation', 'FontSize', 12)
xlabel('Channel')
ylim([-.5 .5])
set(gca,'YTick',[-0.5:.25:0.5])

% plot the output
subplot(133)
bar(params.chanIDs, output,0.5, 'k')
xlabel('Channel')
title('Output', 'FontSize', 12)
ylim([0 1])
hold on 
line(0:0.005:params.numChans+1, 0.1,'Color','k')
set(gca,'YTick',[-0:.25:1])
text(0.1, 0.09, 'yo')

