function cell_lfp_and_OIS_plot(protocol_path, t1, load_folder, save_folder, tags, puff, LFP_Ylim, wcell_Ylim, OIS_Ylim, lost_time)
% clear all
% t1 = 493
% load_folder = 'D:\Neurolab\Data\Ischemia\Traces';
% save_folder = 'D:\Neurolab\Data\Ischemia\Traces';
% protocol_path = 'D:\Neurolab\Ischemia\Protocol\IschemiaProtocol.xlsx';
% 
% %% make LFP
% lfp_make_lfp(protocol_path, t1, save_folder, 1)
%% Load Cell
Protocol = readtable(protocol_path);
id = find(Protocol.ID == t1, 1);
name = Protocol.name{id};

subfolder = 'wcell_trace';
load([load_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.mat']);
%% load puff triggers
subfolder = 'puff_triggers';
load([load_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.mat']);
%% Load LFP
subfolder = 'lfp_trace';
load([load_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.mat']);

%% load OIS

subfolder = 'OIS_trace';
load([load_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.mat']);

%% setup figure
f = figure(1);
f.Position = [10  240  960  540];
clf
%% plot Cell
ch = 1
subplot(311)
title(name, 'interpreter', 'none')
hold on
plot(t_wcell,wcell)

ylim(wcell_Ylim);

Ylims = ylim;
xlim([0 t_wcell(end)])

ylabel(['Whole cell, ' hd.recChUnits{ch}])
%% plot LFP
ch = 3
subplot(312)
hold on
plot(t_lfp,lfp)

ylim(LFP_Ylim);

Ylims = ylim;
xlim([0 t_lfp(end)])
Xlims = xlim;

Ysize = Ylims(2) - Ylims(1);
Xsize = Xlims(2) - Xlims(1);

if tags
tag_y = Ylims(1);%[Ylims(2) - Ylims(1)]/3 + Ylims(1);
i = 0;
for active_tag = 1:size(hd.tags,2)
    i = i+1;
    tag_x = hd.tags(1,active_tag).timeSinceRecStart * hd.fADCSampleInterval/60;
    %tag_y = tag_y + 3*abs(min(lfp)/10);
%Lines(tag_x, [], 'b', '--');

     point1 = [tag_x Ylims(1)];
     point2 = [tag_x [Ylims(2) - Ylims(1)]/6 + Ylims(1)];
     arrow(point1,point2,8,'width',0.5, 'color', 'k')


tagtext = [hd.tags(1,active_tag).comment];
text(tag_x+Xsize/100, Ylims(1)+Ysize/15, tagtext(1:3),'Rotation',90)

%text(tag_x-0.5, tag_y,tagtext,'Rotation',90, 'color', 'r');
TagTime(i) = tag_x;
TagText(i) = {tagtext};
end
end

if puff
    %Lines(trigger_time,[], 'b', '--');
    for k = 1:numel(trigger_time)
     point1 = [trigger_time(k) Ylims(1)];
     point2 = [trigger_time(k) [Ylims(2) - Ylims(1)]/6 + Ylims(1)];
     arrow(point1,point2,8,'width',0.5, 'color', 'red')
    
    %text(trigger_time(k), Ylims(2)+Ysize/20, '\mid', 'fontsize', 18, 'color', 'red')
    
    end
    text(trigger_time(1)+Xsize/100, Ylims(1)+Ysize/15, 'puff', 'color', 'red')
end


ylabel(['LFP, ' hd.recChUnits{ch}])

%% plot OIS
subplot(313)

ylim(OIS_Ylim);


hold on

%lost_time = t_lfp(end) - Time(end);
legend_text = {}
for n = 1%:n_probes
smSignalsIOS(n,:) = smooth(SignalsIOS(n,:),3)
    legend_text = [legend_text num2str(n)]
    
end

n = 1
p_time = Time + lost_time;
h = plot(p_time,smSignalsIOS(n,:))
set(h(n),'linewidth',2);



%xlim([0 Time(end)+ lost_time])
xlim([0 t_lfp(end)])

ylabel('OIS, %')
xlabel('Time, min')
%% SAVE graph
subfolder = 'wcell_lfp_and_OIS_image';
saveas(figure(1),[save_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.jpg']);
disp('Cell, OIS and LFP plotted and saved')
end