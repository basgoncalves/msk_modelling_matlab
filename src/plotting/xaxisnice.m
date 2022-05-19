function xaxisnice(nticks)


xticks([min(xlim):range(xlim)/nticks:max(xlim)])
if range(xlim)<1 && range(xlim)>0.1
    n = 1;
elseif range(xlim)>4
    n = 0;
else
     n = 1;
end
xticklabels(round(xticks,n))