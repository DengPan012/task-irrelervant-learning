%% �ϻ�������
clear;clc; close all
Num=50;%������
sigma=4;%payoff��������ı�׼��
start_a=60;start_b=40;%��ʼpayment
lambda=0.9836;%decay����
theta=50;%decay������
noise=15;%���߹��̵����������׼��
up=80;down=20;%payment�ı߽�
A=zeros(Num,1);B=zeros(Num,1);Aout=zeros(Num,1);Bout=zeros(Num,1);%�洢���ɵ�����
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

%% ģ�ⱻ��
time=0;
for alpha=0.5%�̶�ѧϰ��Ϊ0.5��
for beta=0.5%SoftMax����
    time=time+1;
QL=@(q,r)q+alpha.*(r-q);%����ǿ��ѧϰ��learning rate����
Pi=@(Qi,Qj)exp(Qi./beta)/(exp(Qi./beta)+exp(Qj./beta));%SoftMaxģ�ⱻ��ѡ��
RA_Box=Aout;RB_Box=Bout;
qa_Box=zeros(size(Aout));qb_Box=zeros(size(Bout));PE_Box=zeros(size(Aout));
Choice_Box=zeros(size(Aout));qa=50;qb=50;
QA=[];QB=[];PEBOX=[];
for i=1:Num %ģ��ǿ��ѧϰ
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
%% ����ѡ����ϱ�������
tot=1;
options = optimset('MaxFunEvals',100000, 'MaxIter', 10000);
% ģ��1
aBox1=zeros(1,tot);bBox1=zeros(1,tot);LLBox1=zeros(1,tot);
N=ones(Num,1);
fprintf('%1.0f��',time)
for k=1
    
    LB = [0 0];%�����½�
    UB = [1 Inf];%�����Ͻ�
    x0 = [rand rand];
    [paramsEst1, minuslli1, ~] = ...
        fminsearchbnd(@(params)RL_Init(params,Aout,Bout,Num,N,Choice_Box), x0, LB, UB,options);%������fminsearchbnd������������Ȼ��ֵ
    aBox1(k) = paramsEst1(1);bBox1(k) = paramsEst1(2);LLBox1(k)= minuslli1;
end

learning_rate=aBox1(:,1)
tempature=bBox1(:,1)

QL=@(q,r)q+learning_rate.*(r-q);%����ǿ��ѧϰ��learning rate����
Pi=@(Qi,Qj)exp(Qi./tempature)/(exp(Qi./tempature)+exp(Qj./tempature));%SoftMaxģ�ⱻ��ѡ��
RA_Box=Aout;RB_Box=Bout;
qa_Box2=zeros(size(Aout));qb_Box2=zeros(size(Bout));PE_Box2=zeros(size(Aout));
Choice_Box=zeros(size(Aout));qa=50;qb=50;
for i=1:Num %ģ��ǿ��ѧϰ
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

%% ������PE��ɢ��ͼ
subplot(1,1,time)
scatter(PE_Box,PE_Box2,10,[0 0 0])
xticks([]);yticks([]);
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
end
end