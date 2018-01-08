function trials2mda(filename)
	S=load(filename);
    test_pulse_l=35000;
    for i=1:length(S.T_select)
        T=load(['Trials_EPSC_auto_accel_' S.T_select(i).FName]);
        mat_files={T.Trials(S.T_select(i).trials_select).mat_file};
        path=['../20' S.T_select(i).FName(3:8) '/' S.T_select(i).FName];
        cd(path)
        for j=1:length(mat_files)
            D=load(mat_files{j});
            S.T_select(i).data_raw(:,j)=D.Data(:,1);
            S.T_select(i).accel_raw(:,j)=D.Data(:,2);
        end
        [y,x]=size(S.T_select(i).data_raw);
        data_mda=reshape(S.T_select(i).data_raw,1,[]);
        accel_mda=reshape(S.T_select(i).accel_raw,1,[]);
        data_mda(1:test_pulse_l)=mean(data_mda(test_pulse_l+1:test_pulse_l+100));
        for j=1:x-1
            left_pad=mean(data_mda(j*y-100:j*y));
            right_pad=mean(data_mda(j*y+test_pulse_l:j*y+test_pulse_l+100));
            data_mda(j*y+1:j*y+test_pulse_l)=linspace(left_pad,right_pad,test_pulse_l);
        end
        S.T_select(i).data_mda=data_mda;
        %% plot concatenated data to see the results
        figure;
        subplot(2,1,1)
        plot(data_mda)
        subplot(2,1,2)
        plot(accel_mda);
        title(S.T_select(i).FName,'interpreter','none');
        %% Write into mda format
        cd '/Users/zhikai/Documents/DATA/Ephys/Aerotech_recording_example/Trials_summary'
        writemda32(S.T_select(i).data_mda,[S.T_select(i).FName '.mda']);
    end
end