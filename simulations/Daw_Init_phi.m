function minuslli = Daw_Init_phi(params, RA_Box,RB_Box,Num,N,C)
Sigma_d=params(1);beta=params(2);lambda=params(3);theta=params(4);
phi=params(5);
sigma_a=4;
sigma_b=4;
mu_a=50;
mu_b=50;
Sigma_o=4;

Cal_mu_pre=@(Mu_post_old)lambda.*Mu_post_old+(1-lambda).*theta;
Cal_sigma_pre=@(Sigma_post)lambda.^2.*Sigma_post.^2+Sigma_d.^2;
Cal_learning_rate=@(Sigma_pre)Sigma_pre.^2/(Sigma_pre.^2+Sigma_o.^2);
Cal_mu_post=@(Mu_pre,r,k)Mu_pre+k.*(r-Mu_pre);
Cal_sigma_post=@(Sigma_pre,k)(1-k).*Sigma_pre;
P_choosei_2=@(Qi,Qj,Sig_i,Sig_j)exp((Qi+phi.*Sig_i)./beta)/(exp((Qi+phi.*Sig_j)./beta)+exp((Qj+phi.*Sig_j)./beta));%SoftMax模拟被试选择

PCA=zeros(Num,1);
for i=1:Num %模拟强化学习
    Pca=P_choosei_2(mu_a,mu_b,sigma_a,sigma_b);
    Choice=binornd(1,Pca);
    PCA(i)=Pca;
    if Choice==1
        rQ=RA_Box(i);
        k=Cal_learning_rate(sigma_a);
        mu_a_post=Cal_mu_post(mu_a,rQ,k);
        sigma_a_post=Cal_sigma_post(sigma_a,k);
        mu_a=Cal_mu_pre(mu_a_post);
        sigma_a=Cal_sigma_pre(sigma_a_post);
        
    else
        rQ=RB_Box(i);
        k=Cal_learning_rate(sigma_b);
        mu_b_post=Cal_mu_post(mu_b,rQ,k);
        sigma_b_post=Cal_sigma_post(sigma_b,k);
        mu_b=Cal_mu_pre(mu_b_post);
        sigma_b=Cal_sigma_pre(sigma_b_post);
    end
    
end

PCA(PCA<1e-16) = 1e-16;
PCA(PCA>1-1e-16) = 1-1e-16;
minuslli = -sum(C.*log(PCA)+(N-C).*log(1-PCA));
end

