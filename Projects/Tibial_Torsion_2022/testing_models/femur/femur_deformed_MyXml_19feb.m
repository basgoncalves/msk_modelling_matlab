clear all
close all
clc

%% import the verticies of the bones to matlab
data = xml2struct('C:\Users\hulda\Documents\Delft\Delft_secondyear\Thesis\OpenSim\Gait2392_MDP_deformed\OpenSimToMatlab\femur\femur');
format long
%make sure you import the correct verticies, not the normals
femur = data.VTKFile.PolyData.Piece.Points.DataArray.Text;
femurNUM = str2num(data.VTKFile.PolyData.Piece.Points.DataArray.Text);

%femoral anteversion angle
angle = 180 ;
%rotation around the x-axis
Rx = [1 0 0; 0 cos(angle) sin(angle); 0 -sin(angle) cos(angle)];
rotationFemurX = femurNUM * Rx;

Ry = [cos(angle) 0 -sin(angle); 0 1 0; sin(angle) 0 cos(angle)];
rotationFemurY = femurNUM * Ry;

Rz = [cos(angle) sin(angle) 0; -sin(angle) cos(angle) 0; 0 0 1];
rotationFemurZ = femurNUM * Rz;

% Unrotated bone
% femurtogether = [];
% for i = 1:size(femurNUM,1)
%    femurtogether = [femurtogether,sprintf('\t\t\t%+8.6f %+8.6f %+8.6f\n',femurNUM(i,1:3))];
% end
% FemurRepared = strrep(femurtogether,'+',' ');
% test = str2num(femurtogether);

% Rotated bone
femurtogether = [];
for i = 1:size(rotationFemurZ,1)
   femurtogether = [femurtogether,sprintf('\t\t\t%+8.6f %+8.6f %+8.6f\n',rotationFemurZ(i,1:3))];
end
FemurRepared = strrep(femurtogether,'+',' ');
test = str2num(femurtogether);

