function modelOutName = computeMuscleStrengthScaleFactors(modelIn, height, mass, rho)


%%
% fractional muscle volumes (% of cumulative lower limb volumes)
% from Handsfield et al 2014 JBiomech, only muscle in Rajaganopol model

% hip muscles
glmax = 0.12; addmag = 0.08; glmed = 0.045; psoas = 0.04; iliacus = 0.023;
sart = 0.022; addlong = 0.022; glmin = 0.018; addbrev = 0.018; grac = 0.018;
tfl = 0.01;

% knee muscles
vaslat = 0.115; vasmed = 0.06; vasint = 0.04; recfem = 0.04; semimem = 0.038; bflh = 0.035;
semiten = 0.028; bfsh = 0.018;

% ankle muscles
soleus = 0.06; gasmed = 0.04; gaslat = 0.022; tibant = 0.02; peroneals = 0.02; tibpost = 0.019;
edl = 0.01; fdl = 0.01; ehl = 0.0085; fhl = 0.0085;

%% List of Handsfield muscles that are also in Rajagonopol model
listOfHandsfieldMuscleNames = {'addmag', 'addlong', 'addbrev', 'bflh', ... 
    'bfsh', 'edl', 'fhl', 'fdl', 'gaslat', 'gasmed', 'glmax', 'glmed', ... 
    'glmin', 'grac', 'iliacus', 'peroneals', 'psoas', 'tibpost', 'tibant', ... 
    'vasint', 'vaslat', 'vasmed'};

%% List of muscles root names in the Rajaganopol model
% listOfModelMusclesRootNames = {'addbrev', 'addlong', 'addmag', 'bflh', ... 
%     'bfsh', 'edl', 'ehl', 'fdl', 'fhl', 'gaslat', 'gasmed', 'glmax1', ... 
%     'glmed', 'glmin', 'grac', 'iliacus', 'perbrev', 'perlong', 'psoas', ... 
%     'recfem', 'sart', 'semimem', 'semiten', 'soleus', 'tfl', 'tibant', ...
%     'tibpost', 'vasint', 'vaslat', 'vasmed'};

 listOfModelMusclesRootNames = {'addbrev', 'addlong', 'addmag', 'bflh', ... 
     'bfsh', 'edl', 'ehl', 'fdl', 'fhl', 'gaslat', 'gasmed', 'glmax1', ... 
     'glmed', 'glmin', 'grac', 'iliacus', 'perbrev', 'perlong', 'psoas', ... 
     'recfem', 'sart', 'semimem', 'semiten', 'soleus', 'tfl', 'tibant', ...
     'tibpost', 'vasint', 'vaslat', 'vasmed'};


%% Import classes
import org.opensim.modeling.*
model = Model(modelIn);
model.initSystem;

%% Muscles in model
muscles = model.getMuscles();
nMuscles = muscles.getSize();

muscleNames = cell(nMuscles, 1);
muscleForce = zeros(nMuscles,1);
muscleOptFiberLength = zeros(nMuscles,1);
muscleVolume = zeros(nMuscles,1);

for i = 0:nMuscles-1
    
    currentMuscle = muscles.get(i);
    muscleNames{i+1} = char(currentMuscle.getName());
    muscleForce(i+1) = currentMuscle.getMaxIsometricForce();
    muscleOptFiberLength(i+1) = currentMuscle.getOptimalFiberLength()*100; % in cm
    muscleVolume(i+1) = (muscleForce(i+1)*muscleOptFiberLength(i+1))/rho;

end



%% Theoretical lower-limb muscle volume (unilateral) from Handsfield equations
vTheory = (47*mass*(height/1000)) + 1285;

%% Loop through muscles and some default isometric forces per group, determine
% fractional isometric force

addmagIsoForce = zeros(4,2);
magIndex = 1;

glmaxIsoForce = zeros(3,2);
glmaxIndex = 1;

glmedIsoForce = zeros(3,2);
glmedIndex = 1;

glminIsoForce = zeros(3,2);
glminIndex = 1;

digitalisIsoForce = zeros(2,2);
digitalisIndex = 1;

