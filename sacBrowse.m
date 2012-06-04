%sac test
clear all
close all
addpath sac

% Location of Sac files
sacfolder = '/media/TerraS';
%sacfolder =  '/home/ben/Dropbox/School';
flag = true;
% Ask user for event folder
%directory = uigetdir(sacfolder,'Choose Event Folder');
directory = '/media/TerraS/TEST/ULM' ;
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
    hd = readsac(sacfile);
    dt = hd.DELTA;
    t0 = (hd.T0 - hd.B) / dt;
    t4 = (hd.T4 - hd.B) / dt;
    t7 = (hd.T7 - hd.B) / dt;
    plot(d)
    line([ t0; t0], [ -1, 1], ...
         'LineWidth', 2, 'Color', [.8 .4 .4]);
    line([ t4; t4], [ -1, 1], ...       
        'LineWidth', 2, 'Color', [.1 .7 .1]);
    line([ t7; t7], [ -1, 1], ...
        'LineWidth', 2, 'Color', [.1 .9 .9]);
    legend('data','t0','t4','t7')
end

hd