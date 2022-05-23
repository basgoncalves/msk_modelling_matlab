%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% function to calculate the polinomial for "FiringFrequencyPlot_Breathing"

function P = CalcPoly_Breathing(Time, Volume, TimeSpikes,PolDegree,fs)


deltaTime = diff(TimeSpikes);
FiringFrquency = 1./deltaTime;
FrquencyTimes = TimeSpikes(2:end); % remove the first frame from time vector since there is no frequncy for that

% fit polynomial
p = polyfit(FrquencyTimes,FiringFrquency,PolDegree);                 % polynomial fucntion (https://au.mathworks.com/help/matlab/ref/polyfit.html#bue6sxq-1-y)
P5 = polyfitn(FrquencyTimes,FiringFrquency,PolDegree);
R2 = P5.R2;

% assign each polynomial data
PolynomialTimes = [FrquencyTimes(1):1/fs:TimeSpikes(end)]';
PolynomialData =  polyval(p,PolynomialTimes);

idx_after500ms = PolynomialTimes>PolynomialTimes(1)+0.5;
PolynomialTimes_after500ms = PolynomialTimes(idx_after500ms);
PolynomialData_after500ms = PolynomialData(idx_after500ms);
% figure
% hold on
% plot(PolynomialTimes,PolynomialData)
% plot(PolynomialTimes_after500ms,PolynomialData_after500ms)

P = struct;
P.FiringFrquency = FiringFrquency;
P.FrquencyTimes = FrquencyTimes;
P.PolynomialFunction = p;
P.Pol = PolynomialData;
P.PolTimes = PolynomialTimes;
P.Pol_after500ms = PolynomialData;
P.PolTimes_after500ms = PolynomialTimes;
P.R2 = R2;


%% plot data after 500ms
figure
hold on
plot(Time,Volume,'LineWidth', 1.5,'Color', [0.9100 0.4100 0.1700])
ylabel('Volume (L)')
yyaxis right
plot(FrquencyTimes,FiringFrquency,'.','MarkerSize',12,'Color', [0.25 0.25 0.25])
plot(PolynomialTimes_after500ms,PolynomialData_after500ms,'-','LineWidth', 1.5,'Color', [0 0 0])
legend({'Volume' 'Firings' sprintf('Degree %.f(r^2=%.2f)',PolDegree,R2)})
mmfn_RM ('time (s)','Frequency (Hz)')

%% plot data full
figure
hold on
plot(Time,Volume,'LineWidth', 1.5,'Color', [0.9100 0.4100 0.1700])
ylabel('Volume (L)')
yyaxis right
plot(FrquencyTimes,FiringFrquency,'.','MarkerSize',12,'Color', [0.25 0.25 0.25])
plot(PolynomialTimes,PolynomialData,'-','LineWidth', 1.5,'Color', [0 0 0])
legend({'Volume' 'Firings' sprintf('Degree %.f(r^2=%.2f)',PolDegree,R2)})
mmfn_RM ('time (s)','Frequency (Hz)')
