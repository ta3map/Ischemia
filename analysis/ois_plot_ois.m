function ois_plot_ois(protocol_path, t1, SignalsIOS, Time, Ylim, n_probes,ios_frame, pos, interested_probe)
%% Plot OIS
Protocol = readtable(protocol_path);
id = find(Protocol.ID == t1, 1);
name = Protocol.name{id};

%SignalIOS_2 = locdetrend(SignalIOS, 1, [1000, 10]);%medfilt1(SignalIOS,5);
%[pks,locs] = findpeaks(SignalIOS_2, 'Threshold',0.8, 'MinPeakDistance',10);
f = figure(1);
f.Position = [10  240  960  540];
clf

B=axes;
set(B, 'Visible', 'on','position',[.565 .1 0.4 0.8]);

hold on
xlabel('Time, min')
ylabel('OIS, %')
ylim([min(SignalsIOS(n_probes,:)) max(SignalsIOS(n_probes,:))])
ylim(Ylim)

%tags from lfp
load_folder = 'D:\Neurolab\Data\Ischemia\Traces\lfp_trace\';
lost_time =0;
if  exist([load_folder num2str(t1) '_lfp_trace_' name '.mat']) == 'no'

load([load_folder num2str(t1) '_lfp_trace_' name '.mat'], 'lfp','hd');
t_lfp = (1:numel(lfp))/60e3;
Ylim = ylim;

lost_time = t_lfp(end) - Time(end);
tag_y = Ylim(2);
for active_tag = 1:size(hd.tags,2)
    tag_x = hd.tags(1,active_tag).timeSinceRecStart * hd.fADCSampleInterval/60;
    %tag_y = tag_y + 5;
Lines(tag_x);

tagtext = [ hd.tags(1,active_tag).comment, {}, num2str(hd.tags(1,active_tag).timeSinceRecStart * hd.fADCSampleInterval/60), 'min'];

text(tag_x, tag_y,tagtext );
end
end

for n = 1:n_probes
smSignalsIOS(n,:) = smooth(SignalsIOS(n,:),3)
end

p_time = Time + lost_time;
h = plot(p_time,smSignalsIOS)
set(h(interested_probe),'linewidth',2);

legend_text = {}
for n = 1:n_probes
    legend_text = [legend_text num2str(n)]
end
legend(legend_text)

xlim([0 Time(end)+ lost_time])

% IOS IMAGE
A=axes;
set(A, 'Visible', 'off','position',[.01 .1 0.5 0.8]);
hold on
colormap(gray)
imagesc(ios_frame);
set(gca, 'YDir','reverse')
caxis([-40 40])

for n = 1:n_probes
rectangle('Position',pos(n,:), 'EdgeColor', 'green')
text(pos(n,1)+3,pos(n,2)+6,[num2str(n)], 'color', 'green')
end


m = numel(smSignalsIOS(n,:));
text(10, 30, [num2str(round((m/24)*60))], 'Color', 'r', 'FontSize',10 );
text(70, 30, ['sec'], 'Color', 'r', 'FontSize',10 );
text(10, 60, [num2str(m/24,3)], 'Color', 'g', 'FontSize',12 );
text(60, 60, ['min'], 'Color', 'g', 'FontSize',12 );
end