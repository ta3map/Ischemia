
clear all
cd('D:\Neurolab\ialdev\Ischemia\analysis')
protocol_path = 'D:\Neurolab\ialdev\Ischemia\Protocol\IschemiaProtocol.xlsx';
save_folder = 'D:\Neurolab\Data\Ischemia\Traces';
load_folder = 'D:\Neurolab\Data\Ischemia\Traces';
t1 = 517
Protocol = readtable(protocol_path);
id = find(Protocol.ID == t1, 1);
name = Protocol.name{id};
%% make LFP
ch = 3;
lfp_make_lfp(protocol_path, t1, save_folder, ch);
%% make cell
ch = 1;
cell_make_cell(protocol_path, t1, save_folder, ch);
%% puff triggers
ch = 5;
puff_triggers(protocol_path, t1, save_folder, ch);
%% Load OIS data

v_path = Protocol.IOSFile{id};
if isequal(v_path(end-3:end),'.oos')
    imSize = [348 260]
    dt = 2.5
    [v_data, v_t] = readOOS(v_path, imSize, dt);
else
    startframe = 1;
    eachframe = 5;
    [v_data, v_t] = readIOS(v_path, 'startframe', startframe, 'eachframe', eachframe, 'Format', 'Lin', 'resize', 1);
    disp('OIS data loaded')
end
%% make OIS with probes
n_probes = 2;% number of probes
[ios_frame, baseframe, SignalsIOS, Time, pos] = ois_make_ois(v_data, v_t, protocol_path, t1, n_probes, save_folder);
%% plot OIS
interested_probe = 1;
Ylim =[-8 10]
ois_plot_ois(protocol_path, t1, SignalsIOS, Time, Ylim, n_probes, ios_frame, pos, interested_probe)
% save all about OIS
subfolder = 'OIS_trace';
save([save_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.mat'], 'protocol_path', 't1', 'SignalsIOS', 'Time', 'Ylim', 'n_probes', 'ios_frame', 'pos', 'baseframe');
subfolder = 'OIS_image';
saveas(figure(1),[save_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.jpg']);
disp('saved')
%% LFP and OIS
lfp_and_OIS_plot(protocol_path, t1, load_folder, save_folder, 1)
%% Cell_LFP_and_OIS
wcell_Ylim = [0 200]
LFP_Ylim = [-300 2000]
OIS_Ylim = [-8 1]

[lost_time] = find_lost_time(Protocol, id)
tags = 1;
puff = 0;
cell_lfp_and_OIS_plot(protocol_path, t1, load_folder, save_folder, tags,puff, LFP_Ylim, wcell_Ylim, OIS_Ylim, -lost_time)
