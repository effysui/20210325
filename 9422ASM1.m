%% Q2

clc;clear;

%Change to cvs file derictory
path='/Users/suiyudian/Desktop/9422/ASM 1/MobileCentury_data_final_ver3/NB_veh_files/';
Files = dir(strcat(path,'*.csv'));
LengthFiles = length(Files);
for i = 1:LengthFiles
    name=strcat(path,'veh_',string(i),'.csv');
    csv_data = readtable(name);
    t=csv_data.unixTime;
    length_t=length(t);
    t2=[];
    %Convert Unix Time to datetime format
    for j =1:length_t
        tt = datetime(t(j),'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss','TimeZone','America/Los_Angeles');
        t2=[t2;tt];
        % append
    end
    l=csv_data.postmile;
    s=csv_data.speed;
    figure(1)
    plot(t2,l,'blue');
    xlabel("Time of Day");
    ylabel("Postmile");
    ylim([17,27.5]);
    title("Time-Space Diagram");
    hold on
end

%% Q3

pems=readtable('pems_prop_NB.csv');
Q3data=readtable('Q3data.csv');

Postimile=[];
for a=1:size(Q3data)
    for b = 1:size(pems)
    if Q3data.fk_pems_id(a)==pems.pems_id(b)
        Postimile=[Postimile;pems.abs_pm(b)];
    end
    end
end

Flow=[];
Occ=[];
flow_all=Q3data.flows;
occ_all=Q3data.occs;
for i = 1:size(flow_all)
n=flow_all{i}(2:end-1);
m=occ_all{i}(2:end-1);
n=str2num(n);
n=mean(n)*120;
m=str2num(m);
m=mean(m);
Occ=[Occ;m];
Flow=[Flow;n];
end

Flow(isnan(Flow)==1)=0;
Occ(isnan(Occ)==1)=0;
Density=1000/(4.5+1.8).*Occ;
%% 2nd method
time=Q3data.Time;
flow1=Q3data.flows1;
flow2=Q3data.flow2;
flow3=Q3data.flow3;
flow4=Q3data.flow4;
occ1=Q3data.occ1;
occ2=Q3data.x_occ2;
occ3=Q3data.occ3;
occ4=Q3data.occ4;
unixtime=Q3data.unixtime;

flow1=120*flow1;
flow2=120*flow2;
flow3=120*flow3;
flow4=120*flow4;

h=height(Q3data);
d=Postimile;
D1=1000/(4.5+1.8)*occ1;
D2=1000/(4.5+1.8)*occ2;
D3=1000/(4.5+1.8)*occ3;
D4=1000/(4.5+1.8)*occ4;

s1=flow1./D1;
s1(isnan(s1)==1)=0;
s2=flow2./D2;
s2(isnan(s2)==1)=0;
s3=flow3./D3;
s3(isnan(s3)==1)=0;
s4=flow4./D4;
s4(isnan(s4)==1)=0;
%%
all_lane_speed=(flow1.*s1+flow2.*s2+flow3.*s3+flow4.*s4)./(flow1+flow2+flow3+flow4);
all_lane_speed(isnan(all_lane_speed)==1)=0;
%%
Time_new=[];
for i = 1:287
Time_new(1)= 1202493600;
Time_new(i+1)=Time_new(i)+300;
end
Time_new=Time_new';

%% 
ID=Q3data.fk_pems_id;
ave_speed=[];
ave_d=[];
ID_vec=[];
ave_flow=[];
ave_occ=[];
ave_unixtime=[];
h=height(Q3data);
count=0;
ID1=pems.pems_id;
%ID1=400539;
for id=1:size(ID1)
    x= ID ==ID1(id);
    newID=x.*ID;
    newID(find(newID==0))=[];
    newUtime=x.*unixtime;
    newUtime(find(newUtime==0))=[];
    newSpeed=x.*all_lane_speed;
    newSpeed(find(newSpeed==0))=[];
    newD=x.*d;
    newD(find(newD==0))=[];
    newFlow=x.*Flow;
    newFlow(find(newFlow==0))=[];
    newOcc=x.*Occ;
    newOcc(find(newOcc==0))=[];
    h = size(newSpeed);
    for i = 0 : 10 : h-10  
        if ID(i+1)== ID(i+10)
            ave_d=[ave_d;newD(i+1)];
            ave_speed=[ave_speed;mean(newSpeed(i+1:i+10))];
            ave_flow=[ave_flow;mean(newFlow(i+1:i+10))];
            ave_occ=[ave_occ;mean(newOcc(i+1:i+10))];
            for m = 1:288
                mean_time=mean(newUtime(i+1:i+10));
                a = mean_time-Time_new(m);
                if (a < 300 && mean_time-Time_new(m)>0) || mean_time-Time_new(m)==0
                    ave_unixtime=[ave_unixtime;Time_new(m)];
                    break
                end
            end
        end
    end
    
    if mod(h,10)~=0
        ave_d=[ave_d;newD(end)];
        ave_speed=[ave_speed;mean(newSpeed(end-mod(h,10)+1:end))];
        ave_flow=[ave_flow;mean(newFlow(i+1:i+10))];
        ave_occ=[ave_occ;mean(newOcc(i+1:i+10))];
        for m = 1:288
            mean_time=mean(newUtime(i+1:i+10));
            b = mean_time-Time_new(m);
            if (b < 300 && mean_time-Time_new(m)>0) || mean_time-Time_new(m)==0
                ave_unixtime=[ave_unixtime;Time_new(m)];
                break
            end
        end
    end
