clear;clc; close all
high=75;low=25;scale=3.5;
A=[];B=[];cor=30;
R1=cor+(randi(2)-1)*10+1;
R2=R1+cor+(randi(2)-1)*10;
R3=R2+cor+(randi(2)-1)*10;
R4=R3+cor+(randi(2)-1)*10;
R5=R4+cor+(randi(2)-1)*10;
R6=R5+cor+(randi(2)-1)*10;
a=high;Num=200;b=low;
bBox=zeros(1,Num);
for i=1:Num
    if i==R1
       a=low;b=high; 
    end
    if i==R2
        a=high;b=low; 
    end
    if i==R3
       a=low;b=high; 
    end
    if i==R4 
       a=high;b=low; 
    end
    if i==R5 
       a=low;b=high; 
    end
    if i==R6 
       a=high;b=low; 
    end

    a=a+randn*scale;b=b+randn*scale;
    if a>=100
        a=200-a;
    end
    if b<=0
        b=-b;
    end
    aBox(i)=a;
    bBox(i)=b;
end
A=[A;aBox];B=[B;bBox];
hold on
plot(A,'-g','LineWidth',1)
plot(B,'-b','LineWidth',1)
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('mean payoff');xlabel('trial');ylim([0 100]);xticks([1 R1 R2 R3 R4 R5 R6]-1);xlim([0 Num]);
set(gcf,'unit','normalized','Position',[0.1,0.1,0.6,0.3])

