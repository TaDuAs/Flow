classdef MockFactory
    %MOCKFACTORY Summary of this class goes here
    %   Detailed explanation goes here
        
    methods (Static)
        function [mock, satelite] = GenerateMock(meta)
            satelite = Simple.UnitTests.MockSatelite(meta);
            mock = satelite.mock;
        end
        
        function matchFound = checkMockedSuperClassList(meta, type)
            if strcmp(meta.Name, type)
                matchFound = true;
                return;
            end
            
            for i = 1:length(meta.SuperclassList)
                base = meta.SuperclassList(i);
                if Simple.UnitTests.MockFactory.checkMockedSuperClassList(base, type)
                    matchFound = true;
                    return;
                end
            end
            
            matchFound = false;
        end
    end
end

