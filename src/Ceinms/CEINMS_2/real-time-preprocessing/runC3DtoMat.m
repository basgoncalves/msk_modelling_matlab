function [ baseDir ] = runC3DtoMat( c3dFolder )
%RUNC3DTOMAT Summary of this function goes here
%   Detailed explanation goes here

    addpath('shared');
    mototnmapath = getMOtoNMSpath();
    fp = getFp();
    cwd = pwd;
    
    c3d2matpath = [mototnmapath fp 'src' fp 'C3D2MAT_btk'];
    cd(c3d2matpath);
    sessionFolder = C3D2MAT();
    cd(sessionFolder)
    cd('..')
    baseDir = pwd;
    cd(cwd);
    
end

