% Normalize data

close all
dt = header{1}.DELTA;
ext = round(20/dt);
  
for ii = 1:size(ptrace,1)
    %figure(1)
    T1 = round((header{1}.T1 - header{1}.B)/dt);
    varnoise = norm(ptrace(ii, 1 : ext));
    varP = norm(ptrace(ii, T1 : T1 + ext ));
    %subplot(2,1,1)
    %    plot(ptrace(ii, T1 : T1 + round(10/dt)))
    P(ii,:) = ptrace(ii,:)./max(ptrace(ii,:)) * varP/varnoise;
    %subplot(2,1,2)
    %    plot(ptrace(ii, 1 : round(10/dt)))
    %    title('Noise')
    %plot(ptrace(ii,1: T1 + round(40/dt)))
    %title(sprintf(['norm of noise: %1.2e -- norm of Pcoda: %1.2e\n Ratio'...
    %        ' of norm is: %1.2e\n\n'],varnoise,varP,varP/varnoise))
    %line([T1, T1 + ext],[0,0],'Color',[1 0 0],'LineWidth',2)
    %line([1, ext],[0,0],'Color',[0 1 1],'LineWidth',2)
    scale(ii) = varP/varnoise;
end