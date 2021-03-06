function [root, xml] = genCompatibilityDOM()
    xml = ['<?xml version="1.0" encoding="utf-8"?>', newline(),... 
       '<document type="mxml.tests.HandleModel">', newline(),...
       '    <id type="char">myId</id>', newline(),...
       '    <child1 type="double">123</child1>', newline(),...
       '    <child2 type="mxml.tests.HandleModel" id="123" child1="my son">', newline(),...
       '        <child2 type="logical">true</child2>', newline(),...
       '        <list type="int32">1 2 3 4 5</list>', newline(),...
       '    </child2>', newline(),...
       '    <list type="mxml.tests.HandleModel" isList="true">', newline(),...
       '        <entry type="mxml.tests.HandleModel">', newline(),...
       '            <id type="double">1</id>', newline(),...
       '            <child1 type="string">The quick brown fox</child1>', newline(),...
       '            <list type="int32">1 2 3 4 5</list>', newline(),...
       '        </entry>', newline(),...
       '        <entry type="mxml.tests.HandleModel">', newline(),...
       '            <id type="double">2</id>', newline(),...
       '            <child1 type="string">Jumps over the lazy dog</child1>', newline(),...
       '            <list type="single">1 2 3 4 5; 6 7 8 9 10</list>', newline(),...
       '        </entry>', newline(),...
       '    </list>', newline(),...
       '</document>'];
    
   root = mxml.tests.genDOM(xml);
end