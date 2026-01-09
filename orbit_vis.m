function orbit_vis(data)
%ORBIT_VIS
% - If ECI not present: 2D ECEF ground tracks.
% - If ECI present:     2D ground tracks from ECI + 3D ECI orbits.
%
% Interactive PRN selection + select/deselect all + label toggle (separate UI per fig).

hasECI = isfield(data,'eci') && isfield(data.eci,'position') && ...
         all(isfield(data.eci.position, {'x','y','z'}));

prn = data.PRN(:);
prnList = unique(prn);
nSats = numel(prnList);
cmap = lines(nSats);

labels = strings(nSats,1);
for i=1:nSats
    labels(i) = sprintf('PRN%02d', prnList(i));
end

% ======================================================================
% MODE A: No ECI -> 2D ground tracks (ECEF)
% ======================================================================
if ~hasECI
    if ~isfield(data,'position') || ~isfield(data.position,'elip') || ...
       ~isfield(data.position.elip,'lat') || ~isfield(data.position.elip,'long')
        error("orbit_vis: elip not found. Run cart2elip(data) first so data.position.elip.lat/long exist.");
    end

    lat = data.position.elip.lat(:)  * 180/pi;
    lon = data.position.elip.long(:) * 180/pi;

    fig = figure('Name','GLONASS Ground Tracks (ECEF)', 'NumberTitle','off');
    ax  = axes('Parent', fig);
    hold(ax,'on'); box(ax,'on'); grid(ax,'on');
    xlabel(ax,'Longitude [deg]'); ylabel(ax,'Latitude [deg]');
    title(ax,'GLONASS Ground Tracks (ECEF)');

    try
        S = load('coastlines.mat');
        plot(ax, S.coastlon, S.coastlat, 'k-','HandleVisibility','off');
    catch ME
        rectangle(ax, 'Position',[-180 -90 360 180],'EdgeColor','k');
        warning("Could not load coastlines.mat: %s", ME.message);
    end
    xlim(ax, [-180 180]); ylim(ax, [-90 90]);

    hLine = gobjects(nSats,1);
    hText = gobjects(nSats,1);

    for i = 1:nSats
        s = prnList(i);
        I = (prn == s);
        col = cmap(mod(i-1,size(cmap,1))+1,:);

        [lo2, la2] = break_antimeridian(lon(I), lat(I));
        hLine(i) = plot(ax, lo2, la2, '-', 'LineWidth',1.2, 'Color',col, 'DisplayName',labels(i));

        idLast = find(I,1,'last');
        hText(i) = text(ax, lon(idLast), lat(idLast), " "+labels(i), ...
            'FontSize',9,'FontWeight','bold','Color',col,'Visible','off');
    end

    add_selector_ui(fig, ax, labels, hLine, hText);
    return;
end

% ======================================================================
% MODE B: ECI present -> 2D ground tracks + 3D ECI orbits
% ======================================================================
xI = data.eci.position.x(:);
yI = data.eci.position.y(:);
zI = data.eci.position.z(:);

% ---------- 2D ground tracks ----------
hasEciElip = isfield(data.eci.position,'elip') && ...
             isfield(data.eci.position.elip,'lat') && isfield(data.eci.position.elip,'long');

if hasEciElip
    latF = data.eci.position.elip.lat(:)  * 180/pi;
    lonF = data.eci.position.elip.long(:) * 180/pi;
else
    error("orbit_vis: elip not found. Run cart2elip(data.eci) first so data.eci.position.elip.lat/long exist.");
end

fig2D = figure('Name','ECI Ground Tracks', 'NumberTitle','off');
ax2D  = axes('Parent', fig2D);
hold(ax2D,'on'); box(ax2D,'on'); grid(ax2D,'on');
xlabel(ax2D,'Longitude [deg]'); ylabel(ax2D,'Latitude [deg]');
title(ax2D,'ECI Ground Tracks');

try
    S = load('coastlines.mat');
    plot(ax2D, S.coastlon, S.coastlat, 'k-','HandleVisibility','off');
catch ME
    rectangle(ax2D, 'Position',[-180 -90 360 180],'EdgeColor','k');
    warning("Could not load coastlines.mat: %s", ME.message);
end
xlim(ax2D, [-180 180]); ylim(ax2D, [-90 90]);

hLine2D = gobjects(nSats,1);
hText2D = gobjects(nSats,1);

for i = 1:nSats
    s = prnList(i);
    I = (prn == s);
    col = cmap(mod(i-1,size(cmap,1))+1,:);

    [lo2, la2] = break_antimeridian(lonF(I), latF(I));
    hLine2D(i) = plot(ax2D, lo2, la2, '-', 'LineWidth',1.2, 'Color',col, 'DisplayName',labels(i));

    idLast = find(I,1,'last');
    hText2D(i) = text(ax2D, lonF(idLast), latF(idLast), " "+labels(i), ...
        'FontSize',9,'FontWeight','bold','Color',col,'Visible','off');
end

add_selector_ui(fig2D, ax2D, labels, hLine2D, hText2D);

% ---------- 3D ECI orbits ----------
fig3D = figure('Name','GLONASS Orbits 3D (ECI)', 'NumberTitle','off');
ax3D  = axes('Parent', fig3D);
hold(ax3D,'on'); box(ax3D,'on'); grid(ax3D,'on'); axis(ax3D,'equal');
xlabel(ax3D,'X [km]'); ylabel(ax3D,'Y [km]'); zlabel(ax3D,'Z [km]');
title(ax3D,'GLONASS Orbits (ECI)');

% --- Earth sphere with texture ---
Re = 6378.137;  % km

[XS,YS,ZS] = sphere(2000);
earthImg = imread('earth_texture.jpg');

surf(ax3D, Re*XS, Re*YS, Re*ZS, ...
    'FaceColor','texturemap', ...
    'EdgeColor','none', ...
    'CData', flipud(earthImg));

camlight(ax3D,'headlight');
lighting(ax3D,'gouraud');
material(ax3D,'dull');
view(ax3D, 35, 20);

hLine3D = gobjects(nSats,1);
hText3D = gobjects(nSats,1);

for i = 1:nSats
    s = prnList(i);
    I = (prn == s);
    col = cmap(mod(i-1,size(cmap,1))+1,:);

    hLine3D(i) = plot3(ax3D, xI(I), yI(I), zI(I), '-', ...
        'LineWidth',1.4, 'Color',col, 'DisplayName',labels(i));

    idLast = find(I,1,'last');
    hText3D(i) = text(ax3D, xI(idLast), yI(idLast), zI(idLast), " "+labels(i), ...
        'FontSize',9,'FontWeight','bold','Color',col,'Visible','off');
end

add_selector_ui(fig3D, ax3D, labels, hLine3D, hText3D);

end


% ======================================================================
% UI helper: adds the selector panel to any figure and controls line/text
% ======================================================================
function add_selector_ui(fig, ax, labels, hLine, hText)

nSats = numel(hLine);

% Reserve figure space
ax.Position = [0.07 0.08 0.68 0.85];

panel = uipanel('Parent', fig, 'Units','normalized', 'Position',[0.77 0.08 0.22 0.85], ...
    'Title','Satellites');

uicontrol('Parent', panel, 'Style','text', 'Units','normalized', ...
    'Position',[0.06 0.92 0.88 0.08], ...
    'String',{...
        'Select satellites to SHOW:', ...
        '(Ctrl+LMB to select/deselect multiple)' ...
    }, ...
    'HorizontalAlignment','left');

lb = uicontrol('Parent', panel, 'Style','listbox', 'Units','normalized', ...
    'Position',[0.06 0.28 0.88 0.64], ...
    'String', cellstr(labels), ...
    'Min', 0, 'Max', 2, ...
    'Value', 1:nSats, ...
    'Callback', @onListChange);

uicontrol('Parent', panel, 'Style','pushbutton', 'Units','normalized', ...
    'Position',[0.06 0.18 0.42 0.07], ...
    'String','Select all', 'Callback', @onSelectAll);

uicontrol('Parent', panel, 'Style','pushbutton', 'Units','normalized', ...
    'Position',[0.52 0.18 0.42 0.07], ...
    'String','Deselect all', 'Callback', @onDeselectAll);

cbLabels = uicontrol('Parent', panel, 'Style','checkbox', 'Units','normalized', ...
    'Position',[0.06 0.10 0.88 0.06], ...
    'String','Show PRN labels', ...
    'Value', 0, ...
    'Callback', @onToggleLabels);

btnLegend = uicontrol('Parent', panel, 'Style','pushbutton', 'Units','normalized', ...
    'Position',[0.06 0.03 0.88 0.06], ...
    'String','Toggle legend', 'Callback', @onToggleLegend);

leg = [];
legendVisible = false;

applyVisibility(1:nSats);

    function onListChange(~, ~), applyVisibility(lb.Value); end
    function onSelectAll(~, ~), lb.Value = 1:nSats; applyVisibility(1:nSats); end
    function onDeselectAll(~, ~), lb.Value = []; applyVisibility([]); end
    function onToggleLabels(~, ~), applyVisibility(lb.Value); end

    function onToggleLegend(~, ~)
        if ~legendVisible
            leg = legend(ax, 'Location','eastoutside');
            legendVisible = true;
        else
            if isgraphics(leg), delete(leg); end
            legendVisible = false;
        end
    end

    function applyVisibility(sel)
        show = false(nSats,1);
        show(sel) = true;

        for ii = 1:nSats
            hLine(ii).Visible = onoff(show(ii));
            if cbLabels.Value == 1 && show(ii)
                hText(ii).Visible = 'on';
            else
                hText(ii).Visible = 'off';
            end
        end
        drawnow limitrate;
    end
end

function s = onoff(tf)
if tf, s='on'; else, s='off'; end
end
