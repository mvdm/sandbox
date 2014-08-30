function [y] = egreedy(x, params);

%% Epsilon greedy action selector
% Selects an action based off e-greedy policy

%% randomize
if rand(1) <= 1-params.epsilon
    y = max(x);
else
    y = datasample(x,1);
end

end

