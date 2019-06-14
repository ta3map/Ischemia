% OIS and epilepsy
clear all
t1 = 525

cd('D:\Neurolab\ialdev\Ischemia\analysis')
protocol_path = 'D:\Neurolab\ialdev\Ischemia\Protocol\IschemiaProtocol.xlsx';
save_folder = 'D:\Neurolab\Data\Ischemia\Traces';
load_folder = 'D:\Neurolab\Data\Ischemia\Traces';
Protocol = readtable(protocol_path);
id = find(Protocol.ID == t1, 1);
name = Protocol.name{id};
raw_frq = round(1e6/si);

OIS_xls_file = '\\IFMB-02-024B-10\Ischemia2\OOS\2019-06-14\140619_slc1.xlsx'
Data_file = Protocol.ABFFile{id};

%% loading data
ch = 3;
% reading header
[~, ~, hd]=abfload(Data_file, 'stop',1);
% name of interested channel
chName = hd.recChNames(ch);
[data, si, hd]=abfload(Data_file, 'channels', chName);
%%
OIS_data = readtable(OIS_xls_file);
OIS_data.Properties.VariableNames
OIS_time = OIS_data.Time_min__1;
OIS_ampl =  OIS_data.OIS____1;
%%
% OIS_time = (1:size(OIS_data.OIS____1, 1))*(0.1/59);
% 
% data_time = ((1:size(data,1))/raw_frq)/60;
% 
% fixedTime = [];
% fixedTimes = [];
% Time = OIS_data.Time_min__1(31:59:end);
% stp = 0.1/59;
% for i = 1:size(Time,1)
% fixedTime = Time(i) + (0:stp:0.1-stp);
% fixedTimes = [fixedTimes fixedTime];
% end
% fixedTimes = fixedTimes - 0.1;
% fixedTimes(1:29) = [];
% fixedTimes = [fixedTimes nan*(1:9)];
%%

end_time = 10;
end_time_data_inx = find(data_time >= end_time, 1);
end_time_OIS_inx = find(OIS_time >= end_time, 1);
[lost_time] = find_lost_time(Protocol, id)

OIS_part = OIS_ampl(1:1:end_time_OIS_inx);
OIS_part_time = OIS_time(1:1:end_time_OIS_inx)+lost_time;

data_part = (data(1:1:end_time_data_inx)-data(1));
data_part_time = data_time(1:1:end_time_data_inx);
%%
r_data_part = resample(data_part, 100 , raw_frq);
r_DP_time = (1:size(r_data_part))/6e3;
%%
d_data_part = locdetrend(r_data_part, 100, [300, 30]);
d_DP_time = r_DP_time;
%%
[y,x] = findpeaks(-d_data_part,100,'MinPeakProminence',200);
%% plot
clf
subplot(211)
title([name ' with epilepsy'], 'interpreter', 'none')
hold on
plot(OIS_part_time,OIS_part, 'k')
Lines(x/60, [],[0.8 0.8 0.8], '--');
ylabel('OIS (%)')

subplot(212)
hold on
plot(r_DP_time,d_data_part, 'k')
Lines(x/60, [],[0.8 0.8 0.8], '--');
ylim([-400 120])
ylabel(['LFP (' hd.recChUnits{ch} ')'])
xlabel('Time (min)')
%% where is tags
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

%% save plot
saveas(gcf, 'D:\Neurolab\ialdev\Ischemia\Results\OIS_with epilepsy.jpg')
%% show some
inx = 53
Lines(x(inx)/60, [],'r', '-');
%% insert peak_indexes
Peak_inxes = [Peak_inxes inx]
%% clear peak_indexes
Peak_inxes = [];



%% insert Fals_indexes
Fals_inxes = [Fals_inxes inx]
%% clear Fals_indexes
Fals_inxes = [];


%% data_frames
clf, hold on

Xwind = 60;
Xpoint = Xwind+1;
DF_time = d_DP_time(Xpoint-Xwind:Xpoint+Xwind);

for i = 1:size(x, 1)
Xpoint = round(x(i)*100);

data_frame = d_data_part(Xpoint-Xwind:Xpoint+Xwind) - d_data_part(Xpoint-Xwind);

plot(DF_time,data_frame)
end
%% OIS frames
clf, hold on

ois_Xwind = 60;
after = 0;
for i = 1:size(x, 1)-2
    ois_point_time(i) = x(i)/60;
    ois_Xpoint = find(OIS_part_time >= ois_point_time(i),1);

    OIS_frame = OIS_part(ois_Xpoint+after:ois_Xpoint+ois_Xwind+after) - OIS_part(ois_Xpoint);

    plot(smooth(OIS_frame))
end

%% OIS with peaks
f = figure(1);
f.Position = [10  240  760  540];

Peaks_OIS_frames = [];
clf, hold on
ois_dt = OIS_part_time(2-1);
ois_Xwind = 400;
Peaks_OIS_time = OIS_part_time(1:ois_Xwind)*60 - OIS_part_time(1)*60;
n = numel(Peak_inxes);
after = 0;

for i = 1:numel(Peak_inxes)
    ois_point_time(i) = x(Peak_inxes(i))/60;
    ois_Xpoint = find(OIS_part_time >= ois_point_time(i),1);

    OIS_frame = OIS_part(ois_Xpoint+after:ois_Xpoint+ois_Xwind+after) - OIS_part(ois_Xpoint);
    Peaks_OIS_frames(i,:) = smooth(OIS_frame(1:end-1));
    plot(Peaks_OIS_time, smooth(OIS_frame(1:end-1)))
end

ylabel('OIS (%)')
xlabel('Time (sec)')
xlim([0 Peaks_OIS_time(end)])
title(['OIS at epilepsy' {} ['with peaks']])
%% save
saveas(gcf, 'D:\Neurolab\ialdev\Ischemia\Results\OIS_with peaks at epilepsy.jpg')
%% OIS with fals
f = figure(1);
f.Position = [10  240  460  540];

clf, hold on
ois_dt = OIS_part_time(2-1);
ois_Xwind = 100;
Fals_OIS_frames = [];
Fals_OIS_time =  OIS_part_time(1:ois_Xwind)*60 - OIS_part_time(1)*60;
n = numel(Fals_inxes);
after = 0;

for i = 1:numel(Fals_inxes)
    ois_point_time(i) = x(Fals_inxes(i))/60;
    ois_Xpoint = find(OIS_part_time >= ois_point_time(i),1);
    
    OIS_frame = OIS_part(ois_Xpoint+after:ois_Xpoint+ois_Xwind+after) - mean(OIS_part(ois_Xpoint-10:ois_Xpoint));
    Fals_OIS_frames(i,:) = smooth(OIS_frame(1:end-1));
    plot(Fals_OIS_time, smooth(OIS_frame(1:end-1)), 'color', [0.8 0.8 0.8])
end

M_Fals_OIS_frames = median(Fals_OIS_frames,1);
plot(Fals_OIS_time, M_Fals_OIS_frames, 'r', 'linewidth', 2)


ylabel('OIS (%)')
xlabel('Time (sec)')
xlim([0 Fals_OIS_time(end)])
title(['OIS at epilepsy' {} ['with falls'] ['n = ' num2str(n) '']])

     point1 = [1.5 -0.3];
     point2 = [2 -0.2];
     arrow(point1,point2,15,'width',2, 'color', 'k')
%% save
saveas(gcf, 'D:\Neurolab\ialdev\Ischemia\Results\OIS_with falls at epilepsy.jpg')