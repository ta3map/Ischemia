function lfp_and_OIS_plot(protocol_path, t1, load_folder, save_folder, tags)
% clear all
% t1 = 493
% load_folder = 'D:\Neurolab\Data\Ischemia\Traces';
% save_folder = 'D:\Neurolab\Data\Ischemia\Traces';
% protocol_path = 'D:\Neurolab\Ischemia\Protocol\IschemiaProtocol.xlsx';
% 
% %% make LFP
% lfp_make_lfp(protocol_path, t1, save_folder, 1)
%% Load LFP
Protocol = readtable(protocol_path);
id = find(Protocol.ID == t1, 1);
name = Protocol.name{id};

subfolder = 'lfp_trace';
load([load_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.mat']);

%% load OIS

subfolder = 'ios_trace';
load([load_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.mat']);

%% setup figure
f = figure(1);
f.Position = [10  240  960  540];
clf

%% plot LFP
subplot(211)
title(name, 'interpreter', 'none')
hold on
plot(t_lfp,lfp)

Ylims = ylim;
xlim([0 t_lfp(end)])

if tags
tag_y = Ylims(1);%[Ylims(2) - Ylims(1)]/3 + Ylims(1);
i = 0;
for active_tag = 1:size(hd.tags,2)
    i = i+1;
    tag_x = hd.tags(1,active_tag).timeSinceRecStart * hd.fADCSampleInterval/60;
    %tag_y = tag_y + 3*abs(min(lfp)/10);
Lines(tag_x, [], 'b', '--');

tagtext = [hd.tags(1,active_tag).comment];

text(tag_x-0.5, tag_y,tagtext,'Rotation',90, 'color', 'r');
TagTime(i) = tag_x;
TagText(i) = {tagtext};
end
end

ylabel(['LFP, ' hd.recChUnits{ch}])

%% plot OIS
subplot(212)
Ylims = [-40 60]


hold on

lost_time = t_lfp(end) - Time(end);
legend_text = {}
for n = 1%:n_probes
smSignalsIOS(n,:) = smooth(SignalsIOS(n,:),3)
    legend_text = [legend_text num2str(n)]
    
end

n = 1
p_time = Time + lost_time;
h = plot(p_time,smSignalsIOS(n,:))
set(h(n),'linewidth',2);

if tags
legend(legend_text)
end

xlim([0 Time(end)+ lost_time])

ylabel('OIS, %')
xlabel('Time, min')
%% SAVE graph
subfolder = 'lfp_and_OIS_image';
saveas(figure(1),[save_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.jpg']);
disp('OIS and LFP plotted and saved')
end