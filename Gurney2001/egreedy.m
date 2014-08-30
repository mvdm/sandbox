function [y] = egreedy(x, params)

%% Epsilon greedy action selector
% Selects an action based off e-greedy policy

%% randomize
if rand(1) <= 1-params.e
    [~,idx] = max(x);
else
    temp = randperm(length(x));
    idx = temp(1);
end

y = zeros(size(x));
y(idx) = 1;

end

