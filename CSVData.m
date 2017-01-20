classdef CSVData < handle
    properties
        collectTime;
        specularType;
        maxIntensity;
        mass;
        massIntensity;
        parentMass;
        fileNum;
    end
    
    methods
        function obj = CSVData(varargin)
            if nargin == 3
                obj = CSVData.parse(varargin{1},varargin{2},varargin{3});
            else if nargin == 7
                    obj.collectTime = varargin{1};
                    obj.specularType = varargin{2};
                    obj.maxIntensity = varargin{3};
                    obj.mass = varargin{4};
                    obj.massIntensity = varargin{5};
                    obj.parentMass = varargin{6};
                    obj.fileNum = varargin{7};
                end
            end
        end
        
        function [b,loc,pks] = hasPeaks(obj,vector,tolerance,minIntensityRatio,varargin)
            [pksInts,pksLoc]=findpeaks(obj.massIntensity);
            pksLoc = obj.mass(pksLoc);
            
            tmp = (pksInts > (obj.maxIntensity * minIntensityRatio));
            pksInts = pksInts(tmp);
            pksLoc = pksLoc(tmp);
            
            tarLength = length(vector);
            b = 0;
            loc=zeros(1,tarLength);
            pks=zeros(1,tarLength);
            
            for m = 1:1:tarLength
                dLoc = abs(pksLoc - vector(m));
                [~,index] = sort(dLoc);
                if dLoc(index(1)) <= tolerance
                    b = b+1;
                    loc(m)=pksLoc(index(1));
                    pks(m)=pksInts(index(1));
                end    
            end
            if isempty(varargin)
                minFitNum = tarLength;
            else
                minFitNum = varargin{1};
            end
            if b>= minFitNum
                b = 1;
            else
                b = 0;
                loc = 0;
                pks = 0;
            end
        end
        
        function [a,b] = getMassRange(obj)
            a = obj.mass(1);
            b = obj.mass(end);
        end
    end

    methods (Static)
         function csvData = parse(folderPath,fileName,minMS2Ratio)
             strArray = split(fileName,'.');
             tmp = strArray(1);
             fileNum = str2num(tmp{1});
             fid = fopen(strcat(folderPath,'/',fileName));
             tmpStr = fgets(fid);
             strArray = split(tmpStr,',');
             time = str2double(strArray{1});
             minMS2 = 0;
             if strcmp(strArray{4},'MS2')
                 stype = MassSpecularType.MS2;
                 parentMass = str2double(strArray{5});
                 if and(minMS2Ratio > 0,minMS2Ratio <= 1)
                     minMS2 = parentMass * minMS2Ratio;
                 else if minMS2Ratio > 1
                         minMS2 = minMS2Ratio;
                     end
                 end
             else
                 stype = MassSpecularType.MS1;
                 parentMass = 0;
             end
             mass = str2double(split(fgets(fid),','));
             massIntensity = str2double(split(fgets(fid),','));
             if stype == MassSpecularType.MS2
                 filter = or(mass < minMS2, mass > parentMass);
                 massIntensity(filter) = [];
                 mass(filter) = [];
             end
             maxI = max(massIntensity);
             fclose(fid);
             csvData = CSVData(time,stype,maxI,mass,massIntensity,parentMass,fileNum);
         end       
    end
    
end

