%__________________________________________________________________________
% Authors: Claudio Pizzolato, August 2014 ; Luca Modenese and Elena
% Ceseracciu, February 2015
% email: claudio.pizzolato@griffithuni.edu.au
% DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
%

function [ muscleList jointList] = getMusclesOnDof_BG( dofName, osimModel )

    import org.opensim.modeling.*;
    if ischar(osimModel)
        osimModel = Model(osimModel);
    end

    currentState=osimModel.initSystem();

    osimMuscles = osimModel.getMuscles();
    muscleList = {};
    jointList = {};
    for i = 0:osimMuscles.getSize()-1
        currentMuscleName = char(osimMuscles.get(i).getName());
        if osimMuscles.get(i).get_appliesForce() == 1                                                               % skip if muscle is disabled
            muscleCrossedJointSet = getJointsSpannedByMuscle(osimModel, currentMuscleName);

            for n_joint = 1:size(muscleCrossedJointSet,2)
                
                curr_joint = muscleCrossedJointSet{n_joint};                                                        % current joint

                curr_joint_CoordinateSet = osimModel.getJointSet().get(curr_joint).getCoordinateSet();              % get CoordinateSet for the crossed joint

                % Initial estimation of the nr of Dof of the CoordinateSet for that
                % joint before checking for locked and constraint dofs.
                nDOF = osimModel.getJointSet().get(curr_joint).getCoordinateSet().getSize();

                if nDOF == 0                                                                                        % skip welded joint and remove welded joint from muscleCrossedJointSet
                    continue
                end

                for n_coord = 0:nDOF-1                                                                              % calculating effective dof for that joint

                    curr_coord = curr_joint_CoordinateSet.get(n_coord);                                             % get coordinate
                    curr_coord_name = char(curr_coord.getName());

                    if curr_coord.getLocked(currentState)                                                           % skip dof if locked
                        continue;
                    end

                    % if coordinate is constrained then the independent coordinate and
                    % associated joint will be listed in the sampling "map"
                    if curr_coord.isConstrained(currentState) && ~curr_coord.getLocked(currentState)
                        constraint_coord_name = curr_coord_name;
                        % finding the independent coordinate
                        [ind_coord_name, ind_coord_joint_name] = getIndipCoordAndJoint(osimModel, constraint_coord_name); %#ok<NASGU>
                        % updating the coordinate name to be saved in the list
                        curr_coord_name = ind_coord_name;

                        % skip dof if independent coordinate locked (the coord
                        % correspondent to the name needs to be extracted)
                        if osimModel.getCoordinateSet.get(curr_coord_name).getLocked(currentState)
                            continue;
                        end
                    end

                    if (strcmp(dofName, curr_coord_name))
                        muscleList = [muscleList, currentMuscleName];
                        jointList = unique([jointList curr_joint]);
                    end
                end
            end
        end
    end
end
