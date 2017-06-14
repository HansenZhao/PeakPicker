function varargout = AdFig(varargin)
% ADFIG MATLAB code for AdFig.fig
%      ADFIG, by itself, creates a new ADFIG or raises the existing
%      singleton*.
%
%      H = ADFIG returns the handle to a new ADFIG or the handle to
%      the existing singleton*.
%
%      ADFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADFIG.M with the given input arguments.
%
%      ADFIG('Property','Value',...) creates a new ADFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AdFig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AdFig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AdFig

% Last Modified by GUIDE v2.5 12-Apr-2017 22:59:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AdFig_OpeningFcn, ...
                   'gui_OutputFcn',  @AdFig_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before AdFig is made visible.
function AdFig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AdFig (see VARARGIN)

% Choose default command line output for AdFig
handles.output = hObject;
handles.zRange = varargin{1};
handles.xl = handles.axes1.XLim;
handles.yl = handles.axes1.YLim;
handles.zl = handles.axes1.ZLim;
handles.isAxesModified = false;
set(handles.Slider_Buttom,'Min',-200,'Max',0,'Value',max(handles.zRange(1),0));
set(handles.Slider_Top,'Min',0.1,'Max',handles.zRange(2)*1.5,'Value',handles.zRange(2));
set(handles.CB_showGrid,'Value',1);
set(handles.CB_showBox,'Value',1);
set(handles.CB_showAXY,'Value',1);
set(handles.CB_showAZ,'Value',1);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AdFig wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AdFig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Btn_BGColor.
function Btn_BGColor_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_BGColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%c = uisetcolor();
prompt = {'R(0-1 or 0-255)','G(0-1 or 0-255)','B(0-1 or 0-255)'};
title = 'RGB setting';
numLines = 1;
defaultAns = {'0.94','0.94','0.94'};
answer = inputdlg(prompt,title,numLines,defaultAns);
if ~isempty(answer)
    c = [str2num(answer{1}),str2num(answer{2}),str2num(answer{3})];
    if max(c) > 1
        c = c/255;
    end
    set(handles.axes1,'Color',c);
end



% --- Executes on slider movement.
function Slider_Top_Callback(hObject, eventdata, handles)
% hObject    handle to Slider_Top (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = caxis;
if tmp(1) == eventdata.Source.Value
    tmp(1) = tmp(1) - 1;
    set(handles.Slider_Buttom,'Value',tmp(1));
end
caxis([tmp(1),eventdata.Source.Value]);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function Slider_Top_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Slider_Top (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function Slider_Buttom_Callback(hObject, eventdata, handles)
% hObject    handle to Slider_Buttom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = caxis;
if tmp(2) == eventdata.Source.Value
    tmp(2) = tmp(2) + 1;
    set(handles.Slider_Top,'Value',tmp(2));
end
caxis([eventdata.Source.Value,tmp(2)]);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function Slider_Buttom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Slider_Buttom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on selection change in PopM_CM.
function PopM_CM_Callback(hObject, eventdata, handles)
% hObject    handle to PopM_CM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = eventdata.Source.Value;
maps = eventdata.Source.String;
newmap = maps{val};
colormap(newmap);
% Hints: contents = cellstr(get(hObject,'String')) returns PopM_CM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopM_CM


% --- Executes during object creation, after setting all properties.
function PopM_CM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopM_CM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'parula','jet','hsv','hot','cool','gray'});



function Ed_XRange_Callback(hObject, eventdata, handles)
% hObject    handle to Ed_XRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.isAxesModified
    handles.xl = handles.axes1.XLim;
    handles.zl = handles.axes1.ZLim;
    handles.yl = handles.axes1.YLim;
end
str = get(hObject,'String');
strs = strsplit(str,' ');
if length(strs) == 2
    try
        set(handles.axes1,'Xlim',[str2num(strs{1}),str2num(strs{2})]);
        handles.isAxesModified = true;
    catch
        set(handles,'String','Error input');
    end
else
    set(hObject,'String','Error input');