end
UTC=[];
for n=1:size(ave_unixtime)
    UTC_time = datetime(ave_unixtime(n),'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss','TimeZone','America/Los_Angeles');
    UTC=[UTC;UTC_time];
end

ave_speed(isnan(ave_speed)==1)=0;
T=table(UTC,ave_speed,ave_d);
%%
figure(2);
heatmap(T,'UTC','ave_d','ColorVariable','ave_speed');
colorbar;
colormap(flipud(jet));
xlabel("Time");
ylabel("Postmile");
%% Q4 & Q5
%Flow=(flow1+flow2+flow3+flow4)/4;
%Occ=(occ1+occ2+occ3+occ4)/4;

ID=Q3data.fk_pems_id;
ave_speed=[];
ave_d=[];
ID_vec=[];
ave_flow=[];
ave_occ=[];
ave_unixtime=[];
h=height(Q3data);
count=0;

%choose a random ID number to get plots

ID1=pems.pems_id(16);
for id=1:size(ID1)
    x= ID ==ID1(id);
    newID=x.*ID;
    newID(find(newID==0))=[];
    newUtime=x.*unixtime;
    newUtime(find(newUtime==0))=[];
    newSpeed=x.*all_lane_speed;
    newSpeed(find(newSpeed==0))=[];
    newD=x.*d;
    newD(find(newD==0))=[];
    newFlow=x.*Flow;
    newFlow(find(newFlow==0))=[];
    newOcc=x.*Occ;
    newOcc(find(newOcc==0))=[];
    h = size(newSpeed);
    for i = 0 : 10 : h-10  
        if ID(i+1)== ID(i+10)
            ave_d=[ave_d;newD(i+1)];
            ave_speed=[ave_speed;mean(newSpeed(i+1:i+10))];
            ave_flow=[ave_flow;mean(newFlow(i+1:i+10))];
            ave_occ=[ave_occ;mean(newOcc(i+1:i+10))];
            for m = 1:288
                mean_time=mean(newUtime(i+1:i+10));
                a = mean_time-Time_new(m);
                if (a < 300 && mean_time-Time_new(m)>0) || mean_time-Time_new(m)==0
                    ave_unixtime=[ave_unixtime;Time_new(m)];
                    break
                end
            end
        end
    end
    
    if mod(h,10)~=0
        ave_d=[ave_d;newD(end)];
        ave_speed=[ave_speed;mean(newSpeed(end-mod(h,10)+1:end))];
        ave_flow=[ave_flow;mean(newFlow(i+1:i+10))];
        ave_occ=[ave_occ;mean(newOcc(i+1:i+10))];
        for m = 1:288
            mean_time=mean(newUtime(i+1:i+10));
            b = mean_time-Time_new(m);
            if (b < 300 && mean_time-Time_new(m)>0) || mean_time-Time_new(m)==0
                ave_unixtime=[ave_unixtime;Time_new(m)];
                break
            end
        end
    end
end

Time_q5=ave_unixtime;
UTC2=[];
for n=1:size(Time_q5)
    UTC_time = datetime(Time_q5(n),'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss','TimeZone','America/Los_Angeles');
    UTC2=[UTC2;UTC_time];
end
ID_q5=ave_d;
Flow_q5=ave_flow;
Occ_q5=ave_occ;
Speed_q5=ave_speed;
T_q4=table(UTC2,ID_q5,Flow_q5,Occ_q5,Speed_q5);
T_q42=table(unixtime,ID,Flow,Occ,all_lane_speed);

figure(3);
subplot(2,1,1);
scatter(T_q4.Occ_q5,T_q4.Flow_q5);
ylabel('Flow(veh/h)');
xlabel('Occupancy(%)');
title('Flow vs. Occupancy');

subplot(2,1,2);
scatter(T_q4.Occ_q5,T_q4.Speed_q5);
ylabel('Speed(km/h)');
xlabel('Occupancy(%)');
title('Speed vs. Occupancy');


figure(4);
plot(T_q4.UTC2,T_q4.Speed_q5,'o--');
xlabel('time');
ylabel('speed(km/h)');
title('Time-speed diagram');
%% Useless Code
ave_speed2=zeros(h,1);
ave_d2=zeros(h,1);
ave_time2=zeros(h,1);
for i = 0:h-10
       ave_speed2(i+1)=ave_speed(fix(i/10)+1);
       ave_d2(i+1)=ave_d(fix(i/10)+1);
       ave_time2(i+1)=ave_time(fix(i/10)+1);
end

T2=table(ave_time2,ave_speed2,ave_d2);

heatmap(T2,'ave_time2','ave_d2','ColorVariable','ave_speed2');
colorbar;
colormap(flipud(jet));
xlabel("Time");
ylabel("Postmile");