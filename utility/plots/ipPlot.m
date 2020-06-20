function [uData, g] = ipPlot(ip,param,xy,varargin)
% Gatway plotting routine for the image processing structure
%
% Syntax
%   [uData, g] = ipPlot(ip,param,varargin)
%
% Brief description
%   Needs comments and updating for the ip plotting gateway.
%
% Inputs
%   ip:
%   param
%      'horizontalline'
%      'roi'
%
%
%   xy
%
%
% Key/val pairs
%
% Returns
%    uData
%    hdl
%
% Copyright Imageval Consulting, LLC 2015
%
% See also
%  ieROIDraw, ieROISelect

%% Decode parameters

% varargin = ieParamFormat(varargin);
uData = [];

if ieNotDefined('ip'), error('ip required.'); end
if ieNotDefined('param'), error('plotting parameter required'); end
if ieNotDefined('xy'), xy = []; end

param    = ieParamFormat(param);

switch param
    case 'horizontalline'
        % Set xy
        plotDisplayLine(ip,'h',xy);
    case 'verticalline'
        plotDisplayLine(ip,'v');
    case 'chromaticity'
        plotDisplayColor(ip,'chromaticity');
    case 'cielab'
        plotDisplayColor(ip,'CIELAB');
    case 'cieluv'
        plotDisplayColor(ip,'CIELUV');
    case 'luminance'
        plotDisplayColor(ip,'luminance');
    case 'rgbhistogram'
        plotDisplayColor(ip,'RGB');
    case 'rgb3d'
        plotDisplayColor(ip,'rgb3d');

    case {'roi'}
        % [uData,g] = ipPlot(ip,'roi');
        %
        % If the roi is a rect, use its values to plot a white rectangle on
        % the sensor image.  The returned graphics object is a rectangle
        % (g) and you can adjust the colors and linewidth using it.
        if isempty(ipGet(ip,'roi'))
            [~,rect] = vcROISelect(ip);
            ip = ipSet(ip,'roi',rect);
        end
        
        % Make sure the sensor window is selected
        ipWindow;
        g = ieROIDraw('ip','shape','rect','shape data',ipGet(ip,'roi'));
                
    otherwise
        error('Uknown parameter %s\n',param);
end


end
