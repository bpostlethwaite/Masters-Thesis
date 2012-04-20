%% Get random event directory
clear all; close all;
addpath functions
addpath sac
checkdir = '/media/TerraS/TEST';
station = 'VTIN';
events = dir([checkdir ,'/' , station]);
while true
    event = events(randi(length(events))).name;
    if length(event) > 2
          break
    end
end
eventdir = fullfile(checkdir,station,event);
fprintf('Going to compare data in event directory: %s\n', eventdir)

%% Read in files

fs = dir(eventdir);
ind = 1;
for f = fs'
    if length(f.name) > 2
        header{ind} = readsac(fullfile(eventdir,f.name));
        fname{ind} = f.name;
        [~,comp{ind}] = readsac(fullfile(eventdir,f.name));
        ind = ind + 1;
    end
end




[fname,I] = sort(fname);
header = header(I);
comp = comp(I);

fprintf('\ndata in comp variable with array order: \n');
for f = fname
    fprintf('%s\n',cell2mat(f))
end

w = tukeywin(length(comp{1}),0.05);
for ii = 1:3
    comp{ii} = detrend(comp{ii}).*w;
end

N = 2^nextpow2(length(comp{1}));
for ii = 1:length(comp)
    fcomp(ii,:) = fftshift(fft(comp{ii},N));
end

dt = header{1}.DELTA;
fs = 1/dt;
fbins = [-N/2 : (N/2 - 1)] * fs / N ;
%fig = figure(333);
%    plot(fbins,abs(fcomp([1,2,4],:).^2))
%    title(sprintf('power spectrum of: %s\nPress a Key to continue',fname{ii}))
%    xlim([0,0.2])
t1 = round(header{4}.T1/dt);



[p,s] = freetran(comp{4}',comp{6}',header{4}.USER0,6.06,3.5,1);

figure(3432)
subplot(3,1,1)
plot(comp{4})
xlim([t1-400,t1+1000])
subplot(3,1,2)
plot(comp{5})
xlim([t1-400,t1+1000])
subplot(3,1,3)
    plot(comp{6})
    xlim([t1-400,t1+1000])

figure(232)
subplot(3,1,1)
    plot(p)
    xlim([t1-400,t1+1000])
subplot(3,1,2)
    plot(s)
    xlim([t1-400,t1+1000])
subplot(3,1,3)
    plot(comp{5}/2)
    xlim([t1-400,t1+1000])




