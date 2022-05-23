%% GaitCycleDetect
% References
%   https://doi.org/10.1016/j.gaitpost.2006.05.016

OrganiseFAI
cd(DirC3D)
t = DynamicTrials{1};
d = btk_loadc3d(t);
% sacrum marker 
m = ['LSACR ' 'RSACR ' 'USACR'];
m = split(m,' ');
for ii = 1:length(m)
 s(:,ii) = d.marker_data.Markers.(m{ii})(:,3);
end
s = mean(s,2);
% foot marker 
l = (TestedLeg{1}); %leg
m = [l 'MT1 ' l 'MT2 ' l 'MT5'];%l 'HEE '
m = split(m,' ');
f=[]; % foot
for ii = 1:length(m)
    f(:,ii) = d.marker_data.Markers.(m{ii})(:,2);
end
f = mean(f,2);
Vf = smooth(calcVelocity(f,fs));

id = find(abs(Vf)<200);  % 
bi = Vf;
bi(id) = 0;
id = find(abs(Vf)>200);
bi(id) = 1;
plot(bi);
bi = [1 bi' 1]; % ad a 1 at beginning and end in case the foot is on the ground then 
FC = [];
TO = [];

for ii = 2: length(bi)
   if bi(ii) == 0 &&  bi(ii-1) == 1
       FC(end+1) = ii-1; 
       c = c+1;
   elseif bi(ii) == 0 &&  bi(ii+1) == 1
       TO(end+1) = ii-1; 
   end
end


x = [1:length(Vf)];
s = spline(x,Vf)

fs = d.marker_data.Info.frequency;
vz = smooth(calcVelocity(s,fs));
[p,id] = findpeaks(vz,'MinPeakDistance',30);
(id + d.marker_data.First_Frame) / fs 
id = id-5;
id(6);
p(6);
FO = d.Events.Events.Right_Foot_Off*fs
