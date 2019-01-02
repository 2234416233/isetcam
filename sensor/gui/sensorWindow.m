function h = sensorWindow(varargin)
% Show the sensor window allowing to set some of the display fields
%
%  H = SENSORIMAGEWINDOW(varargin)
%
%  This is an interface to sensorImageWindow. If varargin{1} is a
%  sensor, it is added to the ISET database and returns the handle to
%  a new SENSORIMAGEWINDOW or the handle to the existing singleton.
%
% Example:
%   sensorWindow('scale',0);
%   sensorWindow('scale',1);
%   sensorWindow('visible','off');
%
%   figure(h.sensorImageWindow)
%
% (c) Copyright Imageval LLC, 2012
%
% See also
%


% Show the window and get the handle
sensorImageWindow;
h = ieSessionGet('sensor window handle');

if isempty(varargin), return;
elseif isstruct(varargin{1}) && ...
        isfield(varargin{1},'type') && ...
        (strcmp(varargin{1}.type,'sensor'))
    ieAddObject(varargin{1});
    varargin = varargin(2:end);
end

% Start the window and then parse the arguments
% sensorImageWindow;

for ii = 1:2:length(varargin)
    p = ieParamFormat(varargin{ii});
    val = varargin{ii+1};
    switch p
        case 'scale'
            set(h.btnDisplayScale,'Value',val);
        case 'gamma'
            set(h.editGam,'String',num2str(val));
        case 'visible'
            % sensorWindow('visible','on');
            % sensorWindow('visible','off');
            set(h.sensorImageWindow,'visible',val)
        otherwise
            error('Unknown parameter %s\n',p);
    end
end

sensorImageWindow;  % Refreshes the window.

end



