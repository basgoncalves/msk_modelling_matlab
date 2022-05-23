function mtot = ModifyVerticalImpulse(Fgry,Fgly,g)
FgrSum = sum(Fgry)+sum(Fgly);
FgMean = FgrSum/length(Fgry);
mtot = FgMean/g;
