%% 老虎机参数设置
clear;clc; close all
trialNum=50;%总轮数
Sigma_o=4;%payoff随机噪音的标准差
initPay_A=50;initPay_B=50;%起始payment
lambda=0.9836;%decay参数
theta=50;%decay的中心
Sigma_d=25;%游走过程的随机噪音标准差
up=100;down=0;%payment的边界
A_mu=zeros(trialNum,1);B_mu=zeros(trialNum,1);RA_Box=zeros(trialNum,1);RB_Box=zeros(trialNum,1);%存储生成的数据
B_mu(1)=initPay_B;A_mu(1)=initPay_A;RA_Box(1)=A_mu(1);RB_Box(1)=B_mu(1);

for t=2:length(A_mu)
    a_mu=lambda*A_mu(t-1)+(1-lambda)*theta+normrnd(0,Sigma_d);
    b_mu=lambda*B_mu(t-1)+(1-lambda)*theta+normrnd(0,Sigma_d);
    disp(1)
    A_mu(t)=a_mu;B_mu(t)=b_mu;%mean payoff
    a_pay=round(normrnd(a_mu,Sigma_o));b_pay=round(normrnd(b_mu,Sigma_o));
    %如果老虎机的金额小于0，则取相反数（关于0对称），例如-10变成10
    %如果大于100，则将这个数关于100取对称，例如140变为60,
    %反复上述过程直到取值介于0~100之间
    while ~(a_pay>=down && a_pay<=up)
        if a_pay>=up
            a_pay=2*up-a_pay;
        end
        if a_pay<=down
            a_pay=2*down-a_pay;
        end
    end
    while ~(b_pay>=down && b_pay<=up)
        if b_pay>=up
            b_pay=2*up-b_pay;
        end
        if b_pay<=down
            b_pay=2*down-b_pay;
        end
    end
    RA_Box(t)=a_pay;RB_Box(t)=b_pay;%actual payoff
end
figure
subplot(3,1,1)
hold on
plot(RA_Box,'-','Color',[0 0 180]./255,'LineWidth',2)%A蓝
plot(RB_Box,'-','Color',[0 180 0]./255,'LineWidth',2)%B绿
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('Mean Payoff');xlabel('trial');xlim([0 trialNum]);ylim([down up])
%% 模拟被试
alpha=0.5;%固定学习率为0.5；
beta=0.5;%SoftMax参数
phi=0;

Cal_mu_pre=@(Mu_post_old)lambda.*Mu_post_old+(1-lambda).*theta;
Cal_sigma_pre=@(Sigma_post)lambda.^2.*Sigma_post.^2+Sigma_d.^2;
Cal_learning_rate=@(Sigma_pre)Sigma_pre.^2/(Sigma_pre.^2+Sigma_o.^2);
Cal_mu_post=@(Mu_pre,r,k)Mu_pre+k.*(r-Mu_pre);
Cal_sigma_post=@(Sigma_pre,k)(1-k).*Sigma_pre;

P_choosei_2=@(Qi,Qj,Sig_i,Sig_j)exp((Qi+phi.*Sig_i)./beta)/(exp((Qi+phi.*Sig_j)./beta)+exp((Qj+phi.*Sig_j)./beta));%SoftMax模拟被试选择
MU_A_Box=zeros(size(RA_Box));MU_B_Box=zeros(size(RB_Box));PE_Box=zeros(size(RA_Box));
Choice_Box=zeros(size(RA_Box));
%q代表mu
mu_a=50;mu_b=50;sigma_a=4;sigma_b=4;
MU_A=[];MU_B=[];Pca_Box=[];
for i=1:trialNum %模拟强化学习
    Pca=P_choosei_2(mu_a,mu_b,sigma_a,sigma_b);
    Pca_Box(i)=Pca;
    Choice=binornd(1,Pca);Choice_Box(i)=Choice;

    if Choice==1
        rQ=RA_Box(i);
        PE_Box(i)=rQ-mu_a;
        k=Cal_learning_rate(sigma_a);
        mu_a_post=Cal_mu_post(mu_a,rQ,k);
        sigma_a_post=Cal_sigma_post(sigma_a,k);
        mu_a=Cal_mu_pre(mu_a_post);
        sigma_a=Cal_sigma_pre(sigma_a_post);
        
    else
        rQ=RB_Box(i);
        PE_Box(i)=rQ-mu_b;
        k=Cal_learning_rate(sigma_b);
        mu_b_post=Cal_mu_post(mu_b,rQ,k);
        sigma_b_post=Cal_sigma_post(sigma_b,k);
        mu_b=Cal_mu_pre(mu_b_post);
        sigma_b=Cal_sigma_pre(sigma_b_post);
    end
    MU_A_Box(i)=mu_a;
    MU_B_Box(i)=mu_b;
end
MU_A=[MU_A;MU_A_Box];
MU_B=[MU_B;MU_B_Box];
subplot(3,1,2)
hold on
dotColor=repmat([0 0 0.8],trialNum,1).*Choice_Box+repmat([0 0.8 0],trialNum,1).*(1-Choice_Box);
dotSize=25;
scatter(1:trialNum,ones(1,trialNum).*1.1,dotSize,dotColor,'filled');
plot(MU_A_Box,'.-b','MarkerSize',15,'LineWidth',1)
plot(MU_B_Box,'.-g','MarkerSize',15,'LineWidth',1)
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('Predict Value');xlabel('trial');xlim([0 trialNum]);
%% PE
subplot(3,1,3)
hold on
dotColor=repmat([0 0 1],trialNum,1).*Choice_Box+repmat([0 1 0],trialNum,1).*(1-Choice_Box);
for i=1:trialNum
    bar(i,PE_Box(i),'FaceColor',dotColor(i,:),'EdgeColor',[1 1 1]);
