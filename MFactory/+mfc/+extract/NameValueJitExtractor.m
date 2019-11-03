classdef NameValueJitExtractor < mfc.extract.StructJitExtractor
    methods
        function this = NameValueJitExtractor(args)
            if isrow(args)
                dim = 2;
            else 
                dim = 1;
            end
            if numel(args) > 0
                obj = cell2struct(args(2:2:end), args(1:2:end), dim);
            else
                obj = struct();
            end
            
            this@mfc.extract.StructJitExtractor(obj);
        end
    end
end

