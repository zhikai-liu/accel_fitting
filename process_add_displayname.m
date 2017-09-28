function process_add_displayname(filename,displayname)
    S=load(filename);
    for i=1:length(S.Trials)
        S.Trials(i).bode_displayname=displayname{S.Trials(i).accel_axis-1};
    end
    save(filename,'-struct','S')
end