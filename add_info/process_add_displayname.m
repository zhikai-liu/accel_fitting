function process_add_displayname(filename,varargin)
    if ~isempty(varargin)
        displayname=varargin{1};
    else
        displayname={'Rostral','Ventral','Ipsilateral'};
    end
    S=load(filename);
    for i=1:length(S.Trials)
        S.Trials(i).bode_displayname=displayname{S.Trials(i).accel_axis-1};
    end
    save(filename,'-struct','S')
end