clear;clc; close all
high=80;low=20;scale=34;mid=50;Num=100;
Pbox=[low,mid,high];
A=[];B=[];cor=5;
kk=5;xiao=2;
R1=cor+(randi(kk)-1)*xiao+1;R21=cor+(randi(kk)-1)*xiao+1;
R2=R1+cor+(randi(kk)-1)*xiao;R22=R21+cor+(randi(kk)-1)*xiao;
R3=R2+cor+(randi(kk)-1)*xiao;R23=R22+cor+(randi(kk)-1)*xiao;
R4=R3+cor+(randi(kk)-1)*xiao;R24=R23+cor+(randi(kk)-1)*xiao;
R5=R4+cor+(randi(kk)-1)*xiao;R25=R24+cor+(randi(kk)-1)*xiao;
R6=R5+cor+(randi(kk)-1)*xiao;R26=R25+cor+(randi(kk)-1)*xiao;
R7=R6+cor+(randi(kk)-1)*xiao;R27=R26+cor+(randi(kk)-1)*xiao;
R8=R7+cor+(randi(kk)-1)*xiao;R28=R27+cor+(randi(kk)-1)*xiao;
R9=R8+cor+(randi(kk)-1)*xiao;R29=R28+cor+(randi(kk)-1)*xiao;
R10=R9+cor+(randi(kk)-1)*xiao;R210=R29+cor+(randi(kk)-1)*xiao;
R11=R10+cor+(randi(kk)-1)*xiao;R211=R210+cor+(randi(kk)-1)*xiao;
R12=R11+cor+(randi(kk)-1)*xiao;R212=R211+cor+(randi(kk)-1)*xiao;
a=mid;b=mid;
aBox=zeros(1,Num);
bBox=zeros(1,Num);
j=0;
QA=[];QB=[];PEBOX=[];
VIa=0.5;VIb=0.5;
TH=1;
CC=[];
upP=90;downP=10;
for beta=1
    for alpha=ones(1,1).*0.5
        j=j+1;
        a0=80;b0=80;
        for i=1:Num
            if ismember(i,[R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12])
                a=Pbox(randi(length(Pbox)));
                b=Pbox(randi(length(Pbox)));
            end
            a0=a+randn*randi(15);b0=b+randn*randi(15);
            while ~(a0>downP && a0<upP)
            if a0>=upP
                a0=2*upP-a0;
            end
            if a0<=downP
                a0=2*downP-a0;
            end
            end
            while ~(b0>downP && b0<upP)
            if b0>=upP
                b0=2*upP-b0;
            end
            if b0<=downP
                b0=2*downP-b0;
            end
            end
            aBox(i)=a0;
            bBox(i)=b0;
        end
        dotSize=25;
        
        A=aBox./100;B=bBox./100;
        Aout=binornd(ones(size(A)),A);
        Bout=binornd(ones(size(B)),B);
        if j==1
            figure
            subplot(3,1,1)
            hold on
            scatter(1:Num,Aout.*0.8+0.11+0.08.*rand(size(Aout)),dotSize,'b','filled')
            scatter(1:Num,Bout.*0.8+0.09-0.08.*rand(size(Bout)),dotSize,'g','filled')
            plot(A,'-','Color',[0 0 180]./255,'LineWidth',2)
            plot(B,'-','Color',[0 180 0]./255,'LineWidth',2)
        end
        ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
        ylabel('Probability');xlabel('trial');xlim([0 Num]);
        %% 模拟被试
        QL=@(q,r)q+alpha.*(r-q);
        Pi=@(Qi,Qj)exp(Qi./beta)/(exp(Qi./beta)+exp(Qj./beta));
        RA_Box=Aout;RB_Box=Bout;
        qa_Box=zeros(size(Aout));qb_Box=zeros(size(Bout));PE_Box=zeros(size(Aout));
        Choice_Box=zeros(size(Aout));qa=VIa;qb=VIb;
        rBox=zeros(1,Num);conChoice=zeros(1,Num);conReward=zeros(1,Num);Appear=zeros(1,Num);conAppear=zeros(1,Num);
        for i=1:Num
            Pca=Pi(qa,qb);
            %Choice=(Pca>=0.5)*1;
            Choice=binornd(1,Pca);Choice_Box(i)=Choice;
            if i>=2
                if oldChoice==Choice
                    conChoice(i)=conChoice(i-1)+1;
                else
                    conChoice(i)=0;
                end
            end
            oldChoice=Choice;
            if Choice==1
                rQ=RA_Box(i);
                PE_Box(i)=rQ-qa;
                qa=QL(qa,rQ);
            else
                rQ=RB_Box(i);
                PE_Box(i)=rQ-qb;
                qb=QL(qb,rQ);
            end
            if i>=2
                if oldrQ==rQ
                    conReward(i)=conReward(i-1)+1;
                else
                    conReward(i)=0;
                end
            end
            rBox(i)=rQ;
            if conChoice(i)>=TH && ~(conReward(i)>0 && conReward(i)<=TH)
                if conAppear(i-1)==0
                    appear=binornd(1,1);
                elseif conAppear(i-1)==1
                    appear=binornd(1,0.5);
                else
                    appear=binornd(1,0.25);
                end
            else
                appear=0;
            end
            Appear(i)=appear;
            if i>=2
                if appear==1
                    conAppear(i)=conAppear(i-1)+1;
                else
                    conAppear(i)=0;
                end
            end
            oldappear=appear;
            oldrQ=rQ;
            qa_Box(i)=qa;
            qb_Box(i)=qb;
        end
        QA=[QA;qa_Box];
        QB=[QB;qb_Box];
        PEBOX=[PEBOX;PE_Box];
        CC=[CC;Choice];
    end
