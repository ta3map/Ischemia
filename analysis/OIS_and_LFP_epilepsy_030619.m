% OIS and epilepsy
clear all
t1 = 502

cd('D:\Neurolab\ialdev\Ischemia\analysis')
protocol_path = 'D:\Neurolab\ialdev\Ischemia\Protocol\IschemiaProtocol.xlsx';
save_folder = 'D:\Neurolab\Data\Ischemia\Traces';
load_folder = 'D:\Neurolab\Data\Ischemia\Traces';
Protocol = readtable(protocol_path);
id = find(Protocol.ID == t1, 1);
name = Protocol.name{id};
raw_frq = round(1e6/si);

OIS_file = Protocol.IOSFile{id};
Data_file = Protocol.ABFFile{id};
%% load data

% Load LFP
subfolder = 'lfp_trace';
load([load_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.mat']);

% load OIS

subfolder = 'OIS_trace';
load([load_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.mat']);

% load puff triggers
subfolder = 'puff_triggers';
load([load_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.mat']);

[lost_time] = find_lost_time(Protocol, id)

SignalsIOS = SignalsIOS(1,:);

Time = Time + lost_time;
%% data parts
 OIS_set = [];
 LFP_set = [];
Bad_times = zeros(numel(Time),1)';
Bad_times = Time > 26.5;
t_wind = 0.5;
for i = 1:numel(trigger_time)-1
    Bad_times = (Time > trigger_time(i)-t_wind & Time < trigger_time(i)+t_wind) | Bad_times;
    
    Good_time_ois = Time > trigger_time(i)+t_wind & Time < trigger_time(i+1)-t_wind & Time < 26.5;
    Good_time_LFP = t_lfp > trigger_time(i)+t_wind & t_lfp < trigger_time(i+1)-t_wind & t_lfp < 26.5;
    OIS_set(i).Signal = SignalsIOS(Good_time_ois);
    OIS_set(i).Time = Time(Good_time_ois);
    LFP_set(i).Signal = lfp(Good_time_LFP);
    LFP_set(i).Time = t_lfp(Good_time_LFP);    
end

%% plot parts
clf
subplot(211)
hold on
for i = 1:numel(OIS_set)
plot(OIS_set(i).Time, OIS_set(i).Signal)
end
subplot(212)
hold on
for i = 1:numel(OIS_set)
plot(LFP_set(i).Time, LFP_set(i).Signal)
end
%% detect peaks
m = 0;
epilepsys = [];
epilepsys_Signal = [];
epilepsys_OIS = [];
event_time_window = (0.5)*1e4;

clf
hold on

for i = 1:4
    raw_data_part = LFP_set(i).Signal;
    time_data = LFP_set(i).Time;
    time_data = time_data - time_data(1);
    raw_OIS = OIS_set(i).Signal;
    time_OIS = OIS_set(i).Time;
    time_OIS = time_OIS - time_OIS(1);
    
data_part = -raw_data_part;
data_part = medfilt1(data_part, 200);
data_part = data_part-mean(data_part(1:10));
clear epilepsy_point
[~,epilepsy_point] = findpeaks(data_part,1,'MinPeakProminence',10,'MinPeakdistance',15e3);

after_event_data = 7e4;
after_event_OIS = 4;

for k = 1:numel(epilepsy_point)
    
    start_point = epilepsy_point(k) - event_time_window;
    end_point = epilepsy_point(k) + event_time_window;
    end_point = epilepsy_point(k) + after_event_data;
    
    if end_point < numel(data_part)
    m = m+1;
    

    epilepsy = raw_data_part(start_point:end_point);
    epilepsys(m).Signal = epilepsy - median(epilepsy(event_time_window-100 :event_time_window - after_event_OIS));
    epilepsys_Signal(:,m) = epilepsys(m).Signal;
    epilepsys_Signal_time = (time_data(start_point:end_point) - time_data(start_point))*60;
    
    [~, start_point_OIS] = min(abs(time_OIS - time_data(start_point)));
    [~, end_point_OIS] = min(abs(time_OIS - time_data(end_point)));
    
    end_point_OIS = start_point_OIS+30;
    if end_point_OIS < numel(raw_OIS)
        epilepsy_OIS = raw_OIS(start_point_OIS:end_point_OIS) - median(raw_OIS(start_point_OIS:start_point_OIS+3));  
        epilepsys_OIS(m, :) = epilepsy_OIS;
        epilepsys_OIS_time = (time_OIS(start_point_OIS:end_point_OIS) - time_OIS(start_point_OIS))*60;
        plot(epilepsys_OIS_time, epilepsy_OIS)
       
    end
    
    
    end

end
end



%%

clf
plot(data_part)
hold on
Lines(epilepsy_point);
plot(epilepsy)


%% epilepsys_Signal

M_epilepsys_OIS = mean(epilepsys_OIS);
M_epilepsys_Signal = mean(epilepsys_Signal');

clf
subplot(212)
hold on
plot(epilepsys_Signal_time-5, epilepsys_Signal, 'color', [0.8 0.8 0.8])
%plot(median(epilepsys_Signal'), 'color', 'red')
plot(epilepsys_Signal_time-5, M_epilepsys_Signal, 'color', 'blue')
ylim([-20 30])
xlim([-5 20])
ylabel('LFP (mV)')
xlabel('Time (sec)')
Lines(20, [], 'b', '--')
% epilepsys_OIS
%clf
%
subplot(211)
hold on
plot(epilepsys_OIS_time-5,epilepsys_OIS', 'color', [0.8 0.8 0.8])
plot(epilepsys_OIS_time-5, M_epilepsys_OIS, 'color', 'red', 'linewidth', 3)
%plot(mean(epilepsys_OIS), 'color', 'blue')
ylim([-0.8 1.2])
xlim([-5 80])
ylabel('OIS (%)')
xlabel('Time (sec)')
Lines(20, [], 'b', '--')
title([name ' mean epilepsy'], 'interpreter', 'none')

     point1 = [0 -.8];
     point2 = [0 -.5];
     arrow(point1,point2,15,'width',2, 'color', 'b')
     
%% save
save('D:\Neurolab\ialdev\Ischemia\Results\OIS_and_LFP_epilepsy_030619.mat')
saveas(gcf, 'D:\Neurolab\ialdev\Ischemia\Results\OIS_and_LFP_epilepsy_030619.jpg')