end
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('Prediction Error');xlabel('trial');xlim([0 trialNum]);

%% 根据选择拟合被试数据
tot=5; %重复多次相同的拟合操作，选择其中最大似然值最小一次拟合结果
options = optimset('MaxFunEvals',100000, 'MaxIter', 10000);
Sigma_d_Box=zeros(1,tot);lambda_Box=zeros(1,tot);theta_Box=zeros(1,tot);beta_Box=zeros(1,tot);
phi_Box=zeros(1,tot);
LLBox=zeros(1,tot);
N=ones(trialNum,1);
for k=1:tot
    fprintf('%1.0f…',k)
    LB = [0 0 0 0 0];%参数下界
    UB = [1 Inf 1 Inf Inf];%参数上界
    x0 = [Sigma_d rand lambda theta phi]; %起始点设置
    [paramsEst, minuslli, ~] = ...
        fminsearchbnd(@(params)Daw_Init(params,RA_Box,RB_Box,trialNum,N,Choice_Box), x0, LB, UB,options);%并利用fminsearchbnd函数获得最大似然的值 
    Sigma_d_Box(k)=paramsEst(1);beta_Box(k)=paramsEst(2);lambda_Box(k)=paramsEst(3);theta_Box(k)=paramsEst(4);phi_Box(k)=paramsEst(5);
    LLBox(k)= minuslli;
end
indx=find(LLBox==max(LLBox));indx=indx(1);
Sigma_d_new=Sigma_d_Box(:,indx);beta_new=beta_Box(:,indx);
lambda_new=lambda_Box(:,indx);theta_new=theta_Box(:,indx);
phi_new=phi_Box(:,indx);
%% 利用拟合的参数建立新的被试模型

Cal_mu_pre=@(Mu_post_old)lambda_new.*Mu_post_old+(1-lambda_new).*theta_new;
Cal_sigma_pre=@(Sigma_post)lambda_new.^2.*Sigma_post.^2+Sigma_d_new.^2;
Cal_learning_rate=@(Sigma_pre)Sigma_pre.^2/(Sigma_pre.^2+Sigma_o.^2);
Cal_mu_post=@(Mu_pre,r,k)Mu_pre+k.*(r-Mu_pre);
Cal_sigma_post=@(Sigma_pre,k)(1-k).*Sigma_pre;

P_choosei_new=@(Qi,Qj,Sig_i,Sig_j)exp((Qi+phi_new.*Sig_i)./beta_new)/(exp((Qj+phi_new.*Sig_j)./beta_new)+exp((Qi+phi_new.*Sig_i)./beta_new));%新的SoftMax模拟被试选择
MU_A_Box2=zeros(size(RA_Box));MU_B_Box2=zeros(size(RB_Box));PE_Box2=zeros(size(RA_Box));
Choice_Box=zeros(size(RA_Box));
mu_a=50;mu_b=50;
sigma_a=50;sigma_b=50;
%新的起始点
for i=1:trialNum %模拟强化学习
    Pca=P_choosei_new(mu_a,mu_b,sigma_a,sigma_b);
    Choice=binornd(1,Pca);Choice_Box(i)=Choice;

    if Choice==1
        rQ=RA_Box(i);
        PE_Box2(i)=rQ-mu_a;
        k=Cal_learning_rate(sigma_a);
        mu_a_post=Cal_mu_post(mu_a,rQ,k);
        sigma_a_post=Cal_sigma_post(sigma_a,k);
        mu_a=Cal_mu_pre(mu_a_post);
        sigma_a=Cal_sigma_pre(sigma_a_post);
        
    else
        rQ=RB_Box(i);
        PE_Box2(i)=rQ-mu_b;
        k=Cal_learning_rate(sigma_b);
        mu_b_post=Cal_mu_post(mu_b,rQ,k);
        sigma_b_post=Cal_sigma_post(sigma_b,k);
        mu_b=Cal_mu_pre(mu_b_post);
        sigma_b=Cal_sigma_pre(sigma_b_post);
    end
    MU_A_Box2(i)=mu_a;
    MU_B_Box2(i)=mu_b;
end

figure
subplot(2,1,1)
hold on
dotColor=repmat([0 0 0.8],trialNum,1).*Choice_Box+repmat([0 0.8 0],trialNum,1).*(1-Choice_Box);
dotSize=25;
scatter(1:trialNum,ones(1,trialNum).*1.1,dotSize,dotColor,'filled');
plot(MU_A_Box2,'.-b','MarkerSize',15,'LineWidth',1)
plot(MU_B_Box2,'.-g','MarkerSize',15,'LineWidth',1)
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('Predict Value');xlabel('trial');xlim([0 trialNum]);
%% PE
subplot(2,1,2)
hold on
dotColor=repmat([0 0 1],trialNum,1).*Choice_Box+repmat([0 1 0],trialNum,1).*(1-Choice_Box);
for i=1:trialNum
    bar(i,PE_Box2(i),'FaceColor',dotColor(i,:),'EdgeColor',[1 1 1]);
end
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('Prediction Error');xlabel('trial');xlim([0 trialNum]);

%% 画两次PE的散点图
figure
scatter(PE_Box,PE_Box2,40,[0 0 0])
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
ylabel('Calculated PE');xlabel('Original PE');

r=corr(PE_Box,PE_Box2)