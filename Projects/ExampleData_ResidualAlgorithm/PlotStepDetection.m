figure
tFc = 0:1/fs:(length(Fgrcomb)-1)/fs;
plot(tFc,FgrcombSave,tFc,Fgrcomb)
hold on
plot((idxrto-1)/fs,Fgrcomb(idxrto),'o')
plot((idxrhc-1)/fs,Fgrcomb(idxrhc),'*')
xlabel('Time (s)')
ylabel('Combined ground reaction force right')
title('Step detection')
legend('Raw force','Threshold based force','Toe off','Heel contact')

figure
plot(tFc,FglcombSave,tFc,Fglcomb)
hold on
plot((idxlto-1)/fs,Fglcomb(idxlto),'o')
plot((idxlhc-1)/fs,Fglcomb(idxlhc),'*')
xlabel('Time (s)')
ylabel('Combined ground reaction force left')
title('Step detection')
legend('Raw force','Threshold based force','Toe off','Heel contact')
