function [y] = piecewise(activation, epsilon, m )
%This is a piecewise 
if activation < epsilon
    y = 0;
elseif epsilon <= activation && activation <= 1/m+epsilon
    y = m*(activation-epsilon);
elseif activation > 1/m+epsilon
    y = 1;
end

end

