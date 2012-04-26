%sac test
clear all
close all
addpath sac

% Location of Sac files
sacfolder = '/media/TerraS';
%sacfolder =  '/home/ben/Dropbox/School';
flag = true;
% Ask user for event folder
directory = uigetdir(sacfolder,'Choose Event Folder');
% get list of folders or files from chosen folder


while flag
    
    items = struct2cell(dir(directory));
    items = items(1,1:end);
    
    [Selection,ok] = listdlg('ListString',items,'ListSize',[400,400]);
    
    if ok == 1
        item = cell2mat(items(Selection));
        item = fullfile(directory,item);
        if isdir(item)
            directory =  item;
            flag = true;
        else
            sacfile = item;
            flag = false;
        end
    else
        fprintf('whatever')
        flag = false;
    end
    
end

if sacfile
    [~, d] = readsac(sacfile);
    d = d./max(d);
    S = readsac(sacfile);
    dt = S.DELTA;
    t0 = (S.T0 - S.B) / dt;
    plot(d)
    line([ t0; t0], [ -1, 1], ...
            'LineWidth', 2, 'Color', [.4 .4 .4]);
    %plot(d(round(70/0.05):round(52/0.05)+5000));
end