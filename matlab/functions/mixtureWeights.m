function [pn, func] = mixtureWeights(n)
% Function to pick different combination of weights between n parameters

% Change spacing from 11 to 21 for finer resolution
a = linspace(0,1,11);
args = {a};
for ii = 2:n
    args{end+1} = a;
end

c = combvec(args{:});
w = sort(c(:, sum(c) == 1));
pn = length(w);

func = @(p, ind) w(ind,floor(p*pn));


end