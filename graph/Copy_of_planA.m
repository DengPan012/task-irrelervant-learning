clear;clc; close all
high=80;low=20;scale=5;
A=[];B=[];cor=20;
R1=cor+(randi(4)-1)*5+1;R21=cor+(randi(4)-1)*5+1;
R2=R1+cor+(randi(4)-1)*5;R22=R21+cor+(randi(4)-1)*5+1;
R3=R2+cor+(randi(4)-1)*5;R23=R22+cor+(randi(4)-1)*5+1;
R4=R3+cor+(randi(4)-1)*5;R24=R23+cor+(randi(4)-1)*5+1;
R5=R4+cor+(randi(4)-1)*5;R25=R24+cor+(randi(4)-1)*5+1;
R6=R5+cor+(randi(4)-1)*5;R26=R25+cor+(randi(4)-1)*5+1;
R7=R6+cor+(randi(4)-1)*5;R27=R26+cor+(randi(4)-1)*5+1;
R8=R7+cor+(randi(4)-1)*5;R28=R27+cor+(randi(4)-1)*5+1;
R9=R8+cor+(randi(4)-1)*5;R29=R28+cor+(randi(4)-1)*5+1;
R10=R9+cor+(randi(4)-1)*5;R210=R29+cor+(randi(4)-1)*5+1;
a=high;Num=60;b=low;
bBox=zeros(1,Num);
for i=1:Num
    if i==R1
        a=low;
    end
    if i==R2
        a=high;
    end
    if i==R3
        a=low;
    end
    if i==R4
        a=high;
    end
    if i==R5
        a=low;
    end
    if i==R6
        a=high;
    end
    if i==R7
        a=low;
    end
    if i==R8
        a=high;
    end
    if i==R9
        a=low;
    end
    if i==R10
        a=high;
    end

    if i==R21
        b=high;
    end
    if i==R22
        b=low;
    end
    if i==R23
        b=high;
    end
    if i==R24
        b=low;
    end
    if i==R25
        b=high;
    end
    if i==R26
        b=low;
    end
    if i==R27
        b=high;
    end
    if i==R28
        b=low;
    end
    if i==R29
        b=high;
    end
    if i==R210
        b=low;
    end
    a=a+randn*scale;b=b+randn*scale;
    if a>=100
        a=200-a;
    end
    if b>=100
        b=200-b;
    end
    if a<=0
        a=-a;
    end
    if b<=0
        b=-b;
    end
    aBox(i)=a;
    bBox(i)=b;
end
dotSize=25;
A=aBox./100;B=bBox./100;
Aout=binornd(ones(size(A)),A);
Bout=binornd(ones(size(B)),B);
figure
subplot(3,1,1)
hold on
scatter(1:Num,Aout.*0.8+0.11+0.08.*rand(size(Aout)),dotSize,'b','filled')
scatter(1:Num,Bout.*0.8+0.09-0.08.*rand(size(Bout)),dotSize,'g','filled')
plot(A,'-','Color',[0 0 180]./255,'LineWidth',2)
plot(B,'-','Color',[0 180 0]./255,'LineWidth',2)

ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('Probability');xlabel('trial');xlim([0 Num]);

%% ģ�ⱻ��
VIa=0.5;VIb=0.5;
for b=0.5
    for a=0.5
        QL=@(q,r)q+a.*(r-q);
        Pi=@(Qi,Qj)exp(Qi./b)/(exp(Qi./b)+exp(Qj./b));
        qa=VIa;qb=VIb;
        
        RA_Box=Aout;
        RB_Box=Bout;
        qa_Box=zeros(size(Aout));qb_Box=zeros(size(Bout));
        PE_Box=zeros(size(Aout));
        Choice_Box=zeros(size(Aout));
        
        for i=1:Num
            Pca=Pi(qa,qb);
            Pcb_Box(i)=1-Pca;
            %Choice=(Pca>=0.5)*1;
            Choice=binornd(1,Pca);
            Choice_Box(i)=Choice;
            if Choice==1
                rQ=RA_Box(i);
                PE_Box(i)=rQ-qa;
                qa=QL(qa,rQ);
            else
                rQ=RB_Box(i);
                PE_Box(i)=rQ-qb;
                qb=QL(qb,rQ);
            end
            qa_Box(i)=qa;
            qb_Box(i)=qb;
        end
    end
end
subplot(3,1,2)
hold on
dotColor=repmat([0 0 0.8],Num,1).*Choice_Box'+repmat([0 0.8 0],Num,1).*(1-Choice_Box');
scatter(1:Num,ones(1,Num),dotSize,dotColor,'filled')

plot(qa_Box,'.-b','MarkerSize',15,'LineWidth',1)
plot(qb_Box,'.-g','MarkerSize',15,'LineWidth',1)
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('Predict Value');xlabel('trial');xlim([0 Num]);
%% PE
subplot(3,1,3)
hold on
plot(PE_Box,'--k')
dotColor=repmat([0 0 1],Num,1).*Choice_Box'+repmat([0 1 0],Num,1).*(1-Choice_Box');
scatter(1:Num,PE_Box,dotSize,dotColor,'filled')
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('Prediction Error');xlabel('trial');xlim([0 Num]);

set(gcf,'unit','normalized','Position',[0.1,0.1,0.9,0.9])

saveas(gca,'D.jpg')