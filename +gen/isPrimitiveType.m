function tf = isPrimitiveType(type)
    mc = meta.class.fromName(type);
    if ~isempty(mc) && (mc.Abstract || mc.Enumeration || mc.HandleCompatible)
        tf = false;
    else
        x = feval([type '.empty']);
        tf = gen.isPrimitiveValue(x);
    end
end