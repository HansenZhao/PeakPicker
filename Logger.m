classdef Logger < handle
    
    properties
        maxLength;
        stringContent;
        curPoint;
    end
    
    methods
        function obj = Logger(maxL,str)   
            obj.maxLength = maxL;
            obj.stringContent = cell(obj.maxLength,1);
            obj.stringContent{1} = str;
            obj.curPoint = 2;
        end
        
        function [] = addString(obj,cont)
            if obj.curPoint > obj.maxLength
                obj.curPoint = obj.maxLength;
                for m = 1:1:(obj.maxLength - 1)
                    obj.stringContent{m} = obj.stringContent{m + 1};
                end
            end
            obj.stringContent{obj.curPoint} = cont;
            obj.curPoint = obj.curPoint + 1;
        end
    end
    
end

