%% Viewers
%{
    
    figure(567)
    bar(pbin,sum(pIndex,1))
    title(sprintf('pvalue histogram from station %s',station))
    xlabel('pvalue')
    ylabel('number of traces in pbin')
%}
%%
% View Earth Response
%{
t = [1:size(brec,2)] * dt;
    for ii = 1:size(brec,1)
        figure(5)
        plot(brec(ii,round(t1/dt) + 1: round(t2/dt)))
        title(sprintf('trace %i',ii))
        %hold on
        %plot(brtrace(ii,:))
        pause(1)
    end
%}

%% Junk Stff
% if modnorm
%     modratio = zeros(1,size(ptrace,1));   
%     
%     for ii = 1:size(ptrace,1)
%         t1 = round( (header{ii}.T1 - header{ii}.B) / dt);
%         t3 = round( (header{ii}.T3 - header{ii}.B) / dt);
%         t0 = t1 - round(20/dt);
%         if t0 < 1
%             t0 = 1;
%         end
%         m1 = var(ptrace(ii,  t1 : t3 ));
%         m0 = var(ptrace(ii, t0 : t1 - round(2/dt)));
%         modratio(ii) = m1/m0;
% 
%     end
%     modratio(modratio < 20) = 1;
%     modratio( (modratio < 100) & (modratio > 1) ) = 2;
%     modratio(modratio < 500 & modratio > 2) = 3;
%     modratio(modratio > 5) = 4;
%     ptrace = diag(modratio) * diag(1./max(ptrace,[],2)) * ptrace;
%     strace = diag(modratio) * diag(1./max(strace,[],2)) * strace;
% 
% else

%% Run a few L1 iterations
%{
userdir = getenv('HOME');
f = fullfile(userdir, 'programming','matlab'); %Set base path
addpath(genpath([f,'/spotbox-v1.0/'])) %Path to spot toolbox
addpath(genpath([f,'/spotbox-v1.0/+spot/+rwt'])) 
addpath(genpath([f,'/spgl1'])) %Path to L1 solver
addpath(genpath([f,'/spotbox-v1.0/Splines'])) %Path to rice toolbox

parfor ii = 1:nbins
    lrec(ii,:) = L1crank(ptrace(pIndex(:,ii),:), strace(pIndex(:,ii),:),rec(ii,:), 10);
end
%}

%% Curvelet Denoise
%
%thresh = 0.3;
%crec = performCurveletDenoise(brec,dt,thresh);


