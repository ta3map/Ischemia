function lfp_make_lfp(protocol_path, t1, save_folder, ch)

%protocol_path = 'D:\Neurolab\Ischemia YG\Protocol\IschemiaYGProtocol.xlsx'
Protocol = readtable(protocol_path);

%% making lfp
id = find(Protocol.ID == t1, 1);
name = Protocol.name{id};
filepath = Protocol.ABFFile{id};

[data, si, hd]=abfload(filepath);
raw_frq = round(1e6/si);
lfp_frq = 1e3;
cftn=round(1e3/si);

lfp = resample(data(1:end,ch) - mean(data(1:end,ch)), lfp_frq , raw_frq);

t_lfp = zeros(numel(lfp),1);
t_lfp = (1:numel(lfp))/60e3;

lfp_mv = lfp*0.003;% 0.007% 0.003% 0.0009
%% plot lfp
f = figure(1);
f.Position = [10  240  960  540];
clf
hold on
plot(t_lfp,lfp, 'k', 'linewidth', 2)

Ylims = ylim;
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
xlim([0 t_lfp(end)])
%ylim([0,4000])
ylabel(['LFP, ' hd.recChUnits{ch}])
subfolder = 'lfp_trace';
title([num2str(t1) '_' subfolder '_' name], 'interpreter', 'none')
%% saving

subfolder = 'lfp_trace';
save([save_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.mat'], 'lfp','lfp_mv','t_lfp', 'hd', 'ch');

subfolder = 'lfp_image';
saveas(figure(1),[save_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.jpg']);
disp('saved')


end