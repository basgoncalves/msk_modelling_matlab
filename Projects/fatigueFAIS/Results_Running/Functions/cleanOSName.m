function Output = cleanOSName (Name)

    Output = strrep(Name,'on_l','on');
    Output = strrep(Output,'on_r','on');
    Output = erase(Output,'_angle_r');
    Output = erase(Output,'_angle_l');

