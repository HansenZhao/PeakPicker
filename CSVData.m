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
            if nargin == 2
                obj = CSVData.parse(varargin{1},varargin{2});
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
                tmp = find(abs(pksLoc - vector(m))<= tolerance);
                if(tmp)
                    b = b+1;
                    loc(m)=pksLoc(tmp);
                    pks(m)=pksInts(tmp);
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
    end

    methods (Static)
         function csvData = parse(folderPath,fileName)
             strArray = split(fileName,'.');
             tmp = strArray(1);
             fileNum = str2num(tmp{1});
             fid = fopen(strcat(folderPath,'/',fileName));
             tmpStr = fgets(fid);
             strArray = split(tmpStr,',');
             time = str2double(strArray{1});
             if strcmp(strArray{4},'MS2')
                 stype = MassSpecularType.MS2;
                 parentMass = str2double(strArray{5});
             else
                 stype = MassSpecularType.MS1;
                 parentMass = 0;
             end
             mass = str2double(split(fgets(fid),','));
             massIntensity = str2double(split(fgets(fid),','));
             maxI = max(massIntensity);
             fclose(fid);
             csvData = CSVData(time,stype,maxI,mass,massIntensity,parentMass,fileNum);
         end       
    end
    
end

