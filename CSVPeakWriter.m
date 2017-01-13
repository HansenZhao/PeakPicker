classdef CSVPeakWriter
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        targetPeaks;
        tolerance;
        MIR;
        minFit;
        parentList;
        IntsMat;
        filePath;
        fileName;
    end
    
    methods
        function obj = CSVPeakWriter(targetPeaks,tolerance,MIR,minFit,parentList,IntsMat,filePath,fileName)
            obj.targetPeaks = targetPeaks;
            obj.tolerance = tolerance;
            obj.MIR = MIR;
            obj.minFit = minFit;
            obj.parentList = parentList;
            obj.IntsMat = IntsMat;
            obj.filePath = filePath;
            obj.fileName = fileName;           
        end
        
        function [] = write(obj)
            fid = fopen(strcat(obj.filePath,obj.fileName),'w');
            fprintf(fid,'%s\n','Mass Peaker Result');
            obj.writeInfo(fid);
            obj.writeTitle(fid);
            
            len = length(obj.parentList);           
            for m = 1:1:len
                fprintf(fid,'%f',obj.parentList(m));
                fprintf(fid,'%s',',');
                obj.writeDoubleLine(fid,obj.IntsMat(m,:));
            end
            
            fclose(fid);     
        end       
    end
    
    methods (Access = private)
        function [] = writeDoubleLine(obj,id,vec)
            len = length(vec) - 1;
            if len > 0
                for m = 1:1:len
                    fprintf(id,'%f',vec(m));
                    fprintf(id,'%s',',');
                end
                fprintf(id,'%f\n',vec(m+1));
            else if len == 0
                    fprintf(id,'%f\n',vec);
                end
            end
        end
        
        function [] = writeInfo(obj,fid)
            fprintf(fid,'%s','Date,');
            fprintf(fid,'%s\n',date);
            fprintf(fid,'%s','Tolerance,');
            fprintf(fid,'%f\n',obj.tolerance);
            fprintf(fid,'%s','Min Intensity Ratio,');
            fprintf(fid,'%f\n',obj.MIR);
            fprintf(fid,'%s','Min Fit Number,');
            fprintf(fid,'%d\n',obj.minFit);
        end
        function [] = writeTitle(obj,fid)
            fprintf(fid,'%s','Target Mass,');
            obj.writeDoubleLine(fid,obj.targetPeaks);
        end
        
    end
    
end

