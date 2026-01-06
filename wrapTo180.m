function lon = wrapTo180(lon)

lon =  mod(lon+180, 360) -180;

end