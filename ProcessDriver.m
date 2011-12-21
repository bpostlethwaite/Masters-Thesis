%ProcessTraces

% Script to load up sac files, extract out some info, p-value etc
% Rotate traces, deconvolve traces -> then off to be stacked.
clear all
close all

addpath sac
addpath Data
addpath Functions

viewtraces = false;
%% Variables

user = getenv('USER');

sacfolder = '/media/TerraS/CNSN';

datadir = ['/home/',user,'/Dropbox/ComLinks/programming/matlab/thesis/Data'];

rfile = 'STACK_R.sac';
zfile = 'STACK_Z.sac';

%% 1) Select Station folder to process
station = 'ULM';
%workingdir = fullfile(sacfolder,station);
workingdir = fullfile(['/home/',user,'/Programming/data/'],station);

%load(sprintf('%s/%s.mat',datadir,station))

%% 2) Filter Event Diretories
%   
    printinfo = 1; % On and off flag to print out processing results
    savelist  = 0;
    listname  = [station,'_Dlist'];
    Dlist = filterEventDirs(workingdir,printinfo,savelist,listname);
%}
%% 3)  Convert sac file format, filter bad picks
%    
    picktol  = 10; % The picks should be more than PICKTOL seconds apart, or something may be wrong
    saveflag = 0;
    [ptrace,strace,header,pslows] = ConvertFilterTraces(Dlist,station,rfile,zfile,datadir,picktol,printinfo,saveflag);
%}

%% 4) Bin by p value (build pIndex)
%    
    pbinLimits = linspace(.035,.08,100);
    [pIndex,pbin] = pbinIndexer(pbinLimits,pslows,1);
%}

%% 5)  Window with Taper and fourier transform signal.
%
    viewtaper  = 0;
    viewwindow = 0;
    adj = 0.2;
    [wft,vft] = TaperWindowFFT(ptrace,strace,header,adj,viewtaper,viewwindow);
%}
%% 6) Impulse Response: Stack & Deconvolve
% prep all signals to same length N (power of 2)
% FFT windowed traces and stack in by appropriate pbin

%
% Build up spectral stack, 1 stack for each p (need to sort traces by
% p and put them into bins, all need to be length n
% Now fft windowed traces
ind = 1;
h = waitbar(0,'Deconvolving...');
steps = length(pbin);
for ii = 1:steps
    if any(pIndex(:,ii))
        [r,~,~] = simdecf(wft(pIndex(:,ii),:),vft(pIndex(:,ii),:),-1,0);
        
        % Take complex conjugate and reverse 1st half to recomplete fft
        %rtrace(ind,:) = real(ifft([r,conj(r(end-1:-1:2))]));
        rec(ind,:) = real(ifft(r));
        pslow(ind) = pbin(ii);
        ind = ind + 1;
    end
    waitbar(ii/steps,h)
end
close(h)
%}


%% 7) Filter Impulse Response
%
t1 = 3.5; % Search max between these two windows (in secs after p arrival)
t2 = 5;
dt = header{1}.DELTA;
brec = fbpfilt(rec,dt,0.01,1,3,0);

for ii=1:size(rec,1);
   %brtrace(ii,:)=filter(h2,rtrace(ii,:));
   brec(ii,:)=brec(ii,:)/max(abs(brec(ii,1:800)));
   brec(ii,:)=brec(ii,:)/pslow(ii)^.2;
end

[~,it] = max(brec(:,round(t1/dt) + 1: round(t2/dt)) + 1,[],2);
tps = (it + round(t1/dt)-1)*dt;

%}
%% 8) IRLS Newtons Method to find regression Tps
%

thickness = 35; % Starting guesses for physical paramaters  
alpha = 6;
beta = 3.5;
tol = 0.001;  % Tolerance on interior linear solve is 10x of Newton solution
itermax = 60; % Stop if we go beyond this iteration number

[ Tps,thickness,alpha,beta ] = newtonFit(thickness,alpha,beta,pslow,tps,itermax,tol);




%% 9) Grid and Line Search
[ vbest,rbest,hbest ] = GridSearch(brec,Tps,dt,pslow);

%% Plots


figure(547)
    plot(pslow,tps,'*',pslow,Tps)
    title('residual vector and Minimum norm solution')
    xlabel('pslow')
    ylabel('tps residual')

t1 = 0;
t2 = 20;
figure(63)
%imagesc(pslow,[1:800]*dt,brtrace(:,1:800)')
    csection(brec(:,round(t1/dt)+1 : round(t2/dt)+1),dt*(round(t1/dt)),dt)
    %xlabel('pslow')
    %ylabel('time (s)')
    hold on
    plot(Tps,'k+')
    
%}


%% Viewers
%{
    
    figure(567)
    hist(pslow(:))
    title(sprintf('pvalue histogram from station %s',station))
%}
%%
% View Earth Response
%{
t = [1:size(brtrace,2)] * dt;
    for ii = 1:size(brtrace,1)
        figure(5)
        plot(t,brtrace(ii,:))
        %hold on
        %plot(brtrace(ii,:))
        pause(1)
    end
%}




