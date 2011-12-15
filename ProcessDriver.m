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

sacfolder = '/media/TerraS/CNSN';

user = getenv('USER');
datadir = ['/home/',user,'/Dropbox/ComLinks/programming/matlab/thesis/Data'];

rfile = 'STACK_R.sac';
zfile = 'STACK_Z.sac';

%% 1) Select Station folder to process
station = 'ULM';
%workingdir = fullfile(sacfolder,station);
workingdir = fullfile(['/home/',user,'/Dropbox/School/'],station);

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
    pbinLimits = linspace(.035,.08,60);
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
        rtrace(ind,:) = real(ifft(r));
        pslow(ind) = pbin(ii);
        ind = ind + 1;
    end
    waitbar(ii/steps,h)
end
close(h)
%}


%% 7) Filter Impulse Response
%
t1 = 3.8;
t2 = 5;
dt = header{1}.DELTA;
d=fdesign.lowpass('N,F3dB',3,1,1/dt); %lowpass filter specification object
% Invoke Butterworth design method
Hd=design(d,'butter');
brtrace = fbpfilt(rtrace,dt,0.01,1,3,0);

for ii=1:size(rtrace,1);
   %brtrace(ii,:)=filter(h2,rtrace(ii,:));
   brtrace(ii,:)=brtrace(ii,:)/max(abs(brtrace(ii,1:800)));
   %brtrace(ii,:)=brtrace(ii,:)/pslow(ii)^.2;
end

%[~,it] = max(rtrace(:,round(t1/dt)+1 : round(t2/dt)+1)');
%tps = (it + round(t1/dt)-1)*dt;

[~,it] = max(brtrace(:,round(t1/dt)+1 : round(t2/dt)+1),[],2);
tps = (it + round(t1/dt)-1)*dt;

figure(63)
imagesc(pslow,[1:800]*dt,brtrace(:,1:800)')
colorbar
%}
%% Newtons Method to find tps
%
H = 43;
alpha = 3;
beta = 5;
iter = 0;

while iter < 10
    f = H*(sqrt(1/beta^2 - pslow.^2) - sqrt(1/alpha^2 - pslow.^2));
    r = (f - tps');
    drdH = f/H;
    drda = (H/alpha^3) ./ (sqrt(1/alpha^2 - pslow.^2));
    drdb = (-H/beta^3) ./ (sqrt(1/beta^2 - pslow.^2));
    J = [drdH(:),drda(:),drdb(:)];
    norm(r)
    delm = -J\r(:);
    H = (H + delm(1)); alpha = (alpha + delm(2)); beta = (beta + delm(3));
    iter = iter + 1
end

Tps = H*(sqrt(1/beta^2 - pslow.^2) - sqrt(1/alpha^2 - pslow.^2));


figure(547)
plot(pslow,tps,'*',pslow,Tps)

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




