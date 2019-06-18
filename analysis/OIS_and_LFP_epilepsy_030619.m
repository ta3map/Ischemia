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

after_event_data = 2e4;
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
%% save mat
save('D:\Neurolab\ialdev\Ischemia\Results\OIS_and_LFP_epilepsy_030619.mat')
saveas(gcf, 'D:\Neurolab\ialdev\Ischemia\Results\OIS_and_LFP_epilepsy_030619.jpg')

%% PART 2
%% epilepsy time duration
N_p = [];
for m = 1:size(epilepsys_Signal, 2)

raw_data_part = epilepsys_Signal(:,m);
data_part = -raw_data_part;
data_part = medfilt1(data_part, 200);
data_part = data_part-mean(data_part(1:10));
% find number of peaks
clear epilepsy_point
[~,peaks_in_part] = findpeaks(data_part,1,'MinPeakProminence',5,'MinPeakdistance',1e3);
N_p(m) = numel(peaks_in_part);

epilepsys(m).peaks = peaks_in_part;
epilepsys(m).number_of_peaks = N_p(m);

clf
plot(data_part)
Lines(peaks_in_part);
title(N_p(m))
pause(0.1)
end
%% Average power

N = numel(epilepsys_Signal(:,1))
Average_power = [];
for m = 1:size(epilepsys_Signal, 2)
data_part = epilepsys_Signal(:,m);
Average_power(m) = (1/N) * sum(data_part.^2);
end

clf
plot(Average_power)
%% OIS amplitude and average power

Average_OIS_power = [];
N_OIS = numel(epilepsys_OIS(1, :))

for m = 1:size(epilepsys_Signal, 2)-1
data_part_OIS = epilepsys_OIS(m, :)
Average_OIS_power(m) = (1/N_OIS) * sum(data_part_OIS.^2);

clf, hold on
plot(data_part_OIS)
title(Average_OIS_power(m))
end

Average_OIS_power(14) = 0;
%% comparison of awerage powers

y = Average_OIS_power;
x = Average_power

y_label = 'OIS AP';
x_label = 'LFP AP';
title_text = ['Average power (AP) comparison for ' name];

clf
subplot(411)
hold on
plot(y)
ylabel(y_label)
title(title_text, 'interpreter', 'none')


subplot(412)
plot(x)
ylabel(x_label)

% fit
f2 = fit(y',x','exp1','StartPoint',[1,2]);
p_fit = polyfit(x, y,1); 
y_fit = polyval(p_fit,x); 

x(x==0) = nan;
y(y==0) = nan;

% plot
subplot(212)
hold on
%plot(f2,x, y)
scatter(x, y,'filled')
%plot(x,y_fit)

ylim([0 4])

xlabel(x_label)
ylabel(y_label)
grid on
%legend('data','linear fit') 
%% save AP comparison
saveas(gcf, ['D:\Neurolab\ialdev\Ischemia\Results\' title_text '.jpg'])
%% comparison of number and powers

y = Average_OIS_power;
x = N_p;

y_label = 'OIS AP';
x_label = 'LFP events';
title_text = ['comparison of OIS average power (AP) and number of epileptic events for ' {} name];

clf
subplot(411)
hold on
plot(y)
ylabel(y_label)
title(title_text, 'interpreter', 'none')


subplot(412)
plot(x)
ylabel(x_label)

% fit
f2 = fit(y',x','exp1','StartPoint',[1,2]);
p_fit = polyfit(x, y,1); 
y_fit = polyval(p_fit,x); 

x(x==0) = nan;
y(y==0) = nan;

% plot
subplot(212)
hold on
%plot(f2,x, y)
scatter(x, y,'filled')
%plot(x,y_fit)

%ylim([0 4])
xlim([0 8])

xlabel(x_label)
ylabel(y_label)
grid on
%legend('data','linear fit') 
%% save AP and events comparison
saveas(gcf, ['D:\Neurolab\ialdev\Ischemia\Results\comparison of OIS average power (AP) and number of epileptic events for 030619_P15_slc3.jpg'])
%% save mat
save('D:\Neurolab\ialdev\Ischemia\Results\OIS_and_LFP_epilepsy_030619.mat')
saveas(gcf, 'D:\Neurolab\ialdev\Ischemia\Results\OIS_and_LFP_epilepsy_030619.jpg')

%% PART 3
% examine sample of typical clean LFP epilepsy
%% detect points

d_lfp = medfilt1(-lfp, 3);

clear epilepsy_point
[~,epilepsy_point] = findpeaks(d_lfp,1,'MinPeakProminence',10,'MinPeakdistance',15e3);

%% select point
n = 8;

clf
subplot(311)
hold on
plot(t_lfp*60, lfp)
Lines(60*t_lfp(epilepsy_point), [], [0.5 0.5 0.5], '--');

% select epilepsy
Lines(60*t_lfp(epilepsy_point(n)))


xlim([60*t_lfp(epilepsy_point(n))-50 60*t_lfp(epilepsy_point(n))+50]);

subplot(312)
pwind = 30e3;
strtp = epilepsy_point(n)-pwind;
endp = epilepsy_point(n)+pwind;
datapart_times = 60*(t_lfp(strtp:endp) - t_lfp(strtp) - t_lfp(pwind));
plot(datapart_times,lfp(strtp:endp))
xlim([-150 150])


subplot(313)
[~, epilepsy_point_OIS] = min(abs(Time - t_lfp(epilepsy_point(n))));
pwind_OIS = 50;
strtp_OIS = epilepsy_point_OIS - pwind_OIS;
strtp_OIS(strtp_OIS<0) = 1;
endp_OIS = epilepsy_point_OIS + pwind_OIS; 
datapart_times_OIS = (Time(strtp_OIS:endp_OIS) - Time(strtp_OIS))*60;
datapart_times_OIS = datapart_times_OIS - datapart_times_OIS(epilepsy_point_OIS - strtp_OIS);

plot(datapart_times_OIS, SignalsIOS(strtp_OIS:endp_OIS))
Lines(0)

xlim([-150 150])
%% refresh counter
i = 0;
Dataset_point = [];
Dataset_signal = [];
Dataset_n = [];

Dataset_point_OIS = [];
%% add to set
i = i+1;
Dataset_point(i) = epilepsy_point(n);
Dataset_n(i) = n;

%% collect data

Dataset_signal = [];
Dataset_point_OIS = [];
for i = 1:size(Dataset_n, 2)
    
n = Dataset_n(i);
pwind = 30e3;
strtp = epilepsy_point(n)-pwind;
endp = epilepsy_point(n)+pwind;

Dataset_signal(:,i) = lfp(strtp:endp) - lfp(epilepsy_point(n));



[~, epilepsy_point_OIS] = min(abs(Time - t_lfp(epilepsy_point(n))));
pwind_OIS = 50;
strtp_OIS = epilepsy_point_OIS - pwind_OIS;
strtp_OIS(strtp_OIS<0) = 1;
endp_OIS = epilepsy_point_OIS + pwind_OIS; 

Dataset_point_OIS(:,i) = SignalsIOS(strtp_OIS:endp_OIS) - SignalsIOS(epilepsy_point_OIS);

end

%% median set
M_Dataset_signal = median(Dataset_signal, 2);
M_Dataset_signal_OIS = smooth(median(Dataset_point_OIS, 2), 3);


clf
subplot(211)
hold on
plot(datapart_times, Dataset_signal, 'color', [0.8 0.8 0.8])
plot(datapart_times, M_Dataset_signal)
xlim([-30 30])
ylabel('LFP (mV)')
titletext = ['Clean epilepsy signals from ' name ', n = ' num2str(i)];
title(titletext, 'interpreter', 'none')

subplot(212)
hold on
plot(datapart_times_OIS-2.5, Dataset_point_OIS, 'color', [0.8 0.8 0.8])
plot(datapart_times_OIS-2.5, M_Dataset_signal_OIS, 'linewidth', 2)
xlim([-30 30])
ylabel('OIS (%)')
xlabel('Time (sec)')

%% save mat
save('D:\Neurolab\ialdev\Ischemia\Results\OIS_and_LFP_epilepsy_030619.mat')
saveas(gcf, ['D:\Neurolab\ialdev\Ischemia\Results\' titletext '.jpg'])