%breytt af Mána - this works too
% femurtogetherMani=sprintf('\t\t\t%+8.6f %+8.6f %+8.6f\n',femurNUM');
% FemurReparedMani = strrep(femurtogether,'+',' ');
% testMani = str2num(femurtogetherMani);



%% plot the rotation of the bone
femurSize = size(femurNUM);
coordinates = zeros(401,femurSize(2));
x = [0:0.0002:0.08];
y = [0:0.0002:0.08];
z = [0:0.0002:0.08];
figure
scatter3(femurNUM(:,1),femurNUM(:,2),femurNUM(:,3),5,'r');
hold on
scatter3(x,coordinates(:,2),coordinates(:,3),3,'b');
hold on
scatter3(coordinates(:,1),y,coordinates(:,3),3,'b');
hold on
scatter3(coordinates(:,1),coordinates(:,2),z,3,'b');
title('Scatter plot of the undeformed and unrotated bone')
xlabel('X axis')
ylabel('Y axis')
zlabel('Z axis')

figure
scatter3(rotationFemurX(:,1),rotationFemurX(:,2),rotationFemurX(:,3),5,'r');
hold on
scatter3(x,coordinates(:,2),coordinates(:,3),3,'b');
hold on
scatter3(coordinates(:,1),y,coordinates(:,3),3,'b');
hold on
scatter3(coordinates(:,1),coordinates(:,2),z,3,'b');
title('Scattered plot of the underformed but rotated around the x-axis')
xlabel('X axis')
ylabel('Y axis')
zlabel('Z axis')

%rotation matix y-axis
figure
scatter3(rotationFemurY(:,1),rotationFemurY(:,2),rotationFemurY(:,3),5,'r');
hold on
scatter3(x,coordinates(:,2),coordinates(:,3),3,'b');
hold on
scatter3(coordinates(:,1),y,coordinates(:,3),3,'b');
hold on
scatter3(coordinates(:,1),coordinates(:,2),z,3,'b');
title('Scattered plot of the underformed but rotated around the y-axis')
xlabel('X axis')
ylabel('Y axis')
zlabel('Z axis')

%rotation matix z-axis
figure
scatter3(rotationFemurZ(:,1),rotationFemurZ(:,2),rotationFemurZ(:,3),5,'r');
hold on
scatter3(x,coordinates(:,2),coordinates(:,3),3,'b');
hold on
scatter3(coordinates(:,1),y,coordinates(:,3),3,'b');
hold on
scatter3(coordinates(:,1),coordinates(:,2),z,3,'b');
title('Scattered plot of the underformed but rotated around the z-axis')
xlabel('X axis')
ylabel('Y axis')
zlabel('Z axis')

%% Create the xml for the new rotated femur
%Create the document node and root element, toc:
docNode = com.mathworks.xml.XMLUtils.createDocument('VTKFile');
%Identify the root element, and set the version attribute:
VTKFile = docNode.getDocumentElement;
VTKFile.setAttribute('compressor','vtkLibDataCompressor');
VTKFile.setAttribute('version','0,1');
VTKFile.setAttribute('type','PolyData');
VTKFile.setAttribute('byte_order','LittleEndian');
%Add the tocitem element node for the product page. Each tocitem element in this file has a target attribute and a child text node:
product = docNode.createElement('PolyData');
VTKFile.appendChild(product)
product2 = docNode.createElement('Piece');
product.appendChild(product2)
product2.setAttribute('NumberOfPoints','456');
product2.setAttribute('NumberOfVerts','0');
product2.setAttribute('NumberOfLines','0');
product2.setAttribute('NumnerOfStrips','0');
product2.setAttribute('NumberOfPolys','908');
product3 = docNode.createElement('PointData');
product2.appendChild(product3)
product3.setAttribute('Normals','Normals');
product6 = docNode.createElement('DataArray');
product3.appendChild(product6);
value6 = data.VTKFile.PolyData.Piece.PointData.DataArray.Text;
product6.setTextContent(value6);
product6.setAttribute('Name','Normals');
product6.setAttribute('NumberOfComponents','3');
product6.setAttribute('format','ascii');
product6.setAttribute('type','Float32')
product4 = docNode.createElement('Points');
product2.appendChild(product4)
product7 = docNode.createElement('DataArray');
product4.appendChild(product7);
value7 = data.VTKFile.PolyData.Piece.Points.DataArray.Text;
value7a = FemurRepared;
product7.setTextContent(value7a)
product7.setAttribute('type','Float32');
product7.setAttribute('NumberOfComponents','3');
product7.setAttribute('format','ascii');
product5 = docNode.createElement('Polys');
product2.appendChild(product5)
product8 = docNode.createElement('DataArray');
value8 = data.VTKFile.PolyData.Piece.Polys.DataArray{1,1}.Text;
product8.setTextContent(value8);
product9 = docNode.createElement('DataArray');
value9 = data.VTKFile.PolyData.Piece.Polys.DataArray{1,2}.Text;
product9.setTextContent(value9);
product5.appendChild(product8);
product5.appendChild(product9);
product8.setAttribute('type','Int32');
product8.setAttribute('Name','connnectivity');
product8.setAttribute('format','ascii');
product9.setAttribute('type','Int32');
product9.setAttribute('Name','offsets');
product9.setAttribute('format','ascii');


% %Add a tocitem element node for each function, where the target is of the form function_help.html:
% functions = {'demFlow','facetFlow','flowMatrix','pixelFlow'};
% for idx = 1:numel(functions)
%     curr_node = docNode.createElement('tocitem');
%     
%     curr_file = [functions{idx} '_help.html']; 
%     curr_node.setAttribute('target',curr_file);
%     
%     % Child text is the function name.
%     curr_node.appendChild(docNode.createTextNode(functions{idx}));
%     product.appendChild(curr_node);
% end
%Export the DOM node to info.xml, and view the file with the type function:
xmlwrite('femurRotated.xml',docNode);
type('femurRotated.xml');
