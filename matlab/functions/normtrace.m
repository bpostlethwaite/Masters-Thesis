function [ ndiag ] = normtrace( ptrace, strace, header, dt, plotflag )
% NORMTRACE Build a normalize weight based on SNR and impulsiveness

weight = zeros(length(header), 1);

for ii = 1:length(header)
    t1 = round( (header{ii}.T1 - header{ii}.B) / dt );
    t3 = floor( (header{ii}.T3 - header{ii}.B) /dt );
    td = t1 + floor( (t3 - t1) / 3);
    a = ptrace(ii, t1 : td);
    if t3 > size(ptrace,2)
        t3 = size(ptrace,2) - 1;
    end
    b = ptrace(ii, td + 1 : t3);
    c = ptrace(ii, 1 : t1 - 1);
    A = sqrt( (a * a') / length(a));
    B = sqrt( (b * b') / length(b)) ;
    C = sqrt( (c * c') / length(c));
    
    weight(ii) = (2*A - B) / C;
    
    if plotflag
        subplot(2,1,1)
        minp = min(ptrace(ii, :));
        maxp = max(ptrace(ii, :));
        plot( ptrace(ii, 1:t3 + 200) )
        title(sprintf('A = %2.2f, B = %2.2f, C = %2.2f\nweight %2.2f',...
            A, B, C, weight(ii)))
        hold on
        plot([t1 t1], [minp maxp], 'g')
        plot([td td], [minp maxp], 'g')
        plot([td + 1, td + 1], [minp maxp], 'r')
        plot([t3 t3], [minp maxp], 'r')
        hold off
        subplot(2,1,2)
        plot( strace(ii, :) )
        title(sprintf('weight %2.2f', weight(ii)))
        pause
    end
    
end
    
    ndiag = diag(weight);

end

