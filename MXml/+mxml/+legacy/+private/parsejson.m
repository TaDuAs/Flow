function obj = parsejson(json)
    if any(regexp(json, '^[a-zA-Z]:\\'))
        fname = json;
        fid = fopen(fname);
        json = fread(fid, '*char')';
        fclose(fid);
    end
    element = jsondecode(json);
    obj = mxml.legacy.private.parsejsonElement(element);
end
