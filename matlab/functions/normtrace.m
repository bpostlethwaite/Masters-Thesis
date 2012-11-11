function [ ndiag ] = normtrace( ptrace, header, dt )
% NORMTRACE Build a normalize weight based on SNR and impulsiveness

weight = zeros(length(header), 1);

for ii = 1:length(header)
    t1 = round( (header{ii}.T1 - header{ii}.B) / dt );
    t3 = round( (header{ii}.T3 - header{ii}.B) /dt );
    td = t3 - t1;
    a = ptrace(ii, t1 : t1 + floor(td/2));
    b = ptrace(ii, t1 + ceil(td/2) : t3);
    c = ptrace(ii, 1 : t1);
    A = sqrt( (a * a') / length(a));
    B = sqrt( (b * b') / length(b)) ;
    C = sqrt( (c * c') / length(c));
    
    weight(ii) = A / (B * C);
end
    
    ndiag = diag(weight);

end

