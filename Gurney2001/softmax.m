function action_matrix = softmax(x,params)
% takes the output and tau to select an action using softmax. Returns a
% matrix with 1 for the selected action and zeros for the ignored actions.

softmax = exp(x/params.tau)./sum(exp(x/params.tau));
action_matrix = zeros(1,4);

action_selection = find(rand < cumsum(softmax), 1, 'first');

action_matrix(action_selection) = 1;