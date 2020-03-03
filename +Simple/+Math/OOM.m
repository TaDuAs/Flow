classdef OOM < double
   enumeration
       Yocto    (-24),
       Zepto    (-21),
       Atto     (-18),
       Femto    (-15),
       Pico     (-12),
       Nano     (-9),
       Micro    (-6),
       Mili     (-3),
       Centi    (-2),
       Deci     (-1),
       Normal   (0),
       Deca     (1),
       Hecto    (2),
       Kilo     (3),
       Mega     (6),
       Giga     (9),
       Tera     (12),
       Peta     (15),
       Exa      (18),
       Zetta    (21),
       Yotta    (24)
   end
   
   methods (Static)
       function map = oomPrefixMapping()
           map = {Simple.Math.OOM.Yocto, 'y';...
                  Simple.Math.OOM.Zepto, 'z';...
                  Simple.Math.OOM.Atto, 'a';...
                  Simple.Math.OOM.Femto, 'f';...
                  Simple.Math.OOM.Pico, 'p';...
                  Simple.Math.OOM.Nano, 'n';...
                  Simple.Math.OOM.Micro, 'µ';...
                  Simple.Math.OOM.Mili, 'm';...
                  Simple.Math.OOM.Centi, 'c';...
                  Simple.Math.OOM.Deci, 'd';...
                  Simple.Math.OOM.Normal, '';...
                  Simple.Math.OOM.Deca, 'da';...
                  Simple.Math.OOM.Hecto, 'h';...
                  Simple.Math.OOM.Kilo, 'k';...
                  Simple.Math.OOM.Mega, 'M';...
                  Simple.Math.OOM.Giga, 'G';...
                  Simple.Math.OOM.Tera, 'T';...
                  Simple.Math.OOM.Peta, 'P';...
                  Simple.Math.OOM.Exa, 'E';...
                  Simple.Math.OOM.Zetta, 'Z';...
                  Simple.Math.OOM.Yotta, 'Y'};
       end
       
       function oom = fromPrefix(prefix)
           import Simple.Math.OOM;
           map = OOM.oomPrefixMapping();
           mask = cellfun(@(p) strcmp(p, prefix), map(:,2));
           oom = map{mask,1};
       end
       
       % Generates the relevant order of magnitude enumeration from a
       % specified number.
       % Varriables:
       %    value: generates the OOM of this number
       %    [only3Fold]: Optional. If specified determines whether to
       %                 ignore non 3-fold OOMs (Centi, Deci, Deca, Hecto)
       % Returns:
       %    The OOM of value, for instance 1000->Kilo, 10^-9->Nano
       function oom = fromNumber(value, only3Fold)
           import Simple.Math.*;
           x = doom(value);
           
           if x < OOM.Zepto
               oom = OOM.Yocto;
           elseif x < OOM.Atto
               oom = OOM.Zepto;
           elseif x < OOM.Femto
               oom = OOM.Atto;
           elseif x < OOM.Pico
               oom = OOM.Femto;
           elseif x < OOM.Nano
               oom = OOM.Pico;
           elseif x < OOM.Micro
               oom = OOM.Nano;
           elseif x < OOM.Mili
               oom = OOM.Micro;
           elseif x < OOM.Centi
               oom = OOM.Mili;
           elseif x < OOM.Deci
               if nargin >= 2 && only3Fold
                   oom = OOM.Mili;
               else
                   oom = OOM.Centi;
               end
           elseif x < OOM.Normal
               if nargin >= 2 && only3Fold
                   oom = OOM.Mili;
               else
                   oom = OOM.Deci;
               end
           elseif x < OOM.Deca
               oom = OOM.Normal;
           elseif x < OOM.Hecto
               if nargin >= 2 && only3Fold
                   oom = OOM.Normal;
               else
                   oom = OOM.Deca;
               end
           elseif x < OOM.Kilo
               if nargin >= 2 && only3Fold
                   oom = OOM.Normal;
               else
                   oom = OOM.Hecto;
               end
           elseif x < OOM.Mega
               oom = OOM.Kilo;
           elseif x < OOM.Giga
               oom = OOM.Mega;
           elseif x < OOM.Tera
               oom = OOM.Giga;
           elseif x < OOM.Peta
               oom = OOM.Tera;
           elseif x < OOM.Exa
               oom = OOM.Peta;
           elseif x < OOM.Zetta
               oom = OOM.Exa;
           elseif x < OOM.Yotta
               oom = OOM.Zetta;
           else
               oom = OOM.Yotta;
           end
       end
   end
   
   methods
       % Returns the textual prefix for physical units
       %    Example: Kilo = k, in kilogram = kg
       function prefix = getPrefix(oom)
           import Simple.Math.OOM;
           map = OOM.oomPrefixMapping();
           mask = cellfun(@(x) x == oom, map(:,1));
           prefix = map{mask,2};
       end
   end
end