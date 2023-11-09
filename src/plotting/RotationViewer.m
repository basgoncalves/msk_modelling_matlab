function [ MainFigureHandle ] = RotationViewer()
    % How to use: Simply specify the following 3 inputs in the GUI
    % 1. Rotation type:
    % -> Relative - successive rotations would be carried out about the axes of
    %               the newly rotated coordinate system. This kind of rotation
    %               are sometimes called intrinsic rotations.
    % -> Static - successive rotations are carried about the axes of a fixed
    %             coordinate system. These rotations are sometimes called
    %             extrinsic rotations.
    % 2. Rotation angles: - here you just put rotation angles in degrees
    %                       separated by space.
    % 3. Rotation Axis: Here the axsi about which rotations are done should be
    %                   specified as space separated x y or z.
    %
    % Eg: To rotate 30 deg about x, and then 20 deg about the new y and -45 deg
    %     about the new z, you need the following inputs
    %            Rotation Angles: 30 20 -45
    %            Rotation Axis: x y z
    %
    % NB: The number of rotation angles and rotation axis are not limited except
    %     that they should be of equal length.
    %
    
    % Author: Norman G. Worku
    % Email: normangirma2012@gmail.com
    % Date: 11.04.17
    
    
    fontSize = 9.5;
    fontName = 'FixedWidth';
    RefernceRotationMatrix = eye(3);
    
    % Creation of all uicontrols
    % --- FIGURE -------------------------------------
    MainFigureHandle = figure( ...
        'Tag', 'FigureHandle', ...
        'Units','Normalized',...
        'Position', [0.3,0.3,0.40,0.5], ...
        'Name', 'Rotation Viewer', ...
        'MenuBar', 'Figure', ...
        'NumberTitle', 'off', ...%'WindowStyle','Modal',...
        'Color', get(0,'DefaultUicontrolBackgroundColor'),...
        'CloseRequestFcn',{@figureCloseRequestFunction});
    
    % --- PANELS  AND TABS -------------------------------------
    panelReferenceCoordinate = uipanel( ...
        'Parent', MainFigureHandle, ...
        'Tag', 'panelReferenceCoordinate', ...
        'Units','Normalized',...
        'Position', [0.02,0.75,0.48,0.22], ...
        'FontSize',fontSize,'FontName',fontName,...
        'Visible','On');
    
    lblRotationMatrixRef = uicontrol( ...
        'Parent', MainFigureHandle, ...
        'Tag', 'lblRotationMatrixRef', ...
        'Style', 'text', ...
        'HorizontalAlignment','center',...
        'Units','Normalized',...
        'Position', [0.52,0.94,0.48,0.03], ...
        'FontSize',fontSize,'FontName',fontName,...
        'String', 'Rotation Matrix');
    
    tblRotationMatrixRef = uitable( ...
        'Parent', MainFigureHandle, ...
        'Tag', 'tblRotationMatrixRef', ...
        'Data',eye(3),...
        'FontSize',fontSize,'FontName',fontName,...
        'Units','Normalized',...
        'Position', [0.52,0.81,0.48,0.12],...
        'RowName',{},'ColumnName',{},...
        'ColumnWidth',{120,120,120},...
        'ColumnFormat',{'char','char','char'});
    
    lblRotationTypeRef = uicontrol( ...
        'Parent', panelReferenceCoordinate, ...
        'Tag', 'lblRotationTypeRef', ...
        'Style', 'text', ...
        'HorizontalAlignment','left',...
        'Units','Normalized',...
        'Position', [0.02,0.73,0.40,0.2], ...
        'FontSize',fontSize,'FontName',fontName,...
        'String', 'Rotation Type');
    popRotationTypeRef = uicontrol( ...
        'Parent', panelReferenceCoordinate, ...
        'Tag', 'popRotationTypeRef', ...
        'Style', 'popupmenu', ...
        'HorizontalAlignment','left',...
        'Units','Normalized',...
        'Position', [0.42,0.73,0.40,0.2], ...
        'FontSize',fontSize,'FontName',fontName,...
        'String', {'Relative','Static'},'Value',1);
    
    lblRotationAngleRef = uicontrol( ...
        'Parent', panelReferenceCoordinate, ...
        'Tag', 'lblRotationAngleRef', ...
        'Style', 'text', ...
        'HorizontalAlignment','left',...
        'Units','Normalized',...
        'Position', [0.02,0.43,0.40,0.2], ...
        'FontSize',fontSize,'FontName',fontName,...
        'String', 'Rotation Angle');
    txtRotationAngleRef = uicontrol( ...
        'Parent', panelReferenceCoordinate, ...
        'Tag', 'txtRotationAngleRef', ...
        'Style', 'edit', ...
        'HorizontalAlignment','left',...
        'Units','Normalized',...
        'Position', [0.42,0.43,0.40,0.2], ...
        'FontSize',fontSize,'FontName',fontName,...
        'String', '0 0 0');
    
    lblRotationAxesRef = uicontrol( ...
        'Parent', panelReferenceCoordinate, ...
        'Tag', 'lblRotationAxesRef', ...
        'Style', 'text', ...
        'HorizontalAlignment','left',...
        'Units','Normalized',...
        'Position', [0.02,0.13,0.40,0.2], ...
        'FontSize',fontSize,'FontName',fontName,...
        'String', 'Rotation Axis');
    txtRotationAxesRef = uicontrol( ...
        'Parent', panelReferenceCoordinate, ...
        'Tag', 'txtRotationAxesRef', ...
        'Style', 'edit', ...
        'HorizontalAlignment','left',...
        'Units','Normalized',...
        'Position', [0.42,0.13,0.40,0.2], ...
        'FontSize',fontSize,'FontName',fontName,...
        'String', 'X Y Z');
    
    btnRotatateRef = uicontrol( ...
        'Parent', MainFigureHandle, ...
        'Tag', 'btnRotatateRef', ...
        'Style', 'pushbutton', ...
        'HorizontalAlignment','left',...
        'Units','Normalized',...
        'Position', [0.52,0.75,0.15,0.05], ...
        'FontSize',fontSize,'FontName',fontName,...
        'String', 'Rotate',...
        'Callback', {@btnRotatateRef_Callback});
    btnResetRef = uicontrol( ...
        'Parent', MainFigureHandle, ...
        'Tag', 'btnResetRef', ...
        'Style', 'pushbutton', ...
        'HorizontalAlignment','left',...
        'Units','Normalized',...
        'Position', [0.85,0.75,0.15,0.05], ...
        'FontSize',fontSize,'FontName',fontName,...
        'String', 'Reset',...
        'Callback', {@btnResetRef_Callback});
    
    axesRef = axes( ...
        'Parent', MainFigureHandle, ...
        'Tag', 'axesRef', ...
        'Position', [0.2,0.1,0.6,0.6], ...
        'FontSize',fontSize,'FontName',fontName);
    plot3(axesRef,[0,0,0;1,0,0],[0,0,0;0,1,0],[0,0,0;0,0,1]);
    hold(axesRef, 'on');axis(axesRef,'equal');
    xlabel(axesRef,'X');ylabel(axesRef,'Y');zlabel(axesRef,'Z');
    xlim(axesRef,[-2,2]);
    ylim(axesRef,[-2,2]);
    zlim(axesRef,[-2,2]);
    grid(axesRef,'on');
    box(axesRef,'on');
    currR = eye(3);
    updateAxis(axesRef,currR);
    
    %% ---------------------------------------------------------------------------
    
    function btnRotatateRef_Callback(hObject,evendata) %#ok<INUSD>
        % read the roation angle and order
        rotType = get(popRotationTypeRef,'Value');
        rotAngleVector = str2num(strtrim(get(txtRotationAngleRef,'String')));
        rotAxisCellArray = strsplit(strtrim(get(txtRotationAxesRef,'String')));
        if length(rotAngleVector) ~= length(rotAxisCellArray)
            msgbox('The length of Angle and axis list should be equal.');
            return;
        end
        newR = RefernceRotationMatrix;
        for kk = 1:length(rotAngleVector)
            rotAngle = rotAngleVector(kk); rotAxis = rotAxisCellArray{kk};
            newR = updateAxis(axesRef,newR,rotAngle,rotAxis,rotType);
            
        end
        RefernceRotationMatrix = newR;
    end
    %% ---------------------------------------------------------------------------
    function btnResetRef_Callback(hObject,evendata) %#ok<INUSD>
        RefernceRotationMatrix = eye(3);
        cla(axesRef);
        newR = updateAxis(axesRef,RefernceRotationMatrix);
    end
    
    %% ---------------------------------------------------------------------------
    
    function figureCloseRequestFunction(~,~)
        delete(MainFigureHandle);
    end
    function newR = updateAxis(plotAxes,currR,rotAngle,rotAxis,rotType)
        if nargin < 1; figure;plotAxes = axes; end;
        if nargin < 2; currR = eye(3); end;
        if nargin < 3; rotAngle = 0; end;
        if nargin < 4; rotAxis = 'x'; end;
        if nargin < 5; rotType = 1; end;
        %
        N = ceil(abs(rotAngle));
        pauseTime = 1/(2*N);
        position = [0,0,0];
        axisLength = 1;
        if rotAngle ~= 0
            for n = 1:N
                cla(plotAxes);
                R = GetMatrix(rotAngle*n/N,rotAxis,currR,rotType);
                if rotType == 1
                    newR = currR*R;
                else
                    newR = R*currR;
                end
                plotXYZAxes( newR, position, axisLength, plotAxes );
                pause(pauseTime);
            end
        else
            newR = currR;
        end
        cla(plotAxes);
        plotXYZAxes( newR, position, axisLength, plotAxes );
        set(tblRotationMatrixRef,'Data',newR);
    end
    function R = GetMatrix(rotAngle,rotAxis,currR,rotType)
        theta = rotAngle*pi/180;
        R = eye(3);
        if strcmpi(rotAxis,'x')
            R(1,1) = 1;
            R(2,2) = cos(theta);
            R(2,3) = -sin(theta);
            R(3,2) = sin(theta);
            R(3,3) = cos(theta);
            R = R;
        elseif strcmpi(rotAxis,'y')
            R(1,1) = cos(theta);
            R(1,3) = sin(theta);
            R(2,2) = 1;
            R(3,1) = -sin(theta);
            R(3,3) = cos(theta);
        elseif strcmpi(rotAxis,'z')
            R(1,1) = cos(theta);
            R(1,2) = -sin(theta);
            R(2,1) = sin(theta);
            R(2,2) = cos(theta);
            R(3,3) = 1;
        else
            theta = 0;
            R(1,1) = 1;
            R(2,2) = cos(theta);
            R(2,3) = -sin(theta);
            R(3,2) = sin(theta);
            R(3,3) = cos(theta);
        end
    end
    
    function plotAxes = plotXYZAxes( rotationMatrix, position, axisLength, plotAxes )
        %PLOTXYZAXES Summary of this function goes here
        %   Detailed explanation goes here
        
        if nargin < 1
            error('The function plotXYZAxes requires the rotation matrix as argument.');
        end
        if nargin < 2
            position = [0,0,0];
        end
        if nargin < 3
            axisLength = 1;
        end
        if nargin < 4
            figure;
            plotAxes = axes;
        end
        
        % Plot the local x and y axis over each surface
        local_x_axes = (rotationMatrix(:,1))';
        local_y_axes = (rotationMatrix(:,2))';
        local_z_axes = (rotationMatrix(:,3))';
        
        locX_p1 = position; %
        locX_p2 = position + axisLength*local_x_axes;
        
        locY_p1 = position; %
        locY_p2 = position + axisLength*local_y_axes;
        
        locZ_p1 = position;
        locZ_p2 = position + axisLength*2*local_z_axes;
        
        hold on;
        plot3(plotAxes,...
            [locX_p1(1),locY_p1(1),locZ_p1(1);locX_p2(1),locY_p2(1),locZ_p2(1)],...
            [locX_p1(2),locY_p1(2),locZ_p1(2);locX_p2(2),locY_p2(2),locZ_p2(2)],...
            [locX_p1(3),locY_p1(3),locZ_p1(3);locX_p2(3),locY_p2(3),locZ_p2(3)],'LineWidth',2.5);
        view(3)
    end
end
