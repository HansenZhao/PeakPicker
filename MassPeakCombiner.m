classdef MassPeakCombiner < handle
    
    properties
        capacity;
        precision;
    end
    
    properties (Access = private)
        massList;
        intsMat;
        realSize;
    end
    
    methods
        function obj = MassPeakCombiner(varargin)
            obj.realSize = 0;
            if nargin == 1
                obj.capacity = 0;
                obj.massList = [];
                obj.intsMat = [];   
                obj.precision = varargin{1};
            end
            
            if nargin == 0
                obj.capacity = 0;
                obj.massList = [];
                obj.intsMat = [];   
                obj.precision = 0.01;
            end
            
            if nargin == 3
                obj.capacity = 0;
                obj.precision = varargin{1};
                obj.massList = [];
                obj.intsMat = []; 
                obj.addMassSpec(varargin{2},varargin{3});
            end
        end
        
        function [] = addMassSpec(obj,mass,massInts)
            tmpMassList = [obj.massList;round(mass./obj.precision)*obj.precision];
            tmpMassList = unique(tmpMassList);
                        
            if ~(length(tmpMassList) == length(obj.massList))
                obj.changeMassList(tmpMassList);
            end   
            
            obj.addFineMassInts(interp1(mass,massInts,obj.massList));
        end
        
        function mL = getMassList(obj)
            mL = obj.massList;
        end
        
        function iM = getIntsMat(obj)
            iM = obj.intsMat(1:obj.capacity,:);
        end

        %% getAveInts: get average value in intensity Matrix
        function [vec] = getAveInts(obj)
        	vec = mean(obj.intsMat(1:obj.capacity,:),1);
        end
            
    end
    
    methods (Access = private)
        function [] = addFineMassInts(obj,massInts)
            a = isnan(massInts);
            massInts(a) = 0;
            
            if obj.capacity >= obj.realSize
                if obj.capacity == 0
                    obj.realSize = 5;
                    obj.intsMat = zeros(obj.realSize,length(massInts));
                else
                    obj.realSize = obj.realSize * 2;
                    tmp = zeros(obj.realSize,size(obj.intsMat,2));
                    tmp(1:obj.capacity,:) = obj.intsMat;
                    obj.intsMat = tmp;
                end      
            end
            
            obj.capacity = obj.capacity + 1;
            obj.intsMat(obj.capacity,:) = massInts;
        end
        
        function [] = changeMassList(obj,newList)     
            if obj.capacity > 0
                tmp = zeros(obj.realSize,length(newList));
                newInts = interp1(obj.massList,obj.intsMat(1:obj.capacity,:)',newList);
                tmp(1:obj.capacity,:) = newInts';
                obj.intsMat = tmp;
            end
            obj.massList = newList;
        end
    end
    
end

