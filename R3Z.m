function rotMatrix = R3Z(theta)
% Description: function created by us for the computation of a rotation
% matrix about Z, strictly for three axis 
%
% Input:
%   theta       [rad]
%
% Outputs:
%   rotMatrix   [3x3 array]
%
% Last edited: 28/12/2025 @ 19:20

    rotMatrix = [ ...
        cos(theta), -sin(theta), 0;
        sin(theta), cos(theta), 0;
        0, 0, 1];
end