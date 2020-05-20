function serializer = generateDefaultSerializer()
    factory = MXML.Factory.instance;
    xmlSerializer = mxml.XmlSerializer('Factory', factory);
    jsonSerializer = mxml.JsonSerializer('Factory', factory);
    serializer = mxml.FileFormatSerializer(["xml", "json"], [xmlSerializer, jsonSerializer]);
end

