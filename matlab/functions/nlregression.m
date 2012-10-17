function [brec, pslow, tps, Tps, t1, t2] = nlregression(brec, pslow, dt)
%NLREGRESSION Summary of this function goes here
%   Detailed explanation goes here

if 0
    t1 = db.t1;
    t2 = db.t2;
else
    t1 = 2.0;
    t2 = 6.5;
end
adjbounds = true;

while adjbounds
    t1n = ' ';
    t2n = ' ';
    [~,it] = max(brec(:,round(t1/dt) + 1: round(t2/dt)) + 1,[],2);
    tps = (it + round(t1/dt)-1)*dt;
    h = figure(3311);
    clf(h)
    plot(pslow, tps,'*')
    title('Check bounds and tighten and adjust accordingly')
    t1n = input('Enter a new lower bound or "y" to accept: ', 's');
    if str2num(t1n) % Check if input is a number
        t1 = str2num(t1n); % If it is use number as lower bound
        t2n = input('Enter a new higher bound or "y" to accept: ', 's');
        if str2num(t2n) % Check if 2nd input is a number
            t2 = str2num(t2n); %#ok<*ST2NM> % If it is use num as upper bound
        end
        
    elseif (t1n == 'y') || (t2n == 'y') % If user enters 'y' move on
        % Enter banish mode
        banish = true;
        bound = 0.3;
        while banish %Stay in banish mode till we get a 'y' or a 'x'
            
            % Compute newton fit
            if mean(tps) < 4
                H = 30;
            elseif mean(tps) < 4.4
                H = 34;
            elseif mean(tps) < 4.6
                H = 37;
            else
                H = 42;
            end
            alpha = 6.4;
            beta = 3.6;
            tol = 1e-3;  % Tolerance on interior linear solve is 10x of Newton solution
            itermax = 300; % Stop if we go beyond this iteration number
            damp = 0.2;
            warning off MATLAB:plot:IgnoreImaginaryXYPart
            warning off MATLAB:nearlySingularMatrix
            [ Tps,H,alpha,beta ] = ...
                newtonFit(H,alpha,beta,pslow',tps,itermax,tol,damp,h);
            
            % Compute and show bounds
            changebounds = true;
            while changebounds
                tup = Tps + bound;
                tlw = Tps - bound;
                figure(h);
                clf(h)
                hold on
                plot(pslow( (tps < tlw) | (tps > tup) ), ...
                    tps( (tps < tlw) | (tps > tup) ),'r*')
                plot(pslow( (tps >= tlw) & (tps <= tup) ), ...
                    tps( (tps >= tlw) & (tps <= tup) ),'b*')
                plot(pslow, Tps, 'g')
                bline = plot(pslow, tup, '--r', pslow, tlw, '--r');
                hold off
                title(sprintf(['Current bound = %1.2f\n'...
                    'Red stars will be removed'], bound))
                t1n = input(['Enter a new bound, "r" to remove red' ...
                    ' stared traces,\n "b" to go back and "y" to accept: '], 's');
                
                % Check input, kill outside bounds and repeat or skip and
                % finish
                if str2num(t1n) % Check if input is a number
                    bound = str2num(t1n); % If it is use number as lower bound
                elseif (t1n =='b')
                    banish = false;
                    break % Go back to limit setter
                elseif (t1n == 'r')
                    ind = (tps < tlw) | (tps > tup);
                    tps(ind) = [];
                    pslow(ind) = [];
                    brec(ind,:) = [];
                    Tps(ind) = [];
                    break
                elseif (t1n == 'y') % Get out of all loops
                    banish = false;
                    adjbounds = false;
                    hold off
                    break
                else
                    fprintf('Sorry %s or %s is bad input\n', t1n)
                end
            end
        end
        
    else
        fprintf('Sorry %s or %s is bad input\n', t1n, t2n)
    end
    
    
    close(h)
end

end

