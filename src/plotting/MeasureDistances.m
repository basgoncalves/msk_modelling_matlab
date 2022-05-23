%   Basilio Goncalves 2019
% analysise data from Image J

filename = uigetfile('*.*','Select acquisition.xml file to load', pwd);
Trial = importdata (filename);

ColIdx = find(contains(Trial.colheaders,'Length'));
LengthData = Trial.data (:,ColIdx);
%plot questions 1- 11
figure 
mmfn
for ii = 1:11
   
   subplot (11,1,ii)

  x = 1:100;
  y (1:100, 1) = 50;
  plot (x,y)
  title(sprintf('Q %d',ii))
  axis off
  hold on
  plot ([LengthData(ii) LengthData(ii)], [0 100])
  txt = ['\leftarrow ' sprintf('%.f',LengthData(ii))];
  text (LengthData(ii) , 150,txt)
end


%plot questions 12-22 
figure 
mmfn
for ii = 12:22
   
   subplot (11,1,ii-11)

  x = 1:100;
  y (1:100, 1) = 50;
  plot (x,y)
  title(sprintf('Q %d',ii))
  axis off
  hold on
  plot ([LengthData(ii) LengthData(ii)], [0 100])
  txt = ['\leftarrow ' sprintf('%.f',LengthData(ii))];
  text (LengthData(ii) , 150,txt)
end



%plot questions 23-33
figure 
mmfn
for ii = 23:33
   subplot (11,1,ii-22)

  x = 1:100;
  y (1:100, 1) = 50;
  plot (x,y)
  title(sprintf('Q %d',ii+22))
  axis off
  hold on
  plot ([LengthData(ii) LengthData(ii)], [0 100])
  txt = ['\leftarrow ' sprintf('%.f',LengthData(ii))];
  text (LengthData(ii) , 150,txt)
end
