function rgb = sceneShowImage(scene,displayFlag,gam,sceneW)
% Render an image of the scene data from its SPD values
%
% Synopsis
%    rgb = sceneShowImage(scene,displayFlag,gam,sceneW)
%
% Brief description
%  Computes from scene spectral data to an sRGB rendering. Which type of
%  rendering depends on the displayFlag.
%
% Inputs
%  scene:
%  displayFlag:
%     absolute value of 0,1 compute RGB image 
%     absolute value of 2,  compute gray scale for IR
%     absolute value of 3,  HDR rendering method
%
%     If value is zero or negative, do not display, just render the values
%     into the rgb variable that is returned.
%
%  gam:    The gamma value for the rendering
%  sceneW: sceneWindow_App class object
%
% Outputs
%   rgb:   Image for display
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
%   imageSPD

% Examples:
%{
   scene = sceneCreate; sceneWindow(scene);
   rgb = sceneShowImage(scene,-1);    % Compute, but don't show
   ieNewGraphWin; imagescRGB(rgb);    % Now show
%}
%{
   thisW = sceneWindow2;
   sceneShowImage(scene,1,1,thisW);      % Show
%}
%{
   thisW = sceneWindow2;
   im = sceneShowImage(scene,2,1,thisW); % Show gray scale version.
%}
%{
   im = sceneShowImage(scene,2,1);       % Create gray scale version.
%}

%%  Input parameters
if isempty(scene), cla; return;  end

if ieNotDefined('gam'),         gam = 1;         end
if ieNotDefined('displayFlag'), displayFlag = 1; end
if ieNotDefined('sceneW'),      sceneW = [];     end

if ~isempty(sceneW), sceneAxis = sceneW.sceneImage; 
else, sceneAxis = []; end

%%  Get the data
if checkfields(scene,'data','photons')
    % Don't duplicate the data.
    photons = sceneGet(scene,'photons'); 
    wList   = sceneGet(scene,'wavelength');
    sz      = sceneGet(scene,'size');
else
    cla(sceneAxis);
    sprintf('ISET Warning:  Data are not available');
    return;
end
   
%% Display the image in the GUI, or just compute the values

% The absolute value of the displayFlag flag determines how imageSPD
% converts the data into a displayed image.  It is determined from the GUI
% from the app.

% Clearing the axis eliminates any ROI overlays
rgb = imageSPD(photons,wList,gam,sz(1),sz(2),-1*abs(displayFlag),[],[],sceneW);

%% We could add back ROIs/overlays here, if desired.

% If value is positive, display the rendered RGB. If negative, we just
% return the RGB values.
if displayFlag >= 0
    cla(sceneW.sceneImage);  % Should be called imageAxis
    if ieNotDefined('xcoords') || ieNotDefined('ycoords')
        imagescRGB(rgb); axis image; axis off
    else
        % User specified a grid overlay
        rgb = rgb/max(rgb(:));
        rgb = ieClip(rgb,0,[]);
        imagesc(xcoords,ycoords,rgb);
        axis image; grid on;
        set(gca,'xcolor',[.5 .5 .5]);
        set(gca,'ycolor',[.5 .5 .5]);
    end   
end

end
