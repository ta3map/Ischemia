function [trigger_time] = puff_triggers(protocol_path, t1, save_folder, ch)

Protocol = readtable(protocol_path);

%% loading data
id = find(Protocol.ID == t1, 1);
name = Protocol.name{id};
filepath = Protocol.ABFFile{id};
% reading header
[~, ~, hd]=abfload(filepath, 'stop',1);
% name of interested channel
chName = hd.recChNames(ch);

[data, ~, hd]=abfload(filepath, 'channels', chName);
%% time where data rose up
trigger_point = find(diff(data) > 1);
trigger_time = (trigger_point/hd.si)/6e3;% mimutes

%% saving
subfolder = 'puff_triggers';
save([save_folder '\' subfolder '\' num2str(t1) '_' subfolder '_' name '.mat'], 'trigger_time','trigger_point', 'hd', 'ch');
disp('puff trigger time saved')
end