end
% PEBOX=abs(PEBOX);
Choice=floor(mean(CC).*2);
Aqa_Box=mean(QA,1);
Aqb_Box=mean(QB,1);
APE_Box=mean(PEBOX,1);
qaSD=std(QA,1);
qbSD=std(QB,1);
PESD=std(PEBOX,1);

subplot(3,1,2)
hold on
dotColor=repmat([0 0 0.8],Num,1).*Choice_Box'+repmat([0 0.8 0],Num,1).*(1-Choice_Box');
scatter(1:Num,ones(1,Num).*1.1,dotSize,dotColor,'filled');ylim([0 1.1]);yticks([0 1]);

plot(Aqa_Box,'.-b','MarkerSize',15,'LineWidth',1)
plot(Aqb_Box,'.-g','MarkerSize',15,'LineWidth',1)
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('Predict Value');xlabel('trial');xlim([0 Num]);
%% PE
subplot(3,1,3)
hold on
dotColor=repmat([0 0 1],Num,1).*Choice_Box'+repmat([0 1 0],Num,1).*(1-Choice_Box');
for i=1:Num
    bar(i,APE_Box(i),'FaceColor',dotColor(i,:),'EdgeColor',[1 1 1]);
end
%%
TH=1;
small=zeros(1,Num);
big=zeros(1,Num);
small(conChoice>=TH & conReward>=TH)=1;
big(conChoice>=TH & conReward==0)=1;
sum(big);sum(small);
% figure
% plot(conC)
% hold on
% plot(conR)
upp=1.1;down=-1.1;
realP=find(Appear==1 & rBox==1);realY=ones(size(realP)).*upp;
scatter(realP,realY,40,'^k');
realN=find(Appear==1 & rBox==0);realY=ones(size(realN)).*down;
scatter(realN,realY,40,'vk');

s=1.*(small==1);b=1.*(big==1);
po=1.*(rBox==1);ne=1.*(rBox==0);
sP=find(s.*po==1);bP=find(b.*po==1);
sN=find(s.*ne==1);bN=find(b.*ne==1);
AsP=APE_Box(sP);AbP=APE_Box(bP);
AsN=APE_Box(sN);AbN=APE_Box(bN);

