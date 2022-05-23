% adiciona os CI e os r (ICC) 

CI1 = [0.387,0.908];
CI2 = [0.369,0.898];
r1 = 0.746;
r2 = 0.726;

[LCI,UCI] = CorrDiff_RM(r1,r2,CI1,CI2);

sprintf('[%.2f,%.2f]',LCI,UCI)