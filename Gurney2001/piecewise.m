function [y] = piecewise(a, epsilon, m)
% piecewise
%
% Takes a matrix of size n a as the activation values
% a(a<epsilon) = 0;
% a((epsilon <= a) & (a <= (1/m+epsilon))) = m*(a-epsilon);
% a(a>(1/m+epsilon)) = 1;
% y = a;

for i = 1:length(a)
    if a(i) < epsilon;
        a(i) = 0;
    elseif ((epsilon <= a(i)) && (a(i) <= (1/m+epsilon)));
        a(i) = m*(a(i)-epsilon);
    else a(i) > 1/m+epsilon;
        a(i) = 1;
    end

end

y = a;  % corresponds to the output of the nodes

end

