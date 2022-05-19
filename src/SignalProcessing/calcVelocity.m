% calculates veloctiy for each columns of data

function velocity = calcVelocity (data,fs)
firstFrame = data (1,:);
[Nrow,Ncol]=size (data);
if Ncol>Nrow
    data=data';
end
dx = diff([firstFrame; data]);

timeTrial = 0/fs:1/fs:length(data)/fs;
dt = diff(timeTrial)';
velocity = dx./dt;
if length(data) == length(velocity)
    velocity (1,:)=velocity (2,:); %so velocity does not stard from 0
else
    velocity (1,:) =[];
end