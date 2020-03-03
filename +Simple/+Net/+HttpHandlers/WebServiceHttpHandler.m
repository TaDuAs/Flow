classdef WebServiceHttpHandler < Simple.Net.HttpHandlers.HttpHandler
    %WEBSERVICEHTTPHANDLER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function ismatch = matches(this, request, app)
            ismatch = any(regexp(request.Filename, '^\/?\w+(?:\/\w+)?\/?$'));
        end
        
        function handleRequest(this, request, app)
            serviceUrl=request.Filename;
            response = request.Response;
    
            if ~isempty(serviceUrl) > 0 && serviceUrl(1) == '/'
                serviceUrl = serviceUrl(2:end);
            end
            if ~isempty(serviceUrl) > 0 && serviceUrl(end) == '/'
                serviceUrl = serviceUrl(1:end-1);
            end
            serviceUrlParts = strsplit(serviceUrl, '/');
            
            if length(serviceUrlParts) == 1
                % Handle Service Methods Listing
                foo = @Simple.Net.HttpHandlers.WebServiceHttpHandler.generateControllerMethodsHTML;
                response.write(foo(request, this.getController(request, app, serviceUrlParts{1}), serviceUrlParts{1}));
            elseif length(serviceUrlParts) == 2
                % Invoke service method
                output = this.invokeServiceMethod(request, response, app, serviceUrlParts{1}, serviceUrlParts{2});
                
                response.ContentType='application/xml; charset=UTF-8';
                
                % Wrap response body with SOAPish Simple.Net.Envelope
                responseEnvelope = Simple.Net.Envelope.Response(output);
                response.write(Simple.IO.MXML.toxml(responseEnvelope));
            else
                Simple.Net.HttpServer.RaiseBadHttpHandlerMapping(request, class(this))
            end
        end
    end
    
    methods (Access=private)
        function controller = getController(this, request, app, controllerName)
            try
                controller = app.getController(controllerName);
            catch 
                Simple.Net.HttpServer.RaiseFileNotFoundError(request, ['WebService ' controllerName ' not available']);
            end
        end
        
        function output = invokeServiceMethod(this, request, response, app, serviceName, serviceMethodName)
            % Inspect controller
            controller = this.getController(request, app, serviceName);
            methodMC = this.getServiceMethodDescriptor(controller, serviceMethodName);

            % If method is not available
            if isempty(methodMC)
                Simple.Net.HttpServer.RaiseFileNotFoundError(request, ['WebService method ' serviceName '.' serviceMethodName ' not found']);
            end
            
            % Prepare in/out arguments
            nOutArgs = length(methodMC.OutputNames);
            outArgs = cell(1, nOutArgs);
            inArgs = this.mapMethodArguments(request, methodMC);

            % Invoke controllers method
            [outArgs{:}] = controller.(serviceMethodName)(inArgs{:});
            
            % return output arguments as a struct (which can be serialized
            % easily)
            for oai = 1:nOutArgs
                output.(methodMC.OutputNames{oai}) = outArgs{oai};
            end
        end
        
        function methodMC = getServiceMethodDescriptor(this, controller, serviceMethodName)
            % Gets the method descriptor metaclass for the required service
            % method
            ctrlMC = metaclass(controller);
            methodMC = [];
            for i = 1:length(ctrlMC.Methods)
                currMethodMC = ctrlMC.Methods{i};
                if strcmp(currMethodMC.Name, serviceMethodName)
                    methodMC = currMethodMC;
                    break;
                end
            end
        end
        
        function args = mapMethodArguments(this, request, methodMC)
            %mapMethodArguments Maps all arguments specified in the request either in the
            % query string or as post content to the appropriate method
            % parameters by their names.
            % Returns a cell array with the values of all in arguments
            % expected by the service method. missing parameters are
            % assined empty vectors []
            
            nargs = length(methodMC.InputNames);
            args = cell(1, nargs-1);
            for i = 2:nargs
                % For each method parameter, search it first in post
                % content and second in query string to get the value,
                % otherwise put and empty vector.
                argName = methodMC.InputNames{i};
                args{i-1} = request.get(argName);
            end
        end
    end
    
    methods(Static,Access=private)
        function html = generateControllerMethodsHTML(request, controller, controllerName)

            currentPath = which('Simple.Net.HttpServer');
            currentPath = currentPath(1:find(currentPath=='\',1,'last'));

            % Load html template
            fid = fopen([currentPath 'Templates\ServiceMethodListing.html']);
            html = fread(fid, '*char')';
            fclose(fid);

            % Load html template
            fid = fopen([currentPath 'Templates\ServiceMethodDetails.html']);
            methodHtml = fread(fid, '*char')';
            fclose(fid);

            % Load html template
            fid = fopen([currentPath 'Templates\ServiceMethodParam.html']);
            parameterHtml = fread(fid, '*char')';
            fclose(fid);

            % inspect controller

            controllerMetaClass = metaclass(controller);
            serviceMethods = controllerMetaClass.MethodList;

            % build methods html view
            methodsHtml = '';
            for smi = 1:length(serviceMethods)
                method = serviceMethods(smi);
                if strcmp(method.Name,controllerMetaClass.Name) ||...
                   ~strcmp(method.DefiningClass.Name, controllerMetaClass.Name) ||...
                   ~strcmp(method.Access, 'public') || method.Static || method.Abstract || method.Hidden
                    continue;
                end
                currMethodHTML = strrep(methodHtml, '{ServiceMethodURL}', ...
                    [lower(regexprep(request.Protocol, '\/.*', '')) '://' request.Host '/' controllerName '/' method.Name]);
                currMethodHTML = strrep(currMethodHTML, '{MethodName}', method.Name);

                currMethodParams = '';
                for pii = 2:length(method.InputNames)
                    currMethodParams = [currMethodParams strrep(parameterHtml, '{ParamName}', method.InputNames{pii})];
                end
                currMethodHTML = strrep(currMethodHTML, '{ServiceMethodParameters}', currMethodParams);
                methodsHtml = [methodsHtml, sprintf('\n\r'), currMethodHTML];
            end

            html = strrep(strrep(html, '{ServiceName}', controllerName), '{Methods}', methodsHtml);
        end
    end
end

