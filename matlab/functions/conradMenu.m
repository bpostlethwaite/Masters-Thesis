function menuItem = conradMenu(peakDEL)

fprintf('    CONRAD MENU\n' )
fprintf('--------------------\n' )
fprintf('0) Next Station\n' )
fprintf('1) Change Peak Adjust - current value %1.2f\n', peakDEL)
fprintf('2) Categorize discontinuities\n')
fprintf('3) Save Conrad parameters\n')
fprintf('---------------------\n' )
menuItem = input('');

end