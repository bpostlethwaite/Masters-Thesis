%% Get random event directory
clear all; close all;
addpath functions
addpath sac
checkdir = '/media/TerraS/X5';
station = 'CRLN';
%checkdir = '/media/TerraS/CNSN';
%station = 'ULM';
events = dir([checkdir ,'/' , station]);
while true
    event = events(randi(length(events))).name;
    if str2num(event)
          break
    end
end
eventdir = fullfile(checkdir,station,event);
fprintf('Going to compare data in event directory: %s\n', eventdir)

%% Read in files

fs = dir(eventdir);
ind = 1;
for f = fs'
    if strfind(f.name,'stack_R')
        header = readsac(fullfile(eventdir,f.name));
        [~,rcomp] = readsac(fullfile(eventdir,f.name));
        
    end
    if strfind(f.name,'stack_Z')
        [~,zcomp] = readsac(fullfile(eventdir,f.name));
    end
    if strfind(f.name,'BHZ')
        [~,Zcomp] = readsac(fullfile(eventdir,f.name));
    end
end

%[fname,I] = sort(fname);
%header = header(I);
%comp = comp(I);

%fprintf('\ndata in comp variable with array order: \n');
%for f = fname
%    fprintf('%s\n',cell2mat(f))
%end

dt = header.DELTA;
pslow = header.USER0;

[p,s] = freetran(rcomp',zcomp',pslow,6.06,3.5,1);

Zcomp = Zcomp(1:16384);
Zcomp = Zcomp./max(Zcomp);

t = 1:length(p);

t0 = round( (header.T0 - header.B) /dt );
t4 = round( (header.T4 - header.B)/dt );
t7 = round( (header.T7 - header.B)/dt );

figure(34)
subplot(2,1,1)
plot(t,p./max(p))
xlim([ t0 - 200  , t0 + 2000])
line([ t0; t0], [-1; 1], ...
    'LineWidth', 2, 'Color', [.8 .8 .2]);
line([ t4; t4], [ -1, 1], ...
    'LineWidth', 2, 'Color', [.8 .2 .8]);
line([ t7; t7], [ -1, 1], ...
    'LineWidth', 2, 'Color', [.8 .4 .4]);
%line([ t3; t3], [ -1, 1], ...
%    'LineWidth', 2, 'Color', [.4 .4 .4]);
title(sprintf('Depth is %f',header.EVDP))
legend('PTrace','P','pP','PP')
subplot(2,1,2)
plot(zcomp./max(zcomp))
xlim([ t0 - 200  , t0 + 2000])



