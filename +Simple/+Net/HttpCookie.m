classdef HttpCookie
    properties
        name;
        value;
        expires;
        domain;
        secure;
        httpOnly;
    end
    
    methods
        function this = HttpCookie(name, value)
            this.name = name;
            this.value = value;
        end
        
        function text = toString(this)
            text = [this.name '=' this.value '; '];
            if ~isempty(this.expires)
                text = [text 'Expires=' Simple.getDateTimeString(this.expires, 'eeee, dd MMM yyyy HH:mm:SS Z', 'local') '; '];
            end
            if ~isempty(this.domain)
                text = [text 'Domain=' this.domain '; '];
            end
            if ~isempty(this.secure) && this.secure
                text = [text 'Secure; '];
            end
            if ~isempty(this.httpOnly) && this.httpOnly
                text = [text 'HttpOnly; '];
            end
        end
    end
end