hallucisIsoForce = zeros(2,2);
hallucisIndex = 1;

for i = 1:length(listOfModelMusclesRootNames)
    
    lengthOfName = length(listOfModelMusclesRootNames{i});
    
    for j = 1:length(muscleNames)
        
        if strncmp(listOfModelMusclesRootNames{i}, muscleNames{j}, lengthOfName)
            
            if strncmp(muscleNames(j), 'addmag', 6)
                
                addmagIsoForce(magIndex,1) = muscleForce(j);
                magIndex = magIndex + 1;
                addmagIsoForce(magIndex,1) = muscleForce(j+1);
                magIndex = magIndex + 1;
                addmagIsoForce(magIndex,1) = muscleForce(j+2);
                magIndex = magIndex + 1;
                addmagIsoForce(magIndex,1) = muscleForce(j+3);
                
            elseif strncmp(muscleNames(j), 'glmax', 4)
                
                glmaxIsoForce(glmaxIndex,1) = muscleForce(j);
                glmaxIndex = glmaxIndex + 1;
                glmaxIsoForce(glmaxIndex,1) = muscleForce(j+1);
                glmaxIndex = glmaxIndex + 1;
                glmaxIsoForce(glmaxIndex,1) = muscleForce(j+2);
                
            elseif strncmp(muscleNames(j), 'glmed', 4)
                
                glmedIsoForce(glmedIndex,1) = muscleForce(j);
                glmedIndex = glmedIndex + 1;
                glmedIsoForce(glmedIndex,1) = muscleForce(j+1);
                glmedIndex = glmedIndex + 1;
                glmedIsoForce(glmedIndex,1) = muscleForce(j+2);
                
            elseif strncmp(muscleNames(j), 'glmin', 4)
                
                glminIsoForce(glminIndex,1) = muscleForce(j);
                glminIndex = glminIndex + 1;
                glminIsoForce(glminIndex,1) = muscleForce(j+1);
                glminIndex = glminIndex + 1;
                glminIsoForce(glminIndex,1) = muscleForce(j+2);
            
            elseif strncmp(muscleNames(j), 'fdl', 3) || strncmp(muscleNames(j), 'edl', 3)
                
                digitalisIsoForce(hallucisIndex,1) = muscleForce(j);
                digitalisIndex = digitalisIndex + 1;
                
            elseif strncmp(muscleNames(j), 'ehl', 3) || strncmp(muscleNames(j), 'fhl', 3)
                
                hallucisIsoForce(hallucisIndex,1) = muscleForce(j);
                hallucisIndex = hallucisIndex + 1;
                
            else % evlaute the name of the muscle and isoforce
                myMuscleIsoForce = [listOfModelMusclesRootNames{i}, 'IsoForce'];
                eval([myMuscleIsoForce ' = muscleForce(j);']);
                
            end
            
        break;    
            
        end
        
    end
    
end

sumAddmagIsoForce = sum(addmagIsoForce(:,1));
sumGlmaxIsoForce = sum(glmaxIsoForce(:,1));
sumGlmedIsoForce = sum(glmedIsoForce(:,1));
sumGlminIsoForce = sum(glminIsoForce(:,1));
sumDigitalisIsoForce = sum(digitalisIsoForce(:,1));
sumHallucisIsoForce = sum(hallucisIsoForce(:,1));

for i = 1:size(addmagIsoForce,1)
    
   addmagIsoForce(i,2) = addmagIsoForce(i,1)/sumAddmagIsoForce;
    
end

for i = 1:size(glmaxIsoForce,1)
    
    glmaxIsoForce(i,2) = glmaxIsoForce(i,1)/sumGlmaxIsoForce;
    
end

for i = 1:size(glmedIsoForce,1)
    
    glmedIsoForce(i,2) = glmedIsoForce(i,1)/sumGlmedIsoForce;
    
end

for i = 1:size(glminIsoForce,1)
    
    glminIsoForce(i,2) = glminIsoForce(i,1)/sumGlminIsoForce;
    
end

for i = 1:size(digitalisIsoForce,1)
    
    digitalisIsoForce(i,2) = digitalisIsoForce(i,1)/sumDigitalisIsoForce;
    
end

for i = 1:size(hallucisIsoForce,1)
    
    hallucisIsoForce(i,2) = hallucisIsoForce(i,1)/sumHallucisIsoForce;
    
end

%% Compute new muscle forces and apply to model
for i = 1:length(listOfHandsfieldMuscleNames)
    
    for j = 1:length(listOfModelMusclesRootNames)
    
        if strcmp(listOfHandsfieldMuscleNames{i}, listOfModelMusclesRootNames{j})
                
            eval(['fracVolInstance = ' listOfModelMusclesRootNames{j};]);
            volumeFractionInstance = vTheory*fracVolInstance;
            strengthFraction = (rho*volumeFractionInstance)/muscleOptFiberLength(j);
            
            if strcmp(listOfHandsfieldMuscleNames{i}, 'addmag')
                
                for k = 1:size(addmagIsoForce,1)
                    
                    aMuscle = muscles.get(k+1);
                    aMuscle.setMaxIsometricForce(strengthFraction*addmagIsoForce(k,2))
                    
                end
                
            elseif strcmp(listOfHandsfieldMuscleNames{i}, 'glmax')
                
                for k = 1:size(glmaxIsoForce,1)
                    
                    aMuscle = muscles.get(k+13);
                    aMuscle.setMaxIsometricForce(strengthFraction*glmaxIsoForce(k,2));
                    
                end
                
            elseif strcmp(listOfHandsfieldMuscleNames{i}, 'glmed')
                
                for k = 1:size(glmedIsoForce,1)
                    
                    aMuscle = muscles.get(k+16);
                    aMuscle.setMaxIsometricForce(strengthFraction*glmedIsoForce(k,2));
                    
                end
                
            elseif strcmp(listOfHandsfieldMuscleNames{i}, 'glmin')
                
                for k = 1:size(glminIsoForce,1)
                    
                    aMuscle = muscles.get(k+19);
                    aMuscle.setMaxIsometricForce(strengthFraction*glminIsoForce(k,2));
                    
                end
                
            elseif strcmp(listOfHandsfieldMuscleNames{i}, 'fdl') || strcmp(listOfHandsfieldMuscleNames{i}, 'edl')
                
                newEdlIsoForce = strengthFraction*digitalisIsoForce(1,2);
                newFdlIsoForce = strengthFraction*digitalisIsoForce(2,2);
                
                aMuscle = muscles.get(8);
                aMuscle.setMaxIsometricForce(newEdlIsoForce);
                aMuscle = muscles.get(10);
                aMuscle.setMaxIsometricForce(newFdlIsoForce);
                
            elseif strcmp(listOfHandsfieldMuscleNames{i}, 'fhl') || strcmp(listOfHandsfieldMuscleNames{i}, 'ehl')
                
                newEhlIsoForce = strengthFraction*hallucisIsoForce(1,2);
                newFhlIsoForce = strengthFraction*hallucisIsoForce(2,2);
                
                aMuscle = muscles.get(9);
                aMuscle.setMaxIsometricForce(newEhlIsoForce);
                aMuscle = muscles.get(11);
                aMuscle.setMaxIsometricForce(newFhlIsoForce);
                
            else % all other muscles
                
                lengthOfMuscleInstance = length(listOfModelMusclesRootNames{j});
                
                for x = 1:length(muscleNames)
                    
                    if strncmp(muscleNames{x}, listOfModelMusclesRootNames{j}, lengthOfMuscleInstance)
                        
                        muscleName = model.getMuscles().get(muscleNames{x});
                        muscleClass = char(muscleName.getConcreteClassName);
                        eval(['myMuscle = ' muscleClass '.safeDownCast(muscleName);']);
                        myMuscle.setMaxIsometricForce(strengthFraction);
                        
                        break;
                        
                    end
                end
            end
            
            break;
            
        end
    end
end

%% Print model with new muscle strengths
model.setName([acquisitionInfo.Subject.Code, '_strengthAdjusted']);
modelOut = modelOutName;
model.print(modelOut)
disp(['The new model has been saved at ' modelOut]);