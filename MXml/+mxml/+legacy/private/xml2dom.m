% Generates a DOM object from an XML string using JAVA XML parser.
% Original code by Yair Altman available at: https://undocumentedmatlab.com/blog/parsing-xml-strings
% Minor revisions by TADA to generate a temp file name using timestamp, at
% the mxml.legacy package folder, in fallback functionality.
function dom = xml2dom(xmlString)
    try
        % The following avoids the need for file I/O:
        inputObject = java.io.StringBufferInputStream(xmlString);  % or: org.xml.sax.InputSource(java.io.StringReader(xmlString))
        try
            % Parse the input data directly using xmlread's core functionality
            parserFactory = javaMethod('newInstance','javax.xml.parsers.DocumentBuilderFactory');
            p = javaMethod('newDocumentBuilder',parserFactory);
            dom = p.parse(inputObject);
        catch
            % Use xmlread's semi-documented inputObject input feature
            dom = xmlread(inputObject);
        end
    catch
        % Fallback to standard xmlread usage, using a temporary XML file:

        % Store the XML data in a temp *.xml file
        mxmlPath = which('mxml.legacy.load');
        mxmlPath = mxmlPath(1:end-6);
        filename = [mxmlPath 'temp_' datestr(now, 'yyyy-mm-dd.HH.MM.SS.FFF') '.xml'];
        fid = fopen(filename,'Wt');
        fwrite(fid,xmlString);
        fclose(fid);

        % Read the file into an XML model object
        dom = xmlread(filename);

        % Delete the temp file
        delete(filename);
    end
end

