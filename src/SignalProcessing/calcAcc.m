% calculates veloctiy for each columns of data

function acc = calcAcc (data,fs)
firstFrame = data (1,:);
[Nrow,Ncol]=size (data);
if Ncol>Nrow
    data=data';
end
dx = diff([firstFrame; data]);

timeTrial = 0/fs:1/fs:length(data)/fs;
dt = diff(timeTrial)';
V = dx./dt;
firstFrame = V (1,:);
dv = diff([firstFrame; V]);
acc = dv./dt;

acc (1,:)=acc (2,:); %so velocity does not stard from 0