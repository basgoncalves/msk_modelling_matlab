function [idxhc,idxto,F,Fcomb] = StepDetect(Fin,threshhigh,threshlow,MinSwing)
% idxhc: index van de eerste krachtsample bij heelcontact in een stride die
% groter dan nul is
% idxto: index van de eerste krachtsample bij toe off in een stride die nul is

Fcomb = sqrt(Fin(:,1).^2+Fin(:,2).^2);
Fcomb2 = Fcomb;
F = Fin;
% Make all force samples below the high treshold zero:
idxh = find(Fcomb < threshhigh);
Fcomb(idxh) = 0;
F(idxh,1:2) = 0;

% compare force sample to left and right neighbouring sample to find
% heelcontacts and toe offs:
idxto = zeros(1,length(Fcomb));
idxhc = zeros(1,length(Fcomb));
telto = 1;
telhc = 1;
for i = 2:size(Fcomb,1)-1
  if (Fcomb(i) == 0 && Fcomb(i-1) > 0)
    idxto(telto) = i;
    telto = telto+1;
  end
  if (Fcomb(i) == 0 && Fcomb(i+1) > 0)
    idxhc(telhc) = i+1;
    telhc = telhc+1;
  end
end
% Cut idxto to right length:
if (telto == 1)
  idxto = [];
else  
  idxto = idxto(1:telto-1);
end  
% % Cut idxhc to right length:
if (telhc == 1)
  idxhc =[];
else  
  idxhc = idxhc(1:telhc-1);
end  
% % We want to be sure to start with a toe off:
if (idxto(1) > idxhc(1))
  idxhc = idxhc(2:end);
end

% Start in the middle between toe off and heel contact and move step by
% step to the left. If the force rises above the low threshold, then the
% sample at the right of this value is toe off:
for i = 1:size(idxto,2)-1
  idxtry = round((idxto(i)+idxhc(i))/2);
  while Fcomb2(idxtry) < threshlow
    idxtry = idxtry-1;
  end  
  idxto(i) = idxtry+1;
end

% Start in the middle between toe off and heel contact and move step by
% step to the right. If the force rises above the low threshold, then the
% sample at this value is heel contact:
for i = 1:size(idxto,2)-1
  idxtry = round((idxto(i)+idxhc(i))/2);
  while Fcomb2(idxtry) < threshlow
    idxtry = idxtry+1;
  end  
  idxhc(i) = idxtry;
end
%chop off first and last since they are not reliable:
idxto = idxto(2:end-1);
idxhc = idxhc(2:end-1);

% remove equal indices for heel contact and toe off:
i = 1;
while i <= size(idxto,2)-1
  if idxhc(i) - idxto(i) <= MinSwing
    idxto = [idxto(1:i-1) idxto(i+1:end)];
    idxhc = [idxhc(1:i-1) idxhc(i+1:end)];
    i = i-1;
  end
  i = i+1;
end

% Set the values between to and hc to zero and the rest to the measured
% values:
for i = 1:size(idxto,2)-1
  Fcomb(idxto(i):idxhc(i)-1,1) = 0;
  F(idxto(i):idxhc(i)-1,:) = 0;
  Fcomb(idxhc(i):idxto(i+1),1) = Fcomb2(idxhc(i):idxto(i+1),1);
  F(idxhc(i):idxto(i+1),:) = Fin(idxhc(i):idxto(i+1),:);
end


% % inspect whether the border for toe off can be moved to the right,
% % to a lower force (below low threshold):
% for i = 1:size(idxto,2)-1
%   idxtry = idxto(i);
%   while Fcomb2(idxtry) > threshlow
%     Fcomb(idxtry,1) = Fcomb2(idxtry,1);
%     F(idxtry,:) = Fin(idxtry,:);
%     idxtry = idxtry+1;
%   end  
%   idxto(i) = idxtry;
% end
% % Start from toe off and look step by step to the right when the force
% % starts to rise. If it rises above the lowthresh, heel contact starts:
% for i = 1:size(idxto,2)-1
%   idxtry = idxto(i)+1;
%   while Fcomb2(idxtry) <= threshlow
%     Fcomb(idxtry,1) = Fcomb2(idxtry,1);
%     F(idxtry,:) = Fin(idxtry,:);
%     idxtry = idxtry+1;
%   end  
%   idxhc(i) = idxtry;
% end
% % Restore all force samples from hc to to their original values:
% for i = 1:size(idxhc,2)-1
%   Fcomb(idxhc(i):idxto(i+1),1) = Fcomb2(idxhc(i):idxto(i+1),1);
%   F(idxhc(i):idxto(i+1),:) = Fin(idxhc(i):idxto(i+1),:);
% end  
  



% % inspect whether the border for heel contact can be moved to the left,
% % to a lower force (below low threshold):
% for i = 1:size(idxhc,2)-1
%   idxtry = idxhc(i)-1;
%   while Fcomb2(idxtry) > threshlow
%     Fcomb(idxtry,1) = Fcomb2(idxtry,1);
%     F(idxtry,:) = Fin(idxtry,:);
%     idxtry = idxtry-1;
%   end
% % +1 is necessary, because heel contact is defined as the first force
% % sample that is larger than the threshold:  
%   idxhc(i) = idxtry+1;
% end  

% % if the force does not drop below the threshold during the swing phase
% % doubles can form. This is to remove them:
% idxhc = unique(idxhc,'stable');
% idxto = unique(idxto,'stable');