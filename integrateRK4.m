% function integrateRK4()

% DAVID - Nota: Vídeo bastant útil
% <https://www.bing.com/videos/riverview/relatedvideo?q=4th+order+runge-kutta+method&mid=C06E084B61C37219C7F8C06E084B61C37219C7F8&FORM=VAMTRV>
% De moment està implementat com un programa normal, quan s'hagi provat el
% funcionament ho passem a funció.

% Description: function for the integration of the state using Runge-Kutta
% 4th order explicit method. 
%
% Inputs:
%   in      [6x1 vect] Contains the state vector of start time for a given
%                      satellite, in the TRF reference frame
%       x - position
%       y - position
%       z - position
%       x - acceleration
%       y - acceleration
%       z - acceleration
%
% Outputs:
%   out     [6x1 vect] Same as input, but in the next time t0+delta

%%%%%%%%%%%%%%% PROVISIONALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Paràmetres i constants necessàries (provisionals, falta canviar)
Omega = [0 0 7.292115e-5];    % [rad/s]
acc_TRF = [1; 1; 1];
pos_TRF = [1; 1; 1];

% FUNCIONS del TEMPS i del VECTOR D'ESTAT (provisionals, falta canviar)
time2GMST = @(t) t/(24*3600)*2*pi;

positionTRF2ECI = @(theta) ...
    R3Z(-theta)*pos_TRF;

velocityTRF2ECI = @(theta) ...
    R3Z(-theta)*acc_TRF + vectorialProd(Omega,pos_TRF);


%%%%%%%%%%%%%%%%%% NO PROVISIONALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Function - vector of derivatives
tm = 6*3600;                                % ALERTA valor aleatori de prova
theta = time2GMST(tm);
ym = [positionTRF2ECI(theta);
      velocityTRF2ECI(theta)];

% fFun = @(ym,SM) [...
%         ym(4);
%         ym(5);
%         ym(6);
%         -muE*...      WORK IN PROGRESS :)
%     ];

% 1. Computation of the Sun + Moon accelerations at initial time t0
accSM_ECI = R3Z(-theta)*acc_TRF;


%end