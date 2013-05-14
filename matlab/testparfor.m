%Setup parallel toolbox
clear all; close all;

if ~matlabpool('size')
    workers = 8;
    matlabpool('local', workers)
end


a = zeros(1,1000);

parfor ii = 1:1000;
    
    a(ii) = ii * 10;

end


fprintf('parfor success %i', ( sum([1:1000]*10) == sum(a)))