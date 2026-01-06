function orbit_vis(data)

% --- 2D Ground tracks ---
lat = data.position.elip.lat(:) * 180/pi;
lon = data.position.elip.long(:) * 180/pi;
lon = wrapTo180(lon);

prn = data.PRN(:);
prnList = unique(prn);
nSats = numel(prnList);

cmap = lines(max(7,numel(prnList)));

fig = figure('Name','GLONASS Orbits', 'NumberTitle','off');
ax = axes('Parent', fig);
hold(ax,'on'); box(ax,'on'); grid(ax,'on');
xlabel(ax,'Longitude [deg]'); ylabel(ax,'Latitude [deg]');
title(ax,'GLONASS Ground Tracks (ECEF)');

% Coastline backdrop
try
    S = load('coastlines.mat');            
    plot(ax, S.coastlon, S.coastlat, 'k-'); 
catch ME
    rectangle(ax, 'Position',[-180 -90 360 180],'EdgeColor','k');
    warning("Could not load coastlines.mat: %s", ME.message);
end
xlim(ax, [-180 180]); ylim([-90 90]);

% --- Plot each PRN as a separate line, store handles ---
hLine  = gobjects(nSats,1);
hText  = gobjects(nSats,1);
labels = strings(nSats,1);

for i = 1:nSats
    s = prnList(i);
    I = (prn == s);

    lo = lon(I); la = lat(I);
    [lo2, la2] = break_antimeridian(lo, la);

    col = cmap(mod(i-1,size(cmap,1))+1,:);

    labels(i) = sprintf('PRN%02d', s);
    hLine(i) = plot(ax, lo2, la2, '-', ...
        'LineWidth', 1.2, ...
        'Color', col, ...
        'DisplayName', labels(i));

    idLast = find(I,1,'last');
    hText(i) = text(ax, lon(idLast), lat(idLast), " "+labels(i), ...
        'FontSize', 9, ...
        'FontWeight','bold', ...
        'Color', col, ...
        'Visible', 'on');
    
end

% --- UI controls (listbox + buttons) ---
% Reserve space on the right
ax.Position = [0.07 0.08 0.68 0.85];

panel = uipanel('Parent', fig, 'Units','normalized', 'Position',[0.77 0.08 0.22 0.85], ...
    'Title','Satellites');

uicontrol('Parent', panel, 'Style','text', 'Units','normalized', ...
    'Position',[0.06 0.93 0.88 0.05], ...
    'String',{...
        'Select satellites to SHOW:', ...
        '(Ctrl+LMB to select/deselct multiple)' ...
    }, ...
    'HorizontalAlignment','left');

lb = uicontrol('Parent', panel, 'Style','listbox', 'Units','normalized', ...
    'Position',[0.06 0.28 0.88 0.65], ...
    'String', cellstr(labels), ...
    'Min', 0, 'Max', 2, ...              % enables multi-select
    'Value', 1:nSats, ...                % start with all visible
    'Callback', @onListChange);

btnAll = uicontrol('Parent', panel, 'Style','pushbutton', 'Units','normalized', ...
    'Position',[0.06 0.18 0.42 0.07], ...
    'String','Select all', 'Callback', @onSelectAll);

btnNone = uicontrol('Parent', panel, 'Style','pushbutton', 'Units','normalized', ...
    'Position',[0.52 0.18 0.42 0.07], ...
    'String','Deselect all', 'Callback', @onDeselectAll);

cbLabels = uicontrol('Parent', panel, 'Style','checkbox', 'Units','normalized', ...
    'Position',[0.06 0.10 0.88 0.06], ...
    'String','Show PRN labels', ...
    'Value', 0, ...
    'Callback', @onToggleLabels);

btnLegend = uicontrol('Parent', panel, 'Style','pushbutton', 'Units','normalized', ...
    'Position',[0.06 0.02 0.88 0.07], ...
    'String','Toggle legend', 'Callback', @onToggleLegend);

% Optional legend off by default
leg = [];
legendVisible = false;

% Apply initial visibility (all visible)
applyVisibility(1:nSats);

% ---------------- nested callbacks ----------------
    function onListChange(~, ~)
        sel = lb.Value;                 % indices to SHOW
        applyVisibility(sel);
    end

    function onSelectAll(~, ~)
        lb.Value = 1:nSats;
        applyVisibility(1:nSats);
    end

    function onDeselectAll(~, ~)
        lb.Value = [];
        applyVisibility([]);
    end

    function onToggleLabels(~, ~)
        applyVisibility(lb.Value);
    end

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
            if show(ii)
                hLine(ii).Visible = 'on';
            else
                hLine(ii).Visible = 'off';
            end

            if isgraphics(hText(ii))
                if cbLabels.Value == 1 && show(ii)
                    hText(ii).Visible = 'on';
                else
                    hText(ii).Visible = 'off';
                end
            end
        end
        drawnow limitrate;
    end

end
