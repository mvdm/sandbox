function [S Yo] = selection_gurney2001a_fun(x, params)
% function [S Yo D] = fun_thr(y, param)
% INPUT =
% x = vectors of INTPUT salience value (see Gurney et al 2001a)
% params = structure that contain thresholds (thr_large and thr_small)\
% OUTPUT =
% S = Selected channel (bool)
% Yo = indeterminate set (bool)
% JC in mvdm 29/08/2014


%% weight matrix
Wmat = ones(params.numChans);
weights_matrice = Wmat * params.posW;
negpos = eye(4);
inds = find(negpos == 1);
weights_matrice(inds) = params.negW;

%% Calculate Activation
a = x*weights_matrice;

%% Calculate output
y = piecewise(a, params.epsilon, params.m);

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

%% Calculate the Selected bool 

thr_l = params.thr_large
thr_s = params.thr_small

S=zeros(1,length(y));
S(y>thr_l) = 1;

Yo = zeros(1,length(y));
Yo(y>thr_s & y<thr_l) = 1;

end
