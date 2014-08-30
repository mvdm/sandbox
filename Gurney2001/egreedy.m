function [y] = egreedy(x, params)

%% Epsilon greedy action selector
% Selects an action based off e-greedy policy
%% In the case of a tie between the max values it needs to be broken
if length(x(x==max(x)))>1
    max_ind = find(x==max(x));
    max_x_ind = max_ind(randperm(numel(max_ind)));
    max_x = max_x_ind(1);
end
%% randomize
if rand(1) <= 1-params.e
    idx = max_x;
else
    temp = randperm(length(x));
    idx = temp(1);
end

y = zeros(size(x));
y(idx) = 1;

end

