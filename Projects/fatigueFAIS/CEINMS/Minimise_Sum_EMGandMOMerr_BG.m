% Original code from Kirsten Verkamp and Evy Meinders
% calculate the best iteration to minimise the sum of EMG and moment
% tracking errors

function gamma_opt = Minimise_Sum_EMGandMOMerr_BG (gammas,M_EMG,M_mom)

RMSE_act_norm = M_EMG./max(M_EMG);
RMSE_mom_norm = M_mom./max(M_mom);
% sum RMSE
RMSE_sum = RMSE_mom_norm + RMSE_act_norm;
[ha, ~,FirstCol, LastRow] = tight_subplotBG(1,2,0.15,0.15,0.15,[469 420 1069 420]);

% plot act and mom RMSE vs gamma
axes(ha(1));hold on
plot(gammas,RMSE_mom_norm,'.r','markers',10 )
plot(gammas,RMSE_act_norm,'.b','markers',10)
xlabel('gamma');xticklabels(xticks)
ylabel('normalized RMSE');yticklabels(yticks)
lg = legend('nor.RMSE moments','nor.RMSE activations');
lg.Position = [0.4 0.76 0.15 0.08];

% plot sum RMSE vs gamma
axes(ha(2)); hold on
plot(gammas,RMSE_sum,'ok')
p = polyfit(gammas,RMSE_sum,3);
y = polyval(p,gammas);
plot(gammas,y,'g')
xlabel('gamma');xticklabels(xticks);
% legend('normalized RMSE moments','normalized RMSE activations','difference between RMSEs of both variables','fitted polynome')
k = polyder(p); % derivative of p. 

% Newton's method to find intersection
x = 5;
Tol = 0.0000001;
count = 0;
dx=1;   %this is a fake value so that the while loop will execute
% f=polyval(k,x);    % because f(-2)=-13
f=polyval(p,x);    % because f(-2)=-13

fprintf('step      x           dx           f(x)\n')
fprintf('----  -----------  ---------    ----------\n')
fprintf('%3i %12.8f %12.8f %12.8f\n',count,x,dx,f)
% xVec=x;fVec=f;
while (dx > Tol || abs(f)>Tol || count > 500) %note that dx and f need to be defined for this statement to proceed
    count = count + 1;
    fprime = polyval(k,x);   
    xnew = x - (f/fprime);   % compute the new value of x
    dx=abs(x-xnew);          % compute how much x has changed since last step
    x = xnew;
    f =  polyval(p,x);       % compute the new value of f(x)

    fprintf('%3i %12.8f %12.8f %12.8f\n',count,x,dx,f)
end
if (x < 0 || count > 1000)
    x  = 1;
end

gamma_opt = abs(x);
plot(gamma_opt,0,'xk','linewidth',15)
lg = legend('sum.RMSEs mom&act','fitted polynome',['opt.gamma = ' num2str(x)]);
lg.Position = [0.85 0.76 0.15 0.08];
plot(gammas(2):gammas(end),zeros(length(gammas(2):gammas(end)),1),':k')
yticks([0:max(ylim)/5:max(ylim)]);yticklabels(yticks);
mmfn_inspect