end
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of Ed_XRange as text
%        str2double(get(hObject,'String')) returns contents of Ed_XRange as a double


% --- Executes during object creation, after setting all properties.
function Ed_XRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ed_XRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ed_YRange_Callback(hObject, eventdata, handles)
% hObject    handle to Ed_YRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ed_YRange as text
%        str2double(get(hObject,'String')) returns contents of Ed_YRange as a double
if ~handles.isAxesModified
    handles.xl = handles.axes1.XLim;
    handles.zl = handles.axes1.ZLim;
    handles.yl = handles.axes1.YLim;
end
str = get(hObject,'String');
strs = strsplit(str,' ');
if length(strs) == 2
    try
        set(handles.axes1,'Ylim',[str2num(strs{1}),str2num(strs{2})]);
        handles.isAxesModified = true;
    catch
        set(handles,'String','Error input');
    end
else
    set(hObject,'String','Error input');
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Ed_YRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ed_YRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ed_ZRange_Callback(hObject, eventdata, handles)
% hObject    handle to Ed_ZRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ed_ZRange as text
%        str2double(get(hObject,'String')) returns contents of Ed_ZRange as a double
if ~handles.isAxesModified
    handles.xl = handles.axes1.XLim;
    handles.zl = handles.axes1.ZLim;
    handles.yl = handles.axes1.YLim;
end
str = get(hObject,'String');
strs = strsplit(str,' ');
if length(strs) == 2
    try
        set(handles.axes1,'Zlim',[str2num(strs{1}),str2num(strs{2})]);
        handles.isAxesModified = true;
    catch
        set(handles,'String','Error input');
    end
else
    set(hObject,'String','Error input');
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Ed_ZRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ed_ZRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Btn_Reset.
function Btn_Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.isAxesModified
    set(handles.axes1,'Xlim',handles.xl);
    set(handles.axes1,'Ylim',handles.yl);
    set(handles.axes1,'Zlim',handles.zl);
end


% --- Executes on button press in CB_showGrid.
function CB_showGrid_Callback(hObject, eventdata, handles)
% hObject    handle to CB_showGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
     set(handles.axes1,'XGrid','on')
     set(handles.axes1,'YGrid','on')
     set(handles.axes1,'ZGrid','on')
else
     set(handles.axes1,'XGrid','off')
     set(handles.axes1,'YGrid','off')
     set(handles.axes1,'ZGrid','off')
end
% Hint: get(hObject,'Value') returns toggle state of CB_showGrid


% --- Executes on button press in CB_showBox.
function CB_showBox_Callback(hObject, eventdata, handles)
% hObject    handle to CB_showBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.axes1,'Box','on');
else
    set(handles.axes1,'Box','off');
end
    
% Hint: get(hObject,'Value') returns toggle state of CB_showBox


% --- Executes on button press in CB_showAXY.
function CB_showAXY_Callback(hObject, eventdata, handles)
% hObject    handle to CB_showAXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.axes1.XAxis,'Visible','on');
    set(handles.axes1.YAxis,'Visible','on');
else
    set(handles.axes1.XAxis,'Visible','off');
    set(handles.axes1.YAxis,'Visible','off');
end
% Hint: get(hObject,'Value') returns toggle state of CB_showAXY


% --- Executes on button press in CB_showAZ.
function CB_showAZ_Callback(hObject, eventdata, handles)
% hObject    handle to CB_showAZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.axes1.ZAxis,'Visible','on');
else
    set(handles.axes1.ZAxis,'Visible','off');
end
% Hint: get(hObject,'Value') returns toggle state of CB_showAZ


% --- Executes on button press in Btn_Save.
function Btn_Save_Callback(hObject, eventdata, handles)
% hObject    handle to Btn_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,filePath,index] = uiputfile('*.png','Save png...','default');
if index
    %savefig(handles.figure1,strcat(filePath,fileName));
    %saveas(handles.figure1,strcat(filePath,fileName));
    saveas(handles.axes1,strcat(filePath,fileName));
    disp(strcat('File saved:',32,filePath,fileName));
end
