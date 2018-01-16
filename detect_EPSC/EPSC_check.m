% file = 'ZL170517_fish03a_0016.abf';
% [Data,si,~] = abfload(file);
% %% define parameters for analysis
% amp_thre = 6;  %threshold for ESPC amplitudes
% diff_gap = 240; % gap for taking the difference, 240us in this case
% diff_thre = -8; % threshold for difference to detect event
% 
% [event_index, amps] = EPSC_detection(Data,si,amp_thre,diff_gap,diff_thre);
% save('test.mat','Data','si','event_index','amps')
%% plot the data and detection results
function EPSC_check(datafile,event_num,varargin)
S = load(datafile);
Data = S.Data; si = S.si;
%%  if no extra input is recieved, use event_index; User can also specify to check only missing_events, for example.
if isempty(varargin)
    event_index = S.event_index;
else 
    event_index =S.(varargin{1});
end
%% Save Tags
if isfield(S,'Tag')
    Tag = S.Tag;
else
    Tag = ones(1,length(event_index));
end
F = figure('Units','normal',...
    'Position',[0 .025 1 .95],...
    'Visible', 'on',...
    'KeyPressFcn',@CheckEPSC); % Key press to enable 'keyboard mode' for manually checking EPSCs detected
setappdata(F,'counter',event_num); % set counter for which event is being checked at the moment
setappdata(F,'keyboardMode',0); % set a global for which mode it is in. keyboard = 0 or 1
setappdata(F,'CheckTag',Tag); % set a checktag to record manual checking result. -1 for excluded and 1 for pass
setappdata(F,'filename',datafile);
setappdata(F,'event_index',event_index);
slider = uicontrol(F,'Style','slider',...
    'Units','normal',...
    'Position', [0 .01 1 .015],...
    'Min',0,'Max',50,'Value',0);  % add a slider
unit_UI = uicontrol('Style', 'popup',... % add a popup menu for choosing the unit for time
    'String', {'unit','ms','s'},...
    'Units','normal',...
    'Position', [0.92 0.2 0.07 0.1],...
    'Callback',{@SetTime,si});     % si is the sampling rate, which is needed to set the unit of time
save_UI = uicontrol('Style','pushbutton',...
    'String','save tag',...
    'Units','normal',...
    'Position',[0.92 0.1 0.07 0.03],...
    'Callback',@saveTag);
addlistener(slider,'Value','PostSet',@traceScroll); % add a listener to the slider to enable real-time slider control
%addlistener(unit_UI,'Value','PreSet',@(source,event)setTime(source,event,si));
data_s = smooth(Data(:,1));
plot(data_s); % plot the original trace
counter = getappdata(F,'counter');    
hold on
scatter(event_index,data_s(event_index),20,'filled'); % plot the start point of each event
scatter(event_index(counter),data_s(event_index(counter)),20,'*','g'); % plot a '*' on the graph for knowing which event is being checked

end
%% callback function for slider control
function traceScroll(~,event)
    A = get(gcf,'Children');
    Xlim = get(gca,'xlim');
    kids = get(A(length(A)),'Children');
    XData = kids(length(kids)).XData;
    WindowSize = diff(Xlim);
    ZoomFactor = (length(XData)-WindowSize)/50;
    SliderPosition = get(event.AffectedObject,'Value');
    
    %if Xlim(1)> SliderPosition*ZoomFactor+WindowSize || Xlim(2)<SliderPosition*ZoomFactor
    %    set(event.AffectedObject,'Value',Xlim(1)/ZoomFactor);
    %else
        set(gca,'xlim',[SliderPosition*ZoomFactor SliderPosition*ZoomFactor+WindowSize]);
    %end
end

%% callback function for setting the time
function SetTime(source,~,si)
    A = get(gcf,'Children');
    switch length(A)
        case 4
            AxesNum = 1;
        case 6
            AxesNum = 2; 
        otherwise
          error('wrong axes number'); 
    end
    for i = 1:AxesNum
        XLabel = get(A(length(A)+1-i),'XLabel');
        kids = get(A(length(A)+1-i),'Children');
        switch XLabel.String
            case ''
                ScaleFactor  = 1;
            case 'ms'
                ScaleFactor  = 1e3/si;
            case 'second'
                ScaleFactor  = 1e6/si;
        end
        for j = 1:length(kids)
            XData = get(kids(j),'XData')*ScaleFactor;
            switch source.Value
                case 1
                    set(kids(j),'XData',XData)
                    set(XLabel,'String','')
                case 2
                    set(kids(j),'XData',XData*si/1e3)
                    set(XLabel,'String','ms')
                case 3
                    set(kids(j),'XData',XData*si/1e6)
                    set(XLabel,'String','second')
            end
        end
        CheckEPSC();
    end
 
