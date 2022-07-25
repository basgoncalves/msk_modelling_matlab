function [] = RRA_main_exam()
A = ones(7,19)*6;
i = 1;
while 1
    if i == 1
        
disp('Choose the ID directory file:')
iddir= uigetdir();

disp('Choose the input .osim model:')
[modelf,modelp]=uigetfile('*.osim');
selectedmodel= fullfile(modelp,modelf);

disp('Choose the input .mot file:')
[motf,motp]=uigetfile('*.mot');
selectedmot= fullfile(motp,motf);

disp('Choose the input GRF file:')
[grff,grfp]=uigetfile('*.xml');
selectedgrf= fullfile(grfp,grff);

disp('Choose the input Tasks file:')
[taskf,taskp]=uigetfile('*.xml');
selectedtask= fullfile(taskp,taskf);

disp('Choose the input Actuators file:')
[actuatorf,actuatorp]=uigetfile('*.xml');
selectedactuator= fullfile(actuatorp,actuatorf);

disp('Choose the input Constraints file:')
[constraintf,constraintp]=uigetfile('*.xml');
selectedconstraint= fullfile(constraintp,constraintf);

disp('Choose the Results directory file:')
selecteddir= uigetdir();

disp('Choose the output .osim model:')
[outmodelf,outmodelp]=uigetfile('*.osim');
selectedoutmodel= fullfile(outmodelp,outmodelf);

start_time = input('Enter the start time:');

final_time = input('Enter the end time: ');

    else
        
disp('Choose the input .osim model:')
[modelf,modelp]=uigetfile('*.osim');
selectedmodel= fullfile(modelp,modelf);     
 
disp('Choose the input Tasks file:')
[taskf,taskp]=uigetfile('*.xml');
selectedtask= fullfile(taskp,taskf);

disp('Choose the input Actuators file:')
[actuatorf,actuatorp]=uigetfile('*.xml');
selectedactuator= fullfile(actuatorp,actuatorf);

disp('Choose the input Constraints file:')
[constraintf,constraintp]=uigetfile('*.xml');
selectedconstraint= fullfile(constraintp,constraintf);

disp('Choose the Results directory file:')
selecteddir= uigetdir();

disp('Choose the output .osim model:')
[outmodelf,outmodelp]=uigetfile('*.osim');
selectedoutmodel= fullfile(outmodelp,outmodelf);

    end
save('RRA_main.m','iddir','start_time','final_time','selectedmot','selectedgrf');
import org.opensim.modeling.*
    
  
 Tab =  RRA_analysis_exam(iddir,modelf,selectedmodel,selectedmot,selectedgrf,selectedtask,actuatorf,selectedconstraint,selecteddir,start_time,final_time,selectedoutmodel)
 writetable(Tab,[selecteddir,'\_Data_table.xlsx'],'WriteRowNames',true);
 A = table2array(Tab);
 
 if (A(2,:)<5.5) & (abs(A(1,1))< 0.5) 
 break
 end
i= i+1;
end
end

