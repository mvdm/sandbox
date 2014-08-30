%% Gurney fig3b project


%% Parameters
params.numChans = 4;                % number of channels in the paper
params.posW = 0.45;                 % The positive weights between input-output nodes
params.negW = -1.35;                % The negtive weights between input-output nodes
params.chanIDs = 1:params.numChans; % channel IDs (used for plots)
W = ones(params.numChans);          %synaptic weight matrix (inputs-->outputs only)
epsilon = -0.1;  
m = 1;

%% weight matrix
weights = W*params.posW;
weights(eye(params.numChans)~=0)=params.negWeight; %find the diagonals and replaces them with the negative weights

%% input matrix
x = [.27, .77, .35, .83];    % from input fig3b

%% activation
a = x*weights;

%% output
output = nan(size(Y));
for ii = 1:length(Y)
    output(ii) = piecewise(Y(ii), params.epsilon, params.m);
end
y = output;
% y = piecewise(a, epsilon, m);
%% plot the results
figure(1)
%plot the input
subplot(1,3,1)                   % subplot(#columns, #rows, plot index)
bar(params.chanIDs, x ,0.5, 'k') % bar(x value, y value, width, color)
title('Input', 'FontSize', 16)
xlabel('Channel',  'FontSize', 16)
ylabel('Signal Level', 'FontSize', 16)
ylim([0 1])
set(gca,'YTick',-0:.25:1)      % sets the major ticks for a certain range

%plot the activation level
subplot(132)
bar(params.chanIDs, a,0.5, 'k')
title('Activation', 'FontSize', 16)
xlabel('Channel',  'FontSize', 16)
ylim([-.5 .5])
set(gca,'YTick',-0.5:.25:0.5)

% plot the output
subplot(133)
bar(params.chanIDs, y,0.5, 'k')
xlabel('Channel',  'FontSize', 16)
title('Output', 'FontSize', 16)
ylim([0 1])
hold on 
line(0:0.005:params.numChans+1, 0.1,'Color','k') % adds a line at yo like Fig3b
set(gca,'YTick',-0:.25:1)
text(0.1, 0.09, 'yo')               % adds text 'yo' near the line. 

