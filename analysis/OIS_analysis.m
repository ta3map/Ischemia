
clear all
cd('D:\Neurolab\ialdev\Ischemia\analysis')
protocol_path = 'D:\Neurolab\ialdev\Ischemia\Protocol\IschemiaProtocol.xlsx'
save_folder = 'D:\Neurolab\Data\Ischemia\Traces';
load_folder = 'D:\Neurolab\Data\Ischemia\Traces';
t1 = 503
Protocol = readtable(protocol_path);
id = find(Protocol.ID == t1, 1);
name = Protocol.name{id};
%% make LFP
ch = 3
lfp_make_lfp(protocol_path, t1, save_folder, ch);
%% make cell
ch = 1
cell_make_cell(protocol_path, t1, save_folder, ch);
%% puff triggers
ch = 5
puff_triggers(protocol_path, t1, save_folder, ch);
%% Load OIS data
startframe = 1;
eachframe = 5;
v_path = Protocol.IOSFile{id};
[v_data, v_t] = readIOS(v_path, 'startframe', startframe, 'eachframe', eachframe, 'Format', 'Lin', 'resize', 1);
disp('OIS data loaded')
%% make OIS with probes
n_probes = 2;% number of probes
[ios_frame, baseframe, SignalsIOS, Time, pos] = ois_make_ois(v_data, v_t, protocol_path, t1, n_probes, eachframe, save_folder);
%% plot OIS
interested_probe = 1;
Ylim =[-13 20]
ois_plot_ois(protocol_path, t1, SignalsIOS, Time, Ylim, n_probes, ios_frame, pos, interested_probe)
%% save all about OIS
subfolder = 'ios_trace';
save([save_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.mat'], 'protocol_path', 't1', 'SignalsIOS', 'Time', 'Ylim', 'n_probes', 'ios_frame', 'pos', 'baseframe','eachframe');
subfolder = 'ios_image';
saveas(figure(1),[save_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.jpg']);
%% LFP and OIS
lfp_and_OIS_plot(protocol_path, t1, load_folder, save_folder, 0)
%% Cell_LFP_and_OIS
cell_lfp_and_OIS_plot(protocol_path, t1, load_folder, save_folder, 0,1)
