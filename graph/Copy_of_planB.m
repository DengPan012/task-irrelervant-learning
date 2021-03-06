clear;clc; close all
high=90;low=10;scale=5;mid=50;
A=[];B=[];cor=20;
kk=3;
R1=cor+(randi(kk)-1)*5+1;R21=cor+(randi(kk)-1)*5+1;
R2=R1+cor+(randi(kk)-1)*5;R22=R21+cor+(randi(kk)-1)*5+1;
R3=R2+cor+(randi(kk)-1)*5;R23=R22+cor+(randi(kk)-1)*5+1;
R4=R3+cor+(randi(kk)-1)*5;R24=R23+cor+(randi(kk)-1)*5+1;
R5=R4+cor+(randi(kk)-1)*5;R25=R24+cor+(randi(kk)-1)*5+1;
R6=R5+cor+(randi(kk)-1)*5;R26=R25+cor+(randi(kk)-1)*5+1;
R7=R6+cor+(randi(kk)-1)*5;R27=R26+cor+(randi(kk)-1)*5+1;
R8=R7+cor+(randi(kk)-1)*5;R28=R27+cor+(randi(kk)-1)*5+1;
R9=R8+cor+(randi(kk)-1)*5;R29=R28+cor+(randi(kk)-1)*5+1;
R10=R9+cor+(randi(kk)-1)*5;R210=R29+cor+(randi(kk)-1)*5+1;
a=mid;Num=200;b=mid;
aBox=zeros(1,Num);
bBox=zeros(1,Num);
j=0;
QA=[];QB=[];PEBOX=[];
VIa=0.5;VIb=0.5;
TH=1;
CC=[];
for beta=1
    for alpha=ones(1,1).*0.3
        j=j+1;
        for i=1:Num
            if i==R1
                a=low;b=high;
            end
            if i==R2
                a=mid;b=mid;
            end
            if i==R3
                b=low;a=high;
            end
            if i==R4
                a=low;b=low;
            end
            if i==R5
                a=low;b=high;
            end
            if i==R6
                a=mid;b=mid;
            end
            if i==R7
                b=low;a=low;
            end
            if i==R8
                a=mid;b=mid;
            end
            if i==R9
                a=high;b=high;
            end
            if i==R10
                a=mid;b=mid;
            end
            
            a0=a+randn*scale;b0=b+randn*scale;
            if a0>=100
                a0=200-a0;
            end
            if b0>=100
                b0=200-b0;
            end
            if a0<=0
                a0=-a0;
            end
            if b0<=0
                b0=-b0;
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
        
        
        RA_Box=Aout;
        RB_Box=Bout;
        qa_Box=zeros(size(Aout));qb_Box=zeros(size(Bout));
        PE_Box=zeros(size(Aout));
        Choice_Box=zeros(size(Aout));
        qa=VIa;qb=VIb;
        rBox=zeros(1,Num);
        conC=zeros(1,Num);conR=zeros(1,Num);Appear=zeros(1,Num);conA=zeros(1,Num);
        for i=1:Num
            Pca=Pi(qa,qb);
            %Choice=(Pca>=0.5)*1;
            Choice=binornd(1,Pca);Choice_Box(i)=Choice;
            if i>=2
                if oldChoice==Choice
                    conC(i)=conC(i-1)+1;
                else
                    conC(i)=0;
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
                    conR(i)=conR(i-1)+1;
                else
                    conR(i)=0;
                end
            end
            rBox(i)=rQ;
            if conC(i)>=TH && ~(conR(i)>0 && conR(i)<=TH)
                if conA(i-1)==0
                    appear=binornd(1,1);
                elseif conA(i-1)==1
                    appear=binornd(1,0.6);
                else
                    appear=binornd(1,0.15);
                    
                end
                
            else
                appear=0;
            end
            Appear(i)=appear;
            if i>=2
                if appear==1
                    conA(i)=conA(i-1)+1;
                else
                    conA(i)=0;
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
scatter(1:Num,ones(1,Num),dotSize,dotColor,'filled')

plot(Aqa_Box,'.-b','MarkerSize',15,'LineWidth',1)
plot(Aqb_Box,'.-g','MarkerSize',15,'LineWidth',1)
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('Predict Value');xlabel('trial');xlim([0 Num]);
%% PE
subplot(3,1,3)
hold on
plot(APE_Box,'--k')
dotColor=repmat([0 0 1],Num,1).*Choice_Box'+repmat([0 1 0],Num,1).*(1-Choice_Box');
scatter(1:Num,APE_Box,dotSize,dotColor,'filled')
%%

small=zeros(1,Num);
big=zeros(1,Num);
small(conC>=TH & conR>=TH)=1;
big(conC>=TH & conR==0)=1;
sum(big);sum(small);
% figure
% plot(conC)
% hold on
% plot(conR)
upp=1.1;
real=find(Appear==1);realY=ones(size(real)).*upp;
scatter(real,realY,40,'^k');

s=find(small==1);sY=ones(size(s)).*upp;
scatter(s,sY,30,'^c','filled')

b=find(big==1);bY=ones(size(b)).*upp;
scatter(b,bY,30,'^m','filled')

ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('Prediction Error');xlabel('trial');xlim([0 Num]);yticks([0 1]);ylim([-1 upp])

set(gcf,'unit','normalized','Position',[0.1,0.1,0.9,0.9])

saveas(gca,'B2.jpg')
%%
s=1.*(small==1);b=1.*(big==1);

po=1.*(rBox==1);ne=1.*(rBox==0);
sP=APE_Box(find(s.*po==1));bP=APE_Box(find(b.*po));
sN=APE_Box(find(s.*ne==1));bN=APE_Box(find(b.*ne==1));
Mean=[mean(sP),mean(bP);mean(sN),mean(bN);];
SEM=[std(sP)/sqrt(length(sP)),std(bP)/sqrt(length(bP));std(sN)/sqrt(length(sN)),std(bN)/sqrt(length(bN));];
SEM=[std(sP),std(bP);std(sN),std(bN);];

Y_Name='PE';
figure

h=bar(Mean);
h(1).FaceColor=[1 1 1];

h(1).LineWidth=1.5;
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