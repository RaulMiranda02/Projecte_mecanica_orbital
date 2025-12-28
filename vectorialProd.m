function c = vectorialProd(a, b)
% Description: function created by us for the computation of a vectorial
% product, strictly for three axis 
%
% Inputs:
%   a       [3x1 vec]
%   b       [3x1 vec]
%
% Outputs:
%   c       [3x1 vec] orthogonal to a and b
%
% Last edited: 28/12/2025 @ 19:20

    c1 = a(2)*b(3)-a(3)*b(2);
    c2 = a(3)*b(1)-a(1)*b(3);
    c3 = a(1)*b(2)-a(2)*b(1);
    
    c = [c1; c2; c3];

end