function [lost_time] = find_lost_time(Protocol, id)
%%
OIS_filename = Protocol.IOSFile{id};
LFP_filename = Protocol.ABFFile{id};

S1 = System.IO.File.GetCreationTime(OIS_filename)
S2 = System.IO.File.GetCreationTime(LFP_filename)

creationDateTime1 = datetime(S1.Year, S1.Month, S1.Day, S1.Hour, S1.Minute, S1.Second);
creationDateTime2 = datetime(S2.Year, S2.Month, S2.Day, S2.Hour, S2.Minute, S2.Second);

timediff = creationDateTime2 - creationDateTime1;
lost_time = minutes(timediff)

end