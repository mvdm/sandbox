function [y] = piecewise(a, epsilon, m)
% takes a matrix of size n a as the activation values

output(a<epsilon) = 0; 
output(a>=epsilon & a<= 1/m +epsilon) = m*(a(a>=epsilon & a<= 1/m +epsilon)-epsilon);
output(a>(1/m)+epsilon) = 1;   
y = a;

% a(a<epsilon) = 0;
% a((epsilon <= a) & (a <= (1/m+epsilon))) = m*(a-epsilon);
% a(a>(1/m+epsilon)) = 1;

% for i = 1:length(a)
%     if a(i) < epsilon;
%         a(i) = 0;
%     elseif ((epsilon <= a(i)) && (a(i) <= (1/m+epsilon)));
%         a(i) = m*(a(i)-epsilon);
%     else a(i) > 1/m+epsilon;
%         a(i) = 1;
%     end
% end
% 
% y = a;
% 
% end
% 
