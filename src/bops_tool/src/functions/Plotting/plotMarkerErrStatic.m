

function [TSE,RMSE,MaxError] = plotMarkerErrStatic(DirOutLog,setupScaleXML,staticTRC,staticMot)

Log = importdata(DirOutLog, ' ', 100000);
for k = 1:length(Log)
    
    if ~contains(Log{k},'total squared error')
        continue
        
    else
        str = split(Log{k},'total squared error = ');
        num = split(str{2},',');
        TSE = str2num(num{1});
        disp(['total squared error = ' num{1} ' m'])
        
        str = split(Log{k},'marker error: RMS=');
        num = split(str{2},',');
        RMSE = str2num(num{1});
        disp(['RMSE = ' num{1} ' m'])
        
        str = split(Log{k},', max=');
        num = split(str{2},'(');
        MaxError = str2num(num{1});
        disp(['Max error = ' str{2}])
        
        break
        
    end
end

save Errors TSE RMSE MaxError

if nargin > 1
    XML = xml_read(setupScaleXML);
    IN  = load_trc_file(staticTRC);
    OUT = load_sto_file(staticMot);
    
    markers = XML.ScaleTool.MarkerPlacer.IKTaskSet.objects.IKMarkerTask;
    d = struct;
    for  i = 1:length(markers)                                                                  % check all the markers (start at 3 to skip "frame" and "time"
        
        iMarker = markers(i).ATTRIBUTE.name; 
        in = IN.(iMarker)./1000;
        out = [];
        out(1) = OUT.([iMarker '_tx']);
        out(2) = OUT.([iMarker '_ty']);
        out(3) = OUT.([iMarker '_tz']);
        
        d.(iMarker) = dist_markers(in,out);
        
    end
    fullsizefig
    bar(struct2array(d))
    plot([0 length(markers)],[0.05 0.05],'--k')
    ylim([0 0.3])
    ylabel('marker error (m)')
    xticks([1:length(markers)])
    xticklabels(fields(d))
    mmfn_inspect
    saveas(gcf,'marker_errors.jpeg')
end

