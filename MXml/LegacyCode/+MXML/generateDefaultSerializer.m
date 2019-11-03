function serializer = generateDefaultSerializer()
    serializer = mxml.FileFormatSerializer();
    serializer.Formats = ["xml", "json"];
    serializer.Serializers = [mxml.XmlSerializer('Factory', MXML.Factory.instance), mxml.JsonSerializer('Factory', MXML.Factory.instance)];
end