end
%% Manual checking EPSC in keyboard mode
function CheckEPSC(varargin)
    F = gcf;
    A = get(F,'Children');
    kids = get(A(length(A)),'Children');
	%% get the data from the figure first for later use
    YData = kids(length(kids)).YData;
    index = getappdata(F,'counter');
    XData = kids(length(kids)).XData;
    event = getappdata(F,'event_index');
    %% identify keyboard input 'k' for entering the 'keyboard mode' and 'q' for exiting the 'keyboard mode'
    if ~isempty(varargin)
    switch varargin{2}.Character
        case 'k'
            if getappdata(F,'keyboardMode') == 0
                A = get(gcf,'Children');
                CheckTag = getappdata(F,'CheckTag');
                setappdata(F,'keyboardMode',1)
                %% changing the size of original plot to a smaller one
                set(A(length(A)),'Units','normal','Position', [0.5 .15 .4 .35],...
                'xlim',[XData(max(event(index)-100,1)) XData(min(event(index)+200,length(XData)))]);
                hold off;
                %% add two new plots, A2 is the same as A and A3 is showing the CheckTag information
                A2 = subplot(4,1,1);
                copyobj(allchild(A(length(A))),A2);
                A3 = subplot(4,1,2);
                plot(1:length(CheckTag),CheckTag);
                hold on;
                scatter(index,CheckTag(index),20,'*','g');
                hold off;
                set(A2,'Units','normal','Position', [0.1 .6 .8 .2],...
                    'xlim',[XData(max(event(index)-1000,1)) XData(min(event(index)+2000,length(XData)))]);
                set(A3,'Units','normal','Position', [0.1 .86 .8 .08],...
                    'xlim',[1 length(CheckTag)],...
                    'ylim',[-1.5 1.5]);
            end
            
        case 'q'
            if getappdata(F,'keyboardMode') == 1
                A = get(gcf,'Children');
                %% change A to its original size and delete A2, A3 when exiting
                set(A(length(A)),'Units','normal','Position', 'default');
                set(A(length(A)),'xlim',[XData(1) XData(end)],...
                    'ylim',[-inf inf]);
                setappdata(F,'keyboardMode',0)
                delete(A(length(A)-1));
                delete(A(length(A)-2));
            end
    end
    end
    %% when the figure is in 'keyboard mode', use 'rightarrow', 'leftarrow','uparrow' to control the check each EPSC event
    if getappdata(F,'keyboardMode') == 1
        if ~isempty(varargin)
        switch varargin{2}.Key
        case 'rightarrow'
            if index < length(event)
            % move one step forward when pressing rightarrow key
            setappdata(F,'counter',index+1);
            else
            beep;
            end
        case 'leftarrow'
            if index > 1
            % move one step backward when pressing leftarrow key
            setappdata(F,'counter',index-1);
            else
            beep;
            end
        case 'uparrow'
            % change the CheckTag when pressing the up arrowkey
            A = get(gcf,'Children');
            CheckTag = getappdata(F,'CheckTag');
            CheckTag(index) = -CheckTag(index);
            setappdata(F,'CheckTag',CheckTag);
            set(A(length(A)-2).Children,'YData',CheckTag);
        end
        end
        %% moving the window to the next/previous event on both A and A2
        A = get(gcf,'Children');
        new_index= getappdata(F,'counter');
        Y_range = YData(max(event(new_index)-100,1):min(event(new_index)+200,length(YData)));
        Y_scale = max(Y_range)-min(Y_range);
        set(A(length(A)),'xlim',[XData(max(event(new_index)-100,1)) XData(min(event(new_index)+200,length(XData)))],...
            'ylim',[min(Y_range)-0.2*Y_scale max(Y_range)+0.2*Y_scale]);
        set(A(length(A)-1),'xlim',[XData(max(event(new_index)-1000,1)) XData(min(event(new_index)+2000,length(XData)))],...
            'ylim',[-inf inf])
        %% Moving the '*' to track which event is under checking
        SSkids = A(length(A)+1-3).Children;
        CheckTag = getappdata(F,'CheckTag');
        if CheckTag(new_index) == 1
            New_color = [0 1 0]; %Color is green when pass
        else
            New_color = [1 0 0]; %Color is red when excluded
        end
        set(SSkids(1),'XData',new_index,...
            'YData',CheckTag(new_index),...
            'CData',New_color);
        for i = 1:2
            SSkids = A(length(A)+1-i).Children; % get '*' scatter children for both two plots
            X_scale = diff(get(A(length(A)+1-i),'xlim'));
            set(SSkids(length(SSkids)-2),...
                'XData',XData(event(new_index))+0.01*X_scale,...
                'YData',YData(event(new_index)),...
                'CData',New_color);
        end
        
    end
end

function saveTag(varargin)
     F =gcf;
     Tag = getappdata(F,'CheckTag');
     datafile = getappdata(F,'filename');
     save(datafile,'Tag','-append');
end