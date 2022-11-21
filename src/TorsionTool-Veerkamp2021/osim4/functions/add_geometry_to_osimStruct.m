
function dataModel = add_geometry_to_osimStruct(dataModel,body_coordinates_OpenSim,VTKstruct,modelName,answerLeg,bone)

% convert the body data back to string
body_rotated = sprintf('\t\t\t%+8.6f %+8.6f %+8.6f\n',body_coordinates_OpenSim');
body_Repared = strrep(body_rotated,'+',' ');
% replace the generic data with the rotated bone
VTKstruct.VTKFile.PolyData.Piece.Points.DataArray.Text = body_Repared;

% convert the struct back to xml file
Body_rotated = struct2xml(VTKstruct);
%name and placement of the bone file
direct = [];
% export - write the model as an xml  - remember to save as a vtp file
boneName = [bone upper(answerLeg) '_rotated.vtp'];
cBody = sprintf('%s_%s' ,modelName,boneName);
placeName = sprintf('%s', direct, place, cBody);
FID = fopen(placeName,'w');
fprintf(FID,Body_rotated);
fclose(FID);

%change the name of the bone in the gait2392 model file
if contains(bone,'tibia')
    dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,3}.attached_geometry.Mesh{1,1}.mesh_file = cBody;
elseif contains(bone,'talus')
     dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,4}.attached_geometry.Mesh.mesh_file = cBody;
elseif contains(bone,'calcn')
    dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,5}.attached_geometry.Mesh.mesh_file = cBody;
elseif contains(bone,'toes')
    dataModel.OpenSimDocument.Model.BodySet.objects.Body{1,6}.attached_geometry.Mesh.mesh_file = cBody;
end