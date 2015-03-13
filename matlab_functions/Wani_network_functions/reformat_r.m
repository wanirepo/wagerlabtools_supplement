function r = reformat_r(r, n, type)

% function r = reformat_r(r, n_size, type)
%
% r = n x n matrix
% n_size: network size (n)
% type: 
%    1: flatten
%    2: reconstruct
%    3: remove diagonal
%    4: make it symmetric

switch type
    case 1
        r = r(triu(true(n,n),1));
    case 2
        rr = zeros(n,n);
        rr(triu(true(n,n),1)) = r;
        r = rr + rr';
    case 3
        r(logical(eye(n))) = 0;
    case 4
        r = (r + r')./2;
end

end