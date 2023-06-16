
function [formattedValue,decimalPoints] = determine_decimal_points(value)

if nargin < 1
    value = 34;
end

magnitude = abs(value);
if magnitude >= 1000
    decimalPoints = 0;  % No decimal points for large values
elseif magnitude >= 10
    decimalPoints = 1;  % One decimal point for medium values
else
    decimalPoints = 2;  % Two decimal points for small values
end

formattedValue = sprintf(['%.' num2str(decimalPoints) 'f'], value);