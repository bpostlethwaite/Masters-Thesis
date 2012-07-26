function [pIndex,pbin] = pbinIndexer(pbinLimits,pslows,CHECK)

% PBININDEXER Creates a logical array matrix for indexing p and s traces
% corrisponding to the same indexed pbin.
% CHECK > 0 means that this will also perform a check to make sure every
% plsow is selected.

pbin = pbinLimits(1:end-1) + 0.5 * diff(pbinLimits);

e1 = ones(length(pslows),1);
e2 = ones(1,length(pbin));

limTop = kron(e1,pbinLimits(2:end));
limBottom = kron(e1,pbinLimits(1:end-1));
parray = kron(e2,pslows');

pIndex = (parray >= limBottom) & (parray <  limTop);

if CHECK > 0
    if length(parray(pIndex)) ~= length(pslows)
        fprintf('Failed check, not all plsows accounted for in Index\n')
    end
end

end



