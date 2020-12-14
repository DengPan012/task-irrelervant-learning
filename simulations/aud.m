%% ��Ƶ����
clear
InitializePsychSound(1);
lastTime=0.2;%����ʱ��60ms
sr=44100;%����Ƶ��44100Hz
gatedur=0.005;%���뵭��ʱ��5ms
%Freq1=500;Freq2=1500;Freq3=1000;%Ƶ��500Hz
Freq1=700;Freq2=1700;Freq3=1200;%Ƶ��500Hz
%Freq1=200;Freq2=1500;Freq3=1000;%Ƶ��500Hz
tone1(1,:)=MakeBeep(Freq1,lastTime,sr);
tone2(1,:)=MakeBeep(Freq2,lastTime,sr);
tone3(1,:)=MakeBeep(Freq3,lastTime,sr);
tone4(1,:)=MakeBeep(Freq2,lastTime,sr);
tone=[tone1,tone2,tone3,tone4];
ramplen=[sr*gatedur,sr*gatedur];
L = length(tone);
L1 = round(ramplen(1));%����
L2 = round(ramplen(2));%����
gw_up = linspace(1,0,L1+1)';%���Ա任
win_up = [gw_up;flipud(gw_up(2 : end - 1))];
r1=win_up(L1 + 1 : 2 * L1);
gw_down=linspace(1,0,L2+1)' ;
win_down=[gw_down;flipud(gw_down(2:end-1))];
r2=win_down(1:L2);
ramp=[r1;ones(L-L1-L2,1);r2];
newtone(1,:)=tone.*ramp';
newtone(2,:)=newtone(1,:);%��������������һ��
pahandle=PsychPortAudio('Open',[],[],2,sr); 
PsychPortAudio('FillBuffer',pahandle,newtone);
PsychPortAudio('Start',pahandle);
tic
while toc<=5
x=1;
end
PsychPortAudio('Close');