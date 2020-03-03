function [ param] = prepOptionalParams( value, order, sendIfEmpty )
%PREPOPTIONALPARAMS Summary of this function goes here
%   Detailed explanation goes here
    param = struct('value', value, 'order', order, 'sendIfEmpty', sendIfEmpty);
end

