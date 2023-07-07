function Dirs = getDirs()

Dirs = struct;
Dirs.main = 'Z:\EMG_realtime_biofeedback';
Dirs.data = [Dirs.main fp 'TD10_Data'];
Dirs.model_path = [Dirs.main fp 'Model\defModel_scaled.osim'];
Dirs.marker_weights = [Dirs.main fp 'marker_weights.xml'];
Dirs.results = [Dirs.main fp 'Results' fp 'EMG' fp 'emg.mat'];