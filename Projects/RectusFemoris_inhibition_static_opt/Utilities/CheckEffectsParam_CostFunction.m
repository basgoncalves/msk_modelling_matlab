

count = 0;
iter = [10.^[1:5]];

for MFEV = iter
    count = count+1;
options_sqp = optimoptions('fmincon','Display','notify-detailed', ...
    'TolCon',1e-4,'TolFun',1e-12,'TolX',1e-19,'MaxFunEvals',MFEV,...
    'MaxIter',50000,'Algorithm','sqp');


[coeffsFinal,fval,exitflag,output] = fmincon(@(coeffs0) CostFunction(coeffs0,params), ...
    coeffs_initial,A,b,Aeq,beq,lb,ub,nonlcon,options_sqp) ;
    CF(1:length(coeffsFinal),count) = coeffsFinal;
    FV(count,1) = fval;
end

f1 = figure; hold on
plot(CF)
title('coeffsFinal')
legend(split(num2str(iter))')
f1.Position = [152 232 560 420];

f2 = figure; hold on
plot(log(iter),FV,'o')
title('fval')
xlab(iter)
f2.Position = [750 232 560 420];