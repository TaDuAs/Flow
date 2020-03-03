classdef ImageHttpHandler < Simple.Net.HttpHandlers.FileTypeHttpHandler
    methods(Access=protected)
        
        function ext = supportedFileTypes(this)
            ext = {'bitmap', 'bmp', 'jpg', 'jpeg', 'png', 'gif', 'ico'};
        end
        
        function bool = shouldReadFile(this, request, app)
            bool = true;
        end
        
        function doHandleRequest(this, request, app, file)
            response = request.Response;
            switch (file.extension)
                case 'png'
                    response.ContentType='image/png';
                case {'bmp' 'bitmap'}
                    response.ContentType='image/bmp';
                case {'jpg' 'jpeg'}
                    response.ContentType='image/jpeg';
                case 'gif'
                    response.ContentType='image/gif';
                case 'ico'
                    response.ContentType='image/x-icon';
            end
            
            response.LastModified = file.lastModified;
            response.AcceptRanges = 'bytes';
            
            % Cache for one week
            response.Expires = now + days(365);
            response.CacheControl = ['max-age=' num2str(365*24*60*60)];
            response.Pragma = '';
%             response.ETag = '"948921-15ae-c0dbf340"';
            response.write(file.content);
        end
    end
end

