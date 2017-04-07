function varargout = App(varargin)
% APP MATLAB code for App.fig
%      APP, by itself, creates a new APP or raises the existing
%      singleton*.
%
%      H = APP returns the handle to a new APP or the handle to
%      the existing singleton*.
%
%      APP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in APP.M with the given input arguments.
%
%      APP('Property','Value',...) creates a new APP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before App_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to App_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help App

% Last Modified by GUIDE v2.5 12-Jan-2017 23:37:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @App_OpeningFcn, ...
                   'gui_OutputFcn',  @App_OutputFcn, ...
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


% --- Executes just before App is made visible.
function App_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to App (see VARARGIN)

set(handles.ed_Peaks,'Enable','off');
set(handles.ed_Tolerance,'Enable','off');
set(handles.ed_MIR,'Enable','off');
set(handles.ed_MinFit,'Enable','off');
set(handles.btn_LoadFiles,'Enable','off');
set(handles.btn_ClearAll,'Enable','off');
set(handles.btn_FindPeaks,'Enable','off');
set(handles.btn_ViewResult,'Enable','off');
set(handles.btn_SaveResult,'Enable','off');
handles.output = hObject;
handles.logger = Logger(10,'Welcome to Mass Peaker!');
set(handles.tx_Log,'String',handles.logger.stringContent);
handles.peaks = [];
handles.tolerance = -1;
handles.MIR = -1;
handles.minFit = -1;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes App wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = App_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ed_MIR_Callback(hObject, eventdata, handles)
% hObject    handle to ed_MIR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = str2double(get(hObject,'String'));
if (tmp > 1 || tmp <= 0)
    warndlg('To get meaningful result, MIR should be set in range from 0 to 1!');
else
    handles.MIR = tmp;
    guidata(hObject,handles);
end

% Hints: get(hObject,'String') returns contents of ed_MIR as text
%        str2double(get(hObject,'String')) returns contents of ed_MIR as a double


% --- Executes during object creation, after setting all properties.
function ed_MIR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_MIR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_Tolerance_Callback(hObject, eventdata, handles)
% hObject    handle to ed_Tolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.tolerance = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ed_Tolerance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_Tolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_Peaks_Callback(hObject, eventdata, handles)
% hObject    handle to ed_Peaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmpStr = split(get(hObject,'String'),' ');
tmpNum = str2double(tmpStr);
if isnan(tmpNum)
    warndlg('Cannot Parse Input to mass, Please split each mass value by ''space key''!');
else
    handles.peaks = tmpNum;
    guidata(hObject,handles);
end



% --- Executes during object creation, after setting all properties.
function ed_Peaks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_Peaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_SaveResult.
function btn_SaveResult_Callback(hObject, eventdata, handles)
% hObject    handle to btn_SaveResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,filePath,index] = uiputfile('result.csv');
if index
    writer = CSVPeakWriter(handles.peaks,handles.tolerance,handles.MIR,handles.minFit,...
                           handles.parentList,handles.Ints,filePath,fileName);
    writer.write();
    handles.logger.addString(strcat('file has been write to: ',filePath,fileName));
    set(handles.tx_Log,'String',handles.logger.stringContent);
end


% --- Executes on button press in btn_FindPeaks.
function btn_FindPeaks_Callback(hObject, eventdata, handles)
% hObject    handle to btn_FindPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ((~isempty(handles.peaks))&&...
    (handles.tolerance > 0)&&...
    (handles.MIR > 0)&&...
    (handles.minFit > 0))

    handles.logger.addString(strcat('Find Peaks',32,'with tolerance:',32,num2str(handles.tolerance),...
                                    32,'Min Intensity Ratio',32,num2str(handles.MIR),...
                                    32,'Min Fit Num',32,num2str(handles.minFit)));
    set(handles.tx_Log,'String',handles.logger.stringContent);
    
    [handles.parentList,handles.Ints,handles.findNum] = ...
        handles.container.getDataContains(handles.peaks,handles.tolerance,handles.MIR,handles.minFit);
    
    handles.logger.addString(strcat('Find',32,num2str(handles.findNum),32,'files!'));
    set(handles.tx_Log,'String',handles.logger.stringContent);
    
    guidata(hObject,handles);
    set(handles.btn_SaveResult,'Enable','on');
