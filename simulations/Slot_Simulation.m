%% 老虎机参数
clear;clc; close all
Num=50;%总轮数
sigma=4;%payoff随机噪音的标准差
start_a=60;start_b=40;%起始payment
lambda=0.9836;%decay参数
theta=50;%decay的中心
noise=15;%游走过程的随机噪音标准差
up=80;down=20;%payment的边界
A=zeros(Num,1);B=zeros(Num,1);Aout=zeros(Num,1);Bout=zeros(Num,1);%存储生成的数据
B(1)=start_b;A(1)=start_a;Aout(1)=A(1);Bout(1)=B(1);
for t=2:length(A)
    a=lambda*A(t-1)+(1-lambda)*theta+normrnd(0,noise);
    b=lambda*B(t-1)+(1-lambda)*theta+normrnd(0,noise);
    while ~(a>down && a<up)
        if a>=up
            a=2*up-a;
        end
        if a<=down
            a=2*down-a;
        end
    end
    while ~(b>down && b<up)
        if b>=up
            b=2*up-b;
        end
        if b<=down
            b=2*down-b;
        end
    end
    A(t)=a;B(t)=b;%mean payoff
    Aout(t)=round(normrnd(a,sigma));Bout(t)=round(normrnd(b,sigma));%actual payoff
end

%% 模拟被试
time=0;
for alpha=0.5%固定学习率为0.5；
for beta=0.5%SoftMax参数
    time=time+1;
QL=@(q,r)q+alpha.*(r-q);%经典强化学习，learning rate不变
Pi=@(Qi,Qj)exp(Qi./beta)/(exp(Qi./beta)+exp(Qj./beta));%SoftMax模拟被试选择
RA_Box=Aout;RB_Box=Bout;
qa_Box=zeros(size(Aout));qb_Box=zeros(size(Bout));PE_Box=zeros(size(Aout));
Choice_Box=zeros(size(Aout));qa=50;qb=50;
QA=[];QB=[];PEBOX=[];
for i=1:Num %模拟强化学习
    Pca=Pi(qa,qb);
    Choice=binornd(1,Pca);Choice_Box(i)=Choice;

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
%% 根据选择拟合被试数据
tot=1;
options = optimset('MaxFunEvals',100000, 'MaxIter', 10000);
% 模型1
aBox1=zeros(1,tot);bBox1=zeros(1,tot);LLBox1=zeros(1,tot);
N=ones(Num,1);
fprintf('%1.0f…',time)
for k=1
    
    LB = [0 0];%参数下界
    UB = [1 Inf];%参数上界
    x0 = [rand rand];
    [paramsEst1, minuslli1, ~] = ...
        fminsearchbnd(@(params)RL_Init(params,Aout,Bout,Num,N,Choice_Box), x0, LB, UB,options);%并利用fminsearchbnd函数获得最大似然的值
    aBox1(k) = paramsEst1(1);bBox1(k) = paramsEst1(2);LLBox1(k)= minuslli1;
end

learning_rate=aBox1(:,1)
tempature=bBox1(:,1)

QL=@(q,r)q+learning_rate.*(r-q);%经典强化学习，learning rate不变
Pi=@(Qi,Qj)exp(Qi./tempature)/(exp(Qi./tempature)+exp(Qj./tempature));%SoftMax模拟被试选择
RA_Box=Aout;RB_Box=Bout;
qa_Box2=zeros(size(Aout));qb_Box2=zeros(size(Bout));PE_Box2=zeros(size(Aout));
Choice_Box=zeros(size(Aout));qa=50;qb=50;
for i=1:Num %模拟强化学习
    Pca=Pi(qa,qb);
    Choice=binornd(1,Pca);Choice_Box(i)=Choice;
    if Choice==1
        rQ=RA_Box(i);
        PE_Box2(i)=rQ-qa;
        qa=QL(qa,rQ);
    else
        rQ=RB_Box(i);
        PE_Box2(i)=rQ-qb;
        qb=QL(qb,rQ);
    end
    qa_Box2(i)=qa;
    qb_Box2(i)=qb;
end

%% 画两次PE的散点图
subplot(1,1,time)
scatter(PE_Box,PE_Box2,10,[0 0 0])
xticks([]);yticks([]);
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
end
end