APredictError=[AsP,AbP,AsN,AbN];

sPreal=find(s.*po==1 & Appear==1);bPreal=find(b.*po==1 & Appear==1);
sNreal=find(s.*ne==1 & Appear==1);bNreal=find(b.*ne==1 & Appear==1);

bPY=ones(size(bP)).*upp;
scatter(bP,bPY,30,'^m','filled')
sPY=ones(size(sP)).*upp;
scatter(sP,sPY,30,'^c','filled')
bNY=ones(size(bN)).*down;
scatter(bN,bNY,30,'vm','filled')
sNY=ones(size(sN)).*down;
scatter(sN,sNY,30,'vc','filled')

ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('Prediction Error');xlabel('trial');xlim([0 Num]);yticks([-1 0 1]);ylim([down upp])
set(gcf,'unit','normalized','Position',[0.1,0.1,0.9,0.9])

saveas(gca,'RandomPoint.jpg')
%%

Mean=[mean(AsP),mean(AbP);mean(AsN),mean(AbN);];
SEM=[std(AsP)/sqrt(length(AsP)),std(AbP)/sqrt(length(AbP));std(AsN)/sqrt(length(AsN)),std(AbN)/sqrt(length(AbN));];
SEM=[std(AsP),std(AbP);std(AsN),std(AbN);];

Y_Name='PE';
figure

h=bar(Mean);
h(1).FaceColor=[0 1 1];
h(1).LineWidth=1.5;
h(2).FaceColor=[1 0 1];
h(2).LineWidth=1.5;
%匿名函数f用于将误差线绘制到条形图上
f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';
hold on
errorbar(f(get(h,{'xoffset','xdata'})),Mean,SEM,'.','linewidth',1.5,'Color',[0 0 0])
set(gca,'XTickLabel',{'small','big'})

% 图片后期处理
ylabel(Y_Name)
xlabel('stimuli type')
ax=gca;ax.FontSize=12;ax.LineWidth=1.5;ax.FontName='TimesNewRoman';
ax.Box='off';ax.XColor='k';ax.YColor='k';ax.TickDir = 'out';
set(gcf,'unit','normalized','position',[0,0,0.3,0.5])

figure
hold on
plot(1:length(bNreal)+length(sNreal)+length(sPreal)+length(bPreal),zeros(length(bNreal)+length(sNreal)+length(sPreal)+length(bPreal),1),'--k','Linewidth',1)
scatter(1:length(bNreal),sort(APE_Box(bNreal)),70,'vm','filled','MarkerEdgeColor','k')
scatter(length(bNreal)+1:length(bNreal)+length(sNreal),sort(APE_Box(sNreal)),70,'vc','filled','MarkerEdgeColor','k')
scatter(length(bNreal)+length(sNreal)+1:length(bNreal)+length(sNreal)+length(sPreal),sort(APE_Box(sPreal)),70,'^c','filled','MarkerEdgeColor','k')
scatter(length(bNreal)+length(sNreal)+length(sPreal)+1:length(bNreal)+length(sNreal)+length(sPreal)+length(bPreal),sort(APE_Box(bPreal)),70,'^m','filled','MarkerEdgeColor','k')
xlim([0 length(bNreal)+length(sNreal)+length(sPreal)+length(bPreal)])
ax=gca;ax.FontSize=12;ax.LineWidth=1.5;ax.FontName='TimesNewRoman';ylabel('Prediction Error (PE)')
ax.Box='off';ax.XColor='k';ax.YColor='k';ax.TickDir = 'out';xticks([])
set(gcf,'unit','normalized','position',[0,0,0.5,0.5])
%%
[length(bPreal),length(sPreal),length(bNreal),length(sNreal)]