else
    warndlg('Input parameters have not been set!')
end


% --- Executes on button press in btn_ViewResult.
function btn_ViewResult_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ViewResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Min Peak Intensity','Resolution(suggest: 600-6000)','Min Peak Width(suggest: 1-8)'};
title = 'MS1-MS2 Map Setting';
numLines = 1;
defaultAns = {'0.05','1000','2'};
answer = inputdlg(prompt,title,numLines,defaultAns);
if ~isempty(answer)
    [~,hf,hm] = handles.container.plotMS1MS2(str2num(answer{1}),str2num(answer{3}),str2num(answer{2}));
    h0  = uicontrol(hf,'Style', 'popup',...
           'String', {'parula','jet','hsv','hot','cool','gray'},...
           'Position', [20 80 100 50],...
           'Callback', @setmap);   
    tmp = caxis;
    h1 = uicontrol(hf,'String','Higher','Style','Slider','Position',[20,50,100,20],'Min',0,'Max',500,'Callback',@onSilder);
    set(h1,'Value',tmp(2));
    h2 = uicontrol(hf,'String','Lower','Style','Slider','Position',[20,20,100,20],'Min',-300,'Max',0,'Callback',@onSilder);
    set(h2,'Value',tmp(1));
end

function onSilder(source,event)
tmp = caxis;
if strcmp(source.String,'Lower')
    caxis([source.Value,tmp(2)]);
else
    caxis([tmp(1),source.Value]);
end

function setmap(source,event)
val = source.Value;
maps = source.String;
newmap = maps{val};
colormap(newmap);




% --- Executes on button press in btn_OpenFolder.
function btn_OpenFolder_Callback(hObject, eventdata, handles)
% hObject    handle to btn_OpenFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = uigetdir();
if path ~= 0
    str = strcat('Set Folder Path to:',32,path);
    handles.logger.addString(str);
    set(handles.tx_Log,'String',handles.logger.stringContent);
    handles.folderPath = path;
    set(handles.btn_LoadFiles,'Enable','on');
    guidata(hObject,handles);
end


% --- Executes on button press in btn_LoadFiles.
function btn_LoadFiles_Callback(hObject, eventdata, handles)
% hObject    handle to btn_LoadFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Enable','off');
set(handles.btn_OpenFolder,'Enable','off');
handles.container = CSVDataContainer(handles.folderPath,'*.csv');
set(hObject,'Enable','on');
str = strcat(num2str(handles.container.capacity),32,'folders have been load!');
handles.logger.addString(str);
set(handles.tx_Log,'String',handles.logger.stringContent);
set(handles.btn_ClearAll,'Enable','on');
set(handles.btn_FindPeaks,'Enable','on');
set(handles.ed_Peaks,'Enable','on');
set(handles.ed_Tolerance,'Enable','on');
set(handles.ed_MIR,'Enable','on');
set(handles.ed_MinFit,'Enable','on');
set(handles.btn_ViewResult,'Enable','on');
guidata(hObject,handles);


% --- Executes on button press in btn_ClearAll.
function btn_ClearAll_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ClearAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ed_Peaks,'String','','Enable','off');
set(handles.ed_Tolerance,'String','','Enable','off');
set(handles.ed_MIR,'String','','Enable','off');
set(handles.ed_MinFit,'String','','Enable','off');

set(handles.btn_LoadFiles,'Enable','off');
set(handles.btn_FindPeaks,'Enable','off');
set(handles.btn_ViewResult,'Enable','off');
set(handles.btn_SaveResult,'Enable','off');
set(handles.btn_OpenFolder,'Enable','on');

handles.logger.addString('Clear All data');
set(handles.tx_Log,'String',handles.logger.stringContent);

handles.peaks = [];
handles.tolerance = -1;
handles.MIR = -1;
handles.minFit = -1;

handles.container = [];

set(handles.btn_ClearAll,'Enable','off');
guidata(hObject, handles);



function ed_MinFit_Callback(hObject, eventdata, handles)
% hObject    handle to ed_MinFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.minFit = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ed_MinFit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_MinFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
