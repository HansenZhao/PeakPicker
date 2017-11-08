function [ mat ] = imagecsv2mat(isPCA)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    if ~exist('isPCA','var')
        isPCA = 0;
    end
    fp = uigetdir();
    if ischar(fp)
        validFile = ls(strcat(fp,'\*.csv'));
        L = size(validFile,1);
        mat = cell(L,1);
        fprintf(1,'Find %d files\n',L);
        for m = 1:1:L
            data = importdata(strcat(fp,'\',strtrim(validFile(m,:))));
            mat{m} = data(:)';
        end
        mat = cell2mat(mat);
        if isPCA > 0
            [~,newVec,weight] = pca(mat);
            weight = weight/sum(weight);
            sumWeight = cumsum(weight);
            newDim = sum(sumWeight<isPCA)+1;
            fprintf(1,'PCA: Select %d dimension for %.3f info\n',newDim,sumWeight(newDim));
            mat = newVec(:,1:newDim);
        end
    else
        mat = 0;
        return;
    end    
end

