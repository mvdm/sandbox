%% Gurney fig3b project


%% Parameters
params.numChans = 4;
params.posW = 0.45;
params.negW = -1.35;
params.chanIDs = 1:params.numChans;
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
%% plot the results
figure(1)
%plot the input
subplot(1,3,1)
bar(params.chanIDs, x ,0.5, 'k')
title('Input', 'FontSize', 12)
xlabel('Channel')
ylabel('Signal Level')
ylim([0 1])
set(gca,'YTick',[-0:.25:1])

%plot the activation level
subplot(132)
bar(params.chanIDs, a,0.5, 'k')
title('Activation', 'FontSize', 12)
xlabel('Channel')
ylim([-.5 .5])
set(gca,'YTick',[-0.5:.25:0.5])

% plot the output
subplot(133)
bar(params.chanIDs, y,0.5, 'k')
xlabel('Channel')
title('Output', 'FontSize', 12)
ylim([0 1])
hold on 
line(0:0.005:params.numChans+1, 0.1,'Color','k')
set(gca,'YTick',[-0:.25:1])
text(0.1, 0.09, 'yo')

