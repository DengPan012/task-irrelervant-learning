function minuslli = RL(params, RA_Box,RB_Box,Num,N,C)
alpha=params(1);beta=params(2);qa=params(3);qb=params(4);
QL=@(q,r)q+alpha.*(r-q);%经典强化学习，learning rate不变
Pi=@(Qi,Qj)exp(Qi./beta)/(exp(Qi./beta)+exp(Qj./beta));%SoftMax模拟被试选择
Choice_Box=zeros(Num,1);
PCA=zeros(Num,1);
for i=1:Num %模拟强化学习
    Pca=Pi(qa,qb);
    Choice=binornd(1,Pca);Choice_Box(i)=Choice;
    
    if Choice==1
        rQ=RA_Box(i);
        qa=QL(qa,rQ);
    else
        rQ=RB_Box(i);
        qb=QL(qb,rQ);
    end
    PCA(i)=Choice;
end
PCA(PCA<1e-16) = 1e-16;
PCA(PCA>1-1e-16) = 1-1e-16;
minuslli = -sum(C.*log(PCA)+(N-C).*log(1-PCA));

end

