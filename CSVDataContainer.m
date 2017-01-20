classdef CSVDataContainer < handle
    
    properties
        folderPath;
        fileTypeSpecific;
        capacity;
        fileNames;
        csvMS1Indices;
        csvMS2Indices;
        csvMS1DataArray;
        csvMS2DataArray;
    end

    properties (Access = private)
%         fileNames;
%         csvMS1Indices;
%         csvMS2Indices;
%         csvMS1DataArray;
%         csvMS2DataArray;
    end
    
    methods
        function obj = CSVDataContainer(fPath,specific)
            obj.folderPath = fPath;
            obj.fileTypeSpecific = specific;
            obj.fileNames = dir(strcat(obj.folderPath,'/',specific));
            obj.capacity = length(obj.fileNames);
            
            obj.csvMS1Indices = [];
            obj.csvMS2Indices = [];
            obj.csvMS1DataArray = cell(0);
            obj.csvMS2DataArray = cell(0);
            
            h = waitbar(0,'Begin to load...');
            for m = 1:1:obj.capacity
                tmp = CSVData(fPath,obj.fileNames(m).name,0.33);
                if tmp.specularType == MassSpecularType.MS1
                    obj.csvMS1Indices(end+1) = tmp.fileNum;
                    obj.csvMS1DataArray{end+1} = tmp;
                else
                    obj.csvMS2Indices(end+1) = tmp.fileNum;
                    obj.csvMS2DataArray{end+1} = tmp;
                end
                waitbar(m/obj.capacity,h,'Please wait...');
            end 
            close(h);
        end
        
        function csvData = getData(obj,m)
            tryMS1 = (obj.csvMS1Indices == m);
            tryMS2 = (obj.csvMS2Indices == m);
            if sum(tryMS1)
                csvData = obj.csvMS1DataArray{tryMS1};
            else
                csvData = obj.csvMS2DataArray{tryMS2};
            end
        end
        
        function [parentList,IntsMat,getNum] = getDataContains(obj,peaks,tolerance,minRatio,minFit)           
            searchLength = length(obj.csvMS2DataArray);
            
            parentList = zeros(searchLength,1);
            IntsMat = zeros(searchLength,length(peaks));
            getNum = 0;
            
            for m=1:1:searchLength
                [tmpBool,~,tmpPksInts] = obj.csvMS2DataArray{m}.hasPeaks(peaks,tolerance,minRatio,minFit);
                if tmpBool
                    disp(strcat('Find at file:',num2str(obj.csvMS2DataArray{m}.fileNum)));
                    getNum = getNum + 1;
                    parentList(getNum) = obj.csvMS2DataArray{m}.parentMass;
                    IntsMat(getNum,:) = tmpPksInts;
                end
            end
            
            trimHeader = getNum+1;
            parentList(trimHeader:end) = [];
            IntsMat(trimHeader:end,:) = [];
        end
        
        function comb = getTypeData(obj,spec,varargin)
            comb = [];
            if isempty(varargin)
                precision = 0.001;
            else
                precision = varargin{1};
            end
            
            h = waitbar(0,'begin processing...');
            
            if strcmp(spec,'MS1')
                comb = MassPeakCombiner(precision);
                L = length(obj.csvMS1Indices);
                for m = 1:1:L
                    comb.addMassSpec(obj.csvMS1DataArray{m}.mass,obj.csvMS1DataArray{m}.massIntensity);
                    waitbar(m/L,h,'Busy in Parsing Different MS2 data');
                end
            else if strcmp(spec,'MS2')
                    comb = MassPeakCombiner(precision);
                    L = length(obj.csvMS2Indices);
                    for m = 1:1:L
                        comb.addMassSpec(obj.csvMS2DataArray{m}.mass,obj.csvMS2DataArray{m}.massIntensity);
                        waitbar(m/L,h,'Busy in Parsing Different MS2 data');
                    end
                end
            end
            
            close(h);
        end

        %% getParentList: get MS2 data parent List
        function [list] = getParentList(obj)
            L = length(obj.csvMS2Indices);
            list = zeros(L,1);

            for m = 1:1:L
                list(m) = obj.csvMS2DataArray{m}.parentMass;
            end
        end

        %% sortMS2: sort MS2 list by parent mass
        function [] = sortMS2(obj)
            [~,sortBy] = sort(obj.getParentList());
            obj.csvMS2DataArray = obj.csvMS2DataArray(sortBy);
            obj.csvMS2Indices = obj.csvMS2Indices(sortBy);
        end
                
    end
    
    methods (Access=private)
    end
    
end

