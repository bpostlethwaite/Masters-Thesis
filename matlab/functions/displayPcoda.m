function displayPcoda(indices, ptraces, header, dt)


% Extract header info for correct ptrace indices
count = 1;
for ii = 1:size(ptraces,1)
    if indices(ii)
        b(count) = round( (header{ii}.T1 - header{ii}.B)/dt );
        e(count) = round( (header{ii}.T3 - header{ii}.B)/dt );
        count = count + 1;
    end
end

ptrace = ptraces(indices, :);

h = figure(112211);

for ii = 1:length(b)
    subplot(length(b), 1, ii)
        plot( ptrace(ii, b - 10 : e + 10) )
end

