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
    
    properties(Dependent)
        minMS1;
        maxMS1;
        maxMS1Intensity;
        minMS2;
        maxMS2;
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
                tmp = CSVData(fPath,obj.fileNames(m).name,50);
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
        
        function minM = get.minMS1(obj)
            L = length(obj.csvMS1DataArray);
            minM = inf;
            for m = 1:1:L
                tmp = min(obj.csvMS1DataArray{m}.mass);
                if tmp < minM
                    minM = tmp;
                end
            end
        end
        
        function maxM = get.maxMS1(obj)
            L = length(obj.csvMS1DataArray);
            maxM = 0;
            for m = 1:1:L
                tmp = max(obj.csvMS1DataArray{m}.mass);
                if tmp > maxM
                    maxM = tmp;
                end
            end
        end
        
        function minM = get.minMS2(obj)
            L = length(obj.csvMS2DataArray);
            minM = inf;
            for m = 1:1:L
                tmp = min(obj.csvMS2DataArray{m}.mass);
                if tmp < minM
                    minM = tmp;
                end
            end
        end
        
        function maxM = get.maxMS2(obj)
            L = length(obj.csvMS2DataArray);
            maxM = 0;
            for m = 1:1:L
                tmp = max(obj.csvMS2DataArray{m}.mass);
                if tmp > maxM
                    maxM = tmp;
                end
            end
        end
        
        function maxI = get.maxMS1Intensity(obj)
            L = length(obj.csvMS1DataArray);
            maxI = 0;
            for m = 1:1:L
                tmp = obj.csvMS1DataArray{m}.maxIntensity;
                if tmp > maxI
                    maxI = tmp;
                end
            end
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
        
        %% getMS1MS2Map
        function [resMat,hf,hm] = plotMS1MS2(obj,threshold,minPW,MS2Ratio,varargin)
           % X : MS1
           % Y : MS2
           hbar = waitbar(0,'Begin Render...');
            if isempty(varargin)
                total = 1000;
            else
                total = varargin{1};
            end
            resMat = zeros(total,total+minPW);
            [ms1,msInts1] = obj.getMS1(0.05);
            hf = figure;
            plot(ms1,msInts1);
            [pkInts,pkLocs,pWs,gridW] = obj.getValidPks(ms1,msInts1,total,'MS1',threshold);
            gridW = max(gridW,minPW);
            MS1C = gridW+1;
            waitbar(0.05,hbar,'Begin Parse MS1');
            for m = 1:1:length(pkLocs)
                [pkM,pkC,pkW] = obj.getPeakMat('MS1',pkLocs(m),pWs(m),total,minPW);
                %disp(strcat(num2str(max(pkM(:))),32,num2str(1000 * pkInts(m)/max(pkInts))));
                %resMat((pkC-pkW):1:(pkC+pkW),((MS1C-pkW):1:(MS1C+pkW))) = max(resMat((pkC-pkW):1:(pkC+pkW),((MS1C-pkW):1:(MS1C+pkW))),pkM * (100 * pkInts(m)/max(pkInts)));
                resMat((pkC-pkW):1:(pkC+pkW),((MS1C-pkW):1:(MS1C+pkW))) = max(resMat((pkC-pkW):1:(pkC+pkW),((MS1C-pkW):1:(MS1C+pkW))),pkM * pkInts(m));
                %resMat((pkC-pkW):1:(pkC+pkW),((MS1C-pkW):1:(MS1C+pkW))) = pkM * (100 * pkInts(m)/max(pkInts));
                if pkInts(m)/max(pkInts) == 1
                    disp('s');
                end
            end
            offset = 2*gridW+1;
            MS2total = total - offset;
            waitbar(0.1,hbar,'Begin Parse MS2');
            for m = 1:1:length(obj.csvMS2DataArray)
                parentMass = obj.csvMS2DataArray{m}.parentMass;
                parentLoc = round(total * (parentMass - obj.minMS1)/(obj.maxMS1 - obj.minMS1));
                try
                    [pkInts,pkLocs,pWs,~] = obj.getValidPks(obj.csvMS2DataArray{m}.mass,...
                                                                obj.csvMS2DataArray{m}.massIntensity,...
                                                                MS2total,'MS2',threshold);
                catch
                    disp(strcat('Ignore:',32,num2str(m)));
                end
                for n = 1:1:length(pkLocs)
                    [pkM,pkC,pkW] = obj.getPeakMat('MS2',pkLocs(n),pWs(n),MS2total,minPW);
                    pkC = pkC + offset;
                    if parentLoc <= pkW
                        %resMat(1:1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))) = ...
                        %resMat(1:1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))) + pkM((pkW-parentLoc+2):end,:) * (100 * pkInts(n)/max(pkInts));
                        %resMat(1:1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))) = ...
                        %max(resMat(1:1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))),pkM((pkW-parentLoc+2):end,:) * (100 * MS2Ratio * pkInts(n)/max(pkInts)));
                        resMat(1:1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))) = ...
                        max(resMat(1:1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))),pkM((pkW-parentLoc+2):end,:) * pkInts(n));
                        %resMat(1:1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))) = pkM((pkW-parentLoc+2):end,:) * (100 * MS2Ratio * pkInts(n)/max(pkInts))*0;
                    else
                        %resMat((parentLoc-pkW):1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))) = ...
                        %resMat((parentLoc-pkW):1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))) + pkM * (100 * pkInts(n)/max(pkInts));
                        %resMat((parentLoc-pkW):1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))) = ...
                        %max(resMat((parentLoc-pkW):1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))),pkM * (100 * MS2Ratio * pkInts(n)/max(pkInts)));
                        resMat((parentLoc-pkW):1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))) = ...
                        max(resMat((parentLoc-pkW):1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))),pkM * pkInts(n));
                        %resMat((parentLoc-pkW):1:(parentLoc+pkW),((pkC-pkW):1:(pkC+pkW))) = pkM * (100 * MS2Ratio * pkInts(n)/max(pkInts))*0;
                    end        
                end
                waitbar(0.1 + 0.8 * m/length(obj.csvMS2DataArray),hbar,'Parsing MS2...');
            end
            
            waitbar(0.9,hbar,'Begin Rendering.');
            
            choice = questdlg('Do you want to save raw image data as file',...
                              'MS Peaker',...
                              'Yes,Please','No,Thanks','No,Thanks');
            if strcmp(choice,'Yes,Please')
                [fn,fp] = uiputfile('*.csv');
                if ischar(fn)
                    csvwrite(strcat(fp,fn),resMat);
                end
            end
            
            xticks = obj.minMS1:(obj.maxMS1 - obj.minMS1)/(total-1):obj.maxMS1;
            yticks = obj.minMS2:(obj.maxMS2 - obj.minMS2)/(total-1):obj.maxMS2;
            
            [X,Y] = meshgrid(xticks,yticks);
            scrsz = get(groot,'ScreenSize');
            h = AdFig1([0,max(max(resMat(1:total,1:total)))]);
            for m = 1:1:length(h.Children)
                if isa(h.Children(m),'matlab.graphics.axis.Axes')
                    hm = surf(h.Children(m),X,Y,resMat(1:total,1:total)','EdgeColor','none');
                end
            end
            colorbar;
            waitbar(1,hbar,'Done!');
            xlim([obj.minMS1,obj.maxMS1]);
            ylim([obj.minMS2,obj.maxMS2]);
            zlim([0,max(max(resMat(1:total,1:total)))])
            xlabel('MS1');
            ylabel('MS2');
            grid on;
            box on;
            close(hbar);
        end
        
        
        function [mass,msInts] = getMS1(obj,threshold,varargin)
            if nargin == 2
                step = 0.01;
            else
                step = varargin{1};
            end
            L = length(obj.csvMS1DataArray);
            mass = obj.minMS1:step:obj.maxMS1;
            msInts = zeros(1,length(mass));
            for m = 1:1:L
                data = obj.csvMS1DataArray{m};
                if data.maxIntensity >= threshold * obj.maxMS1Intensity
                    try
                        tmp = interp1(data.mass,data.massIntensity,mass);
                        tmp(isnan(tmp)) = 0;
                        msInts = msInts + tmp;
                    catch
                    end
                end            
            end
        end
        
        function [mass,msInts] = getNumMS1(obj,threshold,ratio,varargin)
            if nargin == 2
                step = 0.01;
            else
                step = varargin{1};
            end
            L = length(obj.csvMS1DataArray);
            mass = obj.minMS1:step:obj.maxMS1;
            msInts = zeros(1,length(mass));
            for m = 1:1:round(L*ratio)
                data = obj.csvMS1DataArray{m};
                if data.maxIntensity >= threshold * obj.maxMS1Intensity
                    try
                        tmp = interp1(data.mass,data.massIntensity,mass);
                        tmp(isnan(tmp)) = 0;
                        msInts = msInts + tmp;
                    catch
                    end
                end            
            end
        end
    end
    
    methods (Access=private)
        function [peakMat,pRectC,pRectW] = getPeakMat(obj,type,ploc,pwidth,totalRS,minPW)
            if strcmp(type,'MS1')
                minM = obj.minMS1;
                maxM = obj.maxMS1;
            else
                minM = obj.minMS2;
                maxM = obj.maxMS2;
            end
            pRectC = round(totalRS * (ploc - minM)/(maxM - minM));
            pRectW = max(round(totalRS * pwidth/(maxM - minM)),minPW);
            
            [X,Y] = meshgrid(1:(2*pRectW+1),1:(2*pRectW+1));
            tmpCov = (pRectW^2)/(4*log(10));
            peakMat = mvnpdf([X(:),Y(:)],[pRectW+1,pRectW+1],[tmpCov,0;0,tmpCov]); 
            peakMat = peakMat/max(peakMat(:));
            peakMat = reshape(peakMat,size(X));
        end
        function gridWidth = getGridWidth(obj,minM,maxM,locW,totalRS)
            gridWidth = round(totalRS * locW/(maxM - minM));
        end
        function [pkInts,pkLocs,pWs,maxGridW] = getValidPks(obj,mass,massInts,total,type,threshold)
            [pkInts,pkLocs,pWs] = findpeaks(massInts,mass);
            % filter too small noise
            filter = pkInts > (threshold * max(pkInts));
            pkInts = pkInts(filter);
            pkLocs = pkLocs(filter);
            pWs = pWs(filter);
            
            if strcmp(type,'MS1')
                minM = obj.minMS1;
                maxM = obj.maxMS1;
            else
                minM = obj.minMS2;
                maxM = obj.maxMS2;
            end
            
            maxGridW = obj.getGridWidth(minM,maxM,max(pWs),total);
        end
    end
    
end

