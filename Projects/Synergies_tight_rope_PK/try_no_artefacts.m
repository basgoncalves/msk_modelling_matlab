%close all
if exist('ovmat')
    clear ovmat unmat under over
end%if
clear bb cc be
a = [1,1,1,1,1,1.5,4,3,4,3,4,1.5,1,2,1,2,1];
aa =signal;
zerth = rms(aa)*2;
%op=aa(aa>-zerth & aa<zerth);
%for o = length(op)
%  find
%aa      = aa - mean(aa);
%aa     = sqrt(aa.^2);
bb= diff(aa);

th = 0.35; %rms(bb)*2;
under = 0;
over = 0;

over = find(bb>th);
over = over;
be = bb;
nr_over = length(over);
row = 1; col = 1;
for zer = 1:nr_over %resorts in a zeromatrix, so that indexes next to each other are in the same row
    if zer == 1
        ovmat(row,col) = over(zer);
    elseif over(zer) - over(zer-1) == 1
        col = col+1;
        ovmat(row,col) = over(zer);
    else
        col = 1;
        row = row+1;
        ovmat(row,col) = over(zer);
    end%if
end%for
if exist('ovmat')
    nr_rows = rows(ovmat);
    for row = 1:nr_rows %for each punch of zeros which are next to each other
        rowstore = nonzeros(ovmat(row,:)); %indexes of zeros (without zero --> due to matrix length)
        s = rowstore(1); %first idx of row
        e = rowstore(end); %last idx of row
        if s~= 1 && e ~= length(be) %if first idx is unequal to 1 and last index is unequal to number of bb
            predat = be(s-1); %datavalue one prior s-index
            postdat= be(e+1); %datavalue one after e-index
            m = mean([predat, postdat]);
            be(rowstore) = 0;
        end%if
    end%for
end%if

under = find(bb<-th);
under = under;
nr_under = length(under);
row = 1; col = 1;
for zer = 1:nr_under %resorts in a zeromatrix, so that indexes next to each other are in the same row
    if zer == 1
        unmat(row,col) = under(zer);
    elseif under(zer) - under(zer-1) == 1
        col = col+1;
        unmat(row,col) = under(zer);
    else
        col = 1;
        row = row+1;
        unmat(row,col) = under(zer);
    end%if
end%for
if exist('unmat')
    nr_rows = rows(unmat);
    for row = 1:nr_rows %for each punch of zeros which are next to each other
        rowstore = nonzeros(unmat(row,:)); %indexes of zeros (without zero --> due to matrix length)
        s = rowstore(1); %first idx of row
        e = rowstore(end); %last idx of row
        if s~= 1 && e ~= length(be) %if first idx is unequal to 1 and last index is unequal to number of bb
            predat = be(s-1); %datavalue one prior s-index
            postdat= be(e+1); %datavalue one after e-index
            m = mean([predat, postdat]);
            be(rowstore) = 0;
        end%if
    end%for
end%if

for i = 1:length (aa)
    if i == 1
        cc(i) = aa(i);
    elseif aa(i)>-zerth && aa(i)<zerth
        cc(i) = aa(i);
    else
        %if any(under == i-1)
        %  [x,y] = find(unmat==i-1)
        %  if y==nonzeros(unmat(x,end));
        %    cc(i) = aa(i);
        %  else
        %    cc(i) = cc(i-1)+be(i-1);
        %  endif
        %elseif any(over == i-1)
        %  [x,y] = find(ovmat==i-1)
        %  if y==nonzeros(ovmat(x,end));
        %    cc(i) = aa(i);
        %  else
        %    cc(i) = cc(i-1)+be(i-1);
        %  endif
        %endif




        %if bb(i-1)>th || bb(i-1)<-th
        %  cc(i) = cc(i-1);
        %else

        cc(i) = cc(i-1)+be(i-1);
        %endif
    end%if
    %if abs(cc(i))>abs(aa(1))
    %  cc(i) = aa(i);
    %endif

end%for

high     = filterSignal_butter(cc, 'high', fR,'order', 4, 'cutoff', 30);
%low1  = filterSignal_butter(high, 'low', fR, 'order', 2, 'cutoff', 30); % 4th order low-pass Butterworth filter 6 Hz

demeaned      = high - mean(high); % demeaned

rectif     = sqrt(demeaned.^2); %rectified
low2  = filterSignal_butter(rectif, 'low', fR, 'order', 2, 'cutoff', 6); % 4th ord
figure (11)
plot(aa)
figure(12)
plot(bb)
figure(13)
plot(cc)
figure(14)
plot(be)

%                                 over
%                                 under

figure(15)
plot(diff(bb))
hold all
plot(diff(be))
%c1 = cc;
figure(16)
plot(aa)
hold all
plot(cc)

figure(20)
plot(low2)