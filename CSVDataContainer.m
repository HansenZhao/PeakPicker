classdef CSVDataContainer < handle
    
    properties
        folderPath;
        fileTypeSpecific;
        capacity;
    end

    properties (Access = private)
        fileNames;
        csvMS1Indices;
        csvMS2Indices;
        csvMS1DataArray;
        csvMS2DataArray;
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
                tmp = CSVData(fPath,obj.fileNames(m).name);
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
    end
    
    methods (Access=private)
    end
    
end

