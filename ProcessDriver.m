%ProcessTraces

% Script to load up sac files, extract out some info, p-value etc
% Rotate traces, deconvolve traces -> then off to be stacked.
clear all
close all

addpath sac
addpath Data
addpath Functions


viewtraces = false;
viewtaper = true;
viewwindow = false;
%% Variables

sacfolder = '/media/TerraS/CNSN';
%sacfolder = '/home/ben/Dropbox/School';
datadir = '/home/bpostlet/Dropbox/ComLinks/programming/matlab/thesis/Data';

rfile = 'STACK_R.sac';
zfile = 'STACK_Z.sac';

% Set Station to process
station = 'ULM';
workingdir = fullfile(sacfolder,station);

%% SortEventDirs
%{
    SortEventDirs(workingdir,'Dlist',1)
%% rotate coordinates of traces, and collect header info in all station events
    
    load Dlist
    ConvertTraces(Dlist,station,rfile,zfile,datadir)
%% bin by p value
    load(sprintf('%s/%s.mat',datadir,station))
%}

%% Taper Window and FFT

load(sprintf('%s/%s.mat',datadir,station))
[wft,vft] = TaperWindowFFT(ptrace,strace,header,0.5,viewtaper,viewwindow);

%% pbins
pbins = linspace(0.035,0.08,40);
pbinshift = pbins(2:end); pbinshift(end+1) = 1;
for ii = 1:length(pslows)
    binarray(ii,:) =  (pbinshift >= pslows(ii)) == (pbins <= pslows(ii)) ;
end

%% STACK
% prep all signals to same length N (power of 2)
% FFT windowed traces and stack in by appropriate pbin


% Build up spectral stack, 1 stack for each p (need to sort traces by
% p and put them into bins, all need to be length n
% Now fft windowed traces

for ii = 1:length(pbins)
    if any(binarray(:,ii))
        figure(13)
        %fprintf('pbin %f has p values\n',pbins(ii))
        %[rft(ii,:),xft(ii,:),betax(ii)] = simdecf(wft(binarray(:,ii),1:(2^13)+1),vft(binarray(:,ii),1:(2^13)+1),-1,1);
        [rft(ii,:),xft(ii,:),betax(ii)] = simdecf(wft(binarray(:,ii),:),vft(binarray(:,ii),:),-1,-1);
        Rtrace(ii,:) = real(ifft(rft(ii,:)));
        pslow = pbins(ii);
        %plot(Rtrace(ii,:))
        %pause(3)
    end
end
%plot(f,real((rft)))



%% Viewers
%
    load(sprintf('%s/%s.mat',datadir,station))
    figure(567)
    hist(pslows(:))
    title(sprintf('pvalue histogram from station %s',station))
%}

% View traces in a slideshow, lines added where windows have been defined
if viewtraces == true
    figure(23)
    load([station,'.mat']);
    for ii = 1:length(ptrace)
        
        plot(ptrace{ii}(:,1),ptrace{ii}(:,2),'b--',strace{ii}(:,1),strace{ii}(:,2),'r--')
        h1 = line([header{ii,1}.T1; header{ii,1}.T1],[min(ptrace{ii}(:,2)); max(ptrace{ii}(:,2))],...
            'LineWidth',4,'Color',[.4 .9 .8]);
        
        h2 = line([header{ii,1}.T3;header{ii,1}.T3],[min(ptrace{ii}(:,2)),max(ptrace{ii}(:,2))],...
            'LineWidth',4,'Color',[.4 .9 .8]);
        
        pause(4)
    end
end




%}




