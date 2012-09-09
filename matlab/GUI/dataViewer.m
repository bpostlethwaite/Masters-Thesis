function varargout = dataViewer(varargin)
%DATAVIEWER M-file for dataViewer.fig
%      DATAVIEWER, by itself, creates a new DATAVIEWER or raises the existing
%      singleton*.
%
%      H = DATAVIEWER returns the handle to a new DATAVIEWER or the handle to
%      the existing singleton*.
%
%      DATAVIEWER('Property','Value',...) creates a new DATAVIEWER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to dataViewer_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      DATAVIEWER('CALLBACK') and DATAVIEWER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DATAVIEWER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dataViewer

% Last Modified by GUIDE v2.5 09-Sep-2012 12:31:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dataViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @dataViewer_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before dataViewer is made visible.
function dataViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

databasedir = '/media/TerraS/database';
handles.stations = {dir([databasedir,'*.mat'])};

% Choose default command line output for dataViewer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dataViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dataViewer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(handles.listbox1,'String',handles.stations,...
    'Value',1)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Viewerbutton.
function Viewerbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Viewerbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
