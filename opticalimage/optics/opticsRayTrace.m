function oi = opticsRayTrace(scene,oi)
%Ray trace from scene to oi; includes distortion, relative illum and PSF
%
%   oi = opticsRayTrace(scene,oi)
%
% Use ray trace information, say generated by Code V or Zemax lens design
% programs, to compute the optical image irradiance.  See the routines
% rtGeometry and rtApplyPSF for the algorithms applied.
%
% See also:  oiCompute, rtPrecomputePSFApply, rtPrecomputePSF
%
% Example:
%
% Copyright ImagEval Consultants, LLC, 2003.

%% Check parameters

if ieNotDefined('scene'), scene = vcGetObject('scene'); end
if ieNotDefined('oi'),    oi = vcGetObject('oi');       end
if isempty(which('rtRootPath')), error('Ray Trace routines not found on the path.'); end

% Clear out the in window message
app = ieSessionGet('oi window');
ieInWindowMessage('',app);

if isempty(oiGet(oi,'optics rayTrace'))
    % No ray trace data available
    str = 'Use Optics | Import to get ray trace information.';
    ieInWindowMessage(str,handles,3);
    fprintf('%s.  Computation canceled.',str);
    return;
end

% Check that the ray trace data were calculated to a field of view equal or
% greater than the scene fov.
rtFOV = oiGet(oi,'optics rtfov');
% rtFOV    = opticsGet(optics,'rtdiagonalfov');
sceneFOV = sceneGet(scene,'diagonalFieldOfView');
if sceneFOV > rtFOV
    str = sprintf('Scene diag fov (%.0f) exceeds max RT fov (%.0f)',sceneFOV,rtFOV);
    ieInWindowMessage(str,handles,2); 
    fprintf('%s.  Computation canceled.',str);
    return;
end

% Check whether the optics ray trace was calculated for the scene distance
% Check whether the rt calculations and the scene are for the same depth.
sceneDist = sceneGet(scene,'distance');  %m
rtDist    = oiGet(oi,'optics rtObjectDistance','m');
if rtDist ~= sceneDist
    app = sceneWindow;
    delay = 1.5;
    str = sprintf('Scene distance (%.2f m) does not match ray trace assumption (%.2f m)',sceneDist,rtDist);
    ieInWindowMessage(str,app,delay);
    ieInWindowMessage('Adjusting scene distance.',app,delay);
    scene = sceneSet(scene,'distance',rtDist);
    % Update the scene and show it in the window
    ieReplaceObject(scene); 
    sceneWindow; 
end

% The optics must both have the scene wavelength sampling.
oi  = oiSet(oi,'wavelength',sceneGet(scene,'wavelength'));

% Start by assuming the OI hfov matches the scene hfov. Later in the
% computation we account for the oi padding.  This makes sense for a thin
% lens.  Not sure it makes sense for an arbitrary lens.  Checking!
oi = oiSet(oi,'wangular',sceneGet(scene,'wangular'));
%{
 oiGet(oi,'width','um')
 oiGet(oi,'spatial resolution','um')
%}
%% Calculations

% We calculate the ray traced output in the order of 
%  (a) Geometric distortion, 
%  (b) Relative illumination, and 
%  (c) OTF blurring 

% The function rtGeometry converts the scene radiance into optical
% irradiance. It also calculates the geometric distortion and relative
% illumination.
fprintf('Geometric distortion ...');
oi = rtGeometry(oi,scene);
fprintf('\n');
% vcNewGraphWin; oiShowImage(oi);
%{
 oiGet(oi,'width','um')
 oiGet(oi,'width','um')/sceneGet(scene,'width','um')
 oiGet(oi,'spatial resolution','um')
%}

% Pre-compute the OTF
% We need to let the user set the angStep in the interface.  This is a good
% default.
angStep = 10;

% Precompute the sample positions PSFs
% Should this be part of optics or oi?
psfStruct = oiGet(oi,'psfStruct');
if isempty(psfStruct)
    fprintf('Pre-computing PSFs...');
    psfStruct = rtPrecomputePSF(oi,angStep);
    oi = oiSet(oi,'psfStruct',psfStruct);
    fprintf('Done precomputing PSFs.\n');
else
    fprintf('Starting with existing PSFs ...\n');
end
% psfMovie(oiGet(oi,'optics'));

% Apply the OTF to the irrad data.
% Very bad.  This changed the spatial sampling resolution.  Time to
% fix!
fprintf('Applying PSFs.\n');             
oi = rtPrecomputePSFApply(oi);
fprintf('Done applying PSFs.\n');
%{
 oiGet(oi,'width','um')
 oiGet(oi,'width','um')/sceneGet(scene,'width','um')
 oiGet(oi,'spatial resolution','um')
%}

% imageSPD(irrad,550:100:650);

% Do we have an anti-alias filter in place?
switch lower(oiGet(oi,'diffuserMethod'))
    case 'blur'
        blur = oiGet(oi,'diffuserBlur','um');
        if ~isempty(blur), oi = oiDiffuser(oi,blur); end
    case 'birefringent'
        oi = oiBirefringentDiffuser(oi);
    case 'skip'
    otherwise
        error('Unknown diffuser method')
end

% Not sure these should be done here.
[illuminance,meanIlluminance] = oiCalculateIlluminance(oi);

oi = oiSet(oi,'illuminance',illuminance);
oi = oiSet(oi,'meanilluminance',meanIlluminance);

end