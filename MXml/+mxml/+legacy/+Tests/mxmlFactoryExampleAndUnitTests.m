import Simple.IO.MXML.*;
import Simple.IO.MXML.Tests.*;
import Simple.UnitTests.*;

obj1_struct = [];
obj1_struct.abc = {'abc', 'xyz', '123'};
obj1_struct.xyz = 1:10;
obj1_struct.inner = obj1_struct;
obj1_struct.mixedCell = {'kmn', 1:10, struct('a', 'a', 'b', 1:3)};

obj1_class1 = Class1('x', 1:10);
obj1_class1.list.set(1:10, 1:10);
obj1_struct_forclass = rmfield(obj1_struct, 'mixedCell');
obj1_class2 = Class2('a', 1:10, obj1_struct_forclass);
obj1_class3 = Class3();
obj1_class3.k = 1:10;
obj1_class3.l = '1:10';
obj1_class3.m.a = 1:3;
obj1_class3.m.b = '^_^';

%----------------------------------------------
% Use class name as string as class identifier
%----------------------------------------------
Factory.instance.addConstructor('Simple.IO.MXML.Tests.Class1', @(data) Class1(data.x,data.y));

%----------------------------------------------
% Use class(instance) as class identifier
%----------------------------------------------
Factory.instance.addConstructor(class(obj1_class2), @(data) Class2(data.a,data.b,data.c));

obj2_class1 = Factory.instance.construct('Simple.IO.MXML.Tests.Class1', struct('x', 'string', 'y', 1:10));
obj2_class2 = Factory.instance.construct('Simple.IO.MXML.Tests.Class2', struct('a', 'string', 'b', 1:10, 'c', []));
obj2_class3 = Factory.instance.construct('Simple.IO.MXML.Tests.Class3', struct('k', 1:10, 'l', '1:10', 'm', struct('a', 1:3, 'b', '^_^')));


test = UnitTesting('Simple.IO.MXML.Factory.addConstructor');

test.checkExpectation('string', obj2_class1.x, 'Simple.IO.MXML.Tests.Class1().x');
test.checkExpectation(1:10, obj2_class1.y, 'Simple.IO.MXML.Tests.Class1().y');
test.checkExpectation('string', obj2_class2.a, 'Simple.IO.MXML.Tests.Class2().a');
test.checkExpectation(1:10, obj2_class2.b, 'Simple.IO.MXML.Tests.Class2().b');
test.checkEmptyExpectation(obj2_class2.c, 'Simple.IO.MXML.Tests.Class2().c');
test.checkExpectation('blah blah blha', obj2_class2.d, 'Simple.IO.MXML.Tests.Class2().d');
test.checkExpectation(1:10, obj2_class3.k, 'Simple.IO.MXML.Tests.Class3().k');
test.checkExpectation('1:10', obj2_class3.l, 'Simple.IO.MXML.Tests.Class3().l');
test.checkExpectation(1:3, obj2_class3.m.a, 'Simple.IO.MXML.Tests.Class3().m.a');
test.checkExpectation('^_^', obj2_class3.m.b, 'Simple.IO.MXML.Tests.Class3().m.b');

test.evaluateAllExpectations();

%----------------------------------------------
% Use factory builer to register all Ctors
%----------------------------------------------
Factory.init(FactoryBuilderTest());

obj3_class1 = Factory.instance.construct('Simple.IO.MXML.Tests.Class1', struct('x', 'string', 'y', 1:10, 'list', IterableImplForTest()));
obj3_class2 = Factory.instance.construct('Simple.IO.MXML.Tests.Class2', struct('a', 'string', 'b', 1:10, 'c', struct('a', 1:3)));

test = UnitTesting('Simple.IO.MXML.Factory.init');

test.checkExpectation('string', obj3_class1.x, 'Simple.IO.MXML.Tests.Class1().x');
test.checkExpectation(1:10, obj3_class1.y, 'Simple.IO.MXML.Tests.Class1().y');
test.checkExpectation('Simple.IO.MXML.Tests.IterableImplForTest', class(obj3_class1.list), 'Simple.IO.MXML.Tests.Class1().list');
test.checkEmptyExpectation(obj3_class1.list.arr, 'Simple.IO.MXML.Tests.Class1().list.arr');
test.checkExpectation('string', obj3_class2.a, 'Simple.IO.MXML.Tests.Class2().a');
test.checkExpectation(1:10, obj3_class2.b, 'Simple.IO.MXML.Tests.Class2().b');
test.checkExpectation(1:3, obj3_class2.c.a, 'Simple.IO.MXML.Tests.Class2().c.a');
test.checkExpectation('blah blah blha', obj3_class2.d, 'Simple.IO.MXML.Tests.Class2().d');

test.evaluateAllExpectations();

thisFolder = which('Simple.IO.MXML.Tests.MXMLFactoryExampleAndUnitTests');
thisFolder = thisFolder(1:find(thisFolder == '\', 1, 'last'));

%----------------------------------------------
% Save to Simple.IO.MXML file
%----------------------------------------------
tic
save([thisFolder 'string.xml'], thisFolder);
save([thisFolder 'obj1_struct.xml'], obj1_struct);
save([thisFolder 'obj1_class1.xml'], obj1_class1);
save([thisFolder 'obj1_class2.xml'], obj1_class2);
save([thisFolder 'obj2_class2.xml'], obj2_class2);
toc

%----------------------------------------------
% Load from Simple.IO.MXML file
%----------------------------------------------
tic
str4 = load([thisFolder 'string.xml']);
obj4_struct = load([thisFolder 'obj1_struct.xml']);
obj4_class1 = load([thisFolder 'obj1_class1.xml']);
obj4_class2 = load([thisFolder 'obj1_class2.xml']);
obj5_class2 = load([thisFolder 'obj2_class2.xml']);
toc

test = UnitTesting('Simple.IO.MXML.save, Simple.IO.MXML.load');

test.checkExpectation(thisFolder, str4, 'Simple.IO.MXML.load(string)');

test.checkExpectation({'abc', 'xyz', '123'}, obj4_struct.abc, 'Simple.IO.MXML.load(struct).abc');
test.checkExpectation(3, length(obj4_struct.mixedCell), 'Simple.IO.MXML.load(struct).mixedCell.length');
test.checkExpectation('kmn', obj4_struct.mixedCell{1}, 'Simple.IO.MXML.load(struct).mixedCell{1}');
test.checkExpectation(1:10, obj4_struct.mixedCell{2}, 'Simple.IO.MXML.load(struct).mixedCell{2}');
test.checkExpectation('a', obj4_struct.mixedCell{3}.a, 'Simple.IO.MXML.load(struct).mixedCell{3}.a');
test.checkExpectation(1:3, obj4_struct.mixedCell{3}.b, 'Simple.IO.MXML.load(struct).mixedCell{3}.b');
test.checkExpectation(1:10, obj4_struct.xyz, 'Simple.IO.MXML.load(struct).xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj4_struct.inner.abc, 'Simple.IO.MXML.load(struct).inner.abc');
test.checkExpectation(1:10, obj4_struct.inner.xyz, 'Simple.IO.MXML.load(struct).inner.xyz');

test.checkExpectation('x', obj4_class1.x, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).x');
test.checkExpectation(1:10, obj4_class1.y, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).y');
test.checkExpectation('Simple.IO.MXML.Tests.IterableImplForTest', class(obj4_class1.list), 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).list.type');
test.checkExpectation(1:10, obj4_class1.list.arr, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).list.arr');

test.checkExpectation('a', obj4_class2.a, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).a');
test.checkExpectation(1:10, obj4_class2.b, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).b');
test.checkExpectation({'abc', 'xyz', '123'}, obj4_class2.c.abc, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.abc');
test.checkExpectation(1:10, obj4_class2.c.xyz, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj4_class2.c.inner.abc, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.inner.abc');
test.checkExpectation(1:10, obj4_class2.c.inner.xyz, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.inner.xyz');
test.checkExpectation('blah blah blha', obj4_class2.d, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).d');

test.checkExpectation('string', obj5_class2.a, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).a');
test.checkExpectation(1:10, obj5_class2.b, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).b');
test.checkEmptyExpectation(obj5_class2.c, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).c');
test.checkExpectation('blah blah blha', obj5_class2.d, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).d');

test.evaluateAllExpectations();


%% --------------------------------------------
% Load from xml string
%----------------------------------------------
filename = [thisFolder 'string.xml'];
fid = fopen(filename);
str6_content = fread(fid, '*char')';
fclose(fid);

filename = [thisFolder 'obj1_struct.xml'];
fid = fopen(filename);
obj6_struct_content = fread(fid, '*char')';
fclose(fid);

filename = [thisFolder 'obj1_class1.xml'];
fid = fopen(filename);
obj6_class1_content = fread(fid, '*char')';
fclose(fid);

filename = [thisFolder 'obj1_class2.xml'];
fid = fopen(filename);
obj6_class2_content = fread(fid, '*char')';
fclose(fid);

filename = [thisFolder 'obj2_class2.xml'];
fid = fopen(filename);
obj7_class2_content = fread(fid, '*char')';
fclose(fid);

tic
str6 = load(str6_content);
obj6_struct = load(obj6_struct_content);
obj6_class1 = load(obj6_class1_content);
obj6_class2 = load(obj6_class2_content);
obj7_class2 = load(obj7_class2_content);

toc

test = UnitTesting('Simple.IO.MXML.load(xml)');

test.checkExpectation(thisFolder, str6, 'Simple.IO.MXML.load(string)');

test.checkExpectation({'abc', 'xyz', '123'}, obj6_struct.abc, 'Simple.IO.MXML.load(struct).abc');
test.checkExpectation(1:10, obj6_struct.xyz, 'Simple.IO.MXML.load(struct).xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj6_struct.inner.abc, 'Simple.IO.MXML.load(struct).inner.abc');
test.checkExpectation(1:10, obj6_struct.inner.xyz, 'Simple.IO.MXML.load(struct).inner.xyz');
test.checkExpectation(3, length(obj6_struct.mixedCell), 'Simple.IO.MXML.load(struct).mixedCell.length');
test.checkExpectation('kmn', obj6_struct.mixedCell{1}, 'Simple.IO.MXML.load(struct).mixedCell{1}');
test.checkExpectation(1:10, obj6_struct.mixedCell{2}, 'Simple.IO.MXML.load(struct).mixedCell{2}');
test.checkExpectation('a', obj6_struct.mixedCell{3}.a, 'Simple.IO.MXML.load(struct).mixedCell{3}.a');
test.checkExpectation(1:3, obj6_struct.mixedCell{3}.b, 'Simple.IO.MXML.load(struct).mixedCell{3}.b');

test.checkExpectation('x', obj6_class1.x, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).x');
test.checkExpectation(1:10, obj6_class1.y, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).y');
test.checkExpectation('Simple.IO.MXML.Tests.IterableImplForTest', class(obj6_class1.list), 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).list.type');
test.checkExpectation(1:10, obj6_class1.list.arr, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).list.arr');

test.checkExpectation('a', obj6_class2.a, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).a');
test.checkExpectation(1:10, obj6_class2.b, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).b');
test.checkExpectation({'abc', 'xyz', '123'}, obj6_class2.c.abc, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.abc');
test.checkExpectation(1:10, obj6_class2.c.xyz, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj6_class2.c.inner.abc, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.inner.abc');
test.checkExpectation(1:10, obj6_class2.c.inner.xyz, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.inner.xyz');
test.checkExpectation('blah blah blha', obj6_class2.d, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).d');

test.checkExpectation('string', obj7_class2.a, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).a');
test.checkExpectation(1:10, obj7_class2.b, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).b');
test.checkEmptyExpectation(obj7_class2.c, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).c');
test.checkExpectation('blah blah blha', obj7_class2.d, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).d');

test.evaluateAllExpectations();


%% --------------------------------------------
% toxml tests
%----------------------------------------------

tic
str6_content2 = toxml(str6);
obj6_struct_content2 = toxml(obj6_struct);
obj6_class1_content2 = toxml(obj6_class1);
obj6_class2_content2 = toxml(obj6_class2);
obj7_class2_content2 = toxml(obj7_class2);
toc

test = UnitTesting('toxml');
test.checkExpectation(char(str6_content), str6_content2, 'toxml(string)');
test.checkExpectation(char(obj6_struct_content), obj6_struct_content2, 'toxml(struct)');
test.checkExpectation(char(obj6_class1_content), obj6_class1_content2, 'toxml(class1)');
test.checkExpectation(char(obj6_class2_content), obj6_class2_content2, 'toxml(class2)');
test.checkExpectation(char(obj7_class2_content), obj7_class2_content2, 'toxml(class2 alternative)');

test.evaluateAllExpectations();


%% --------------------------------------------
% Save\Load big vector
%----------------------------------------------

test = UnitTesting('Big Vector');

x = 1:99999;
tic
save([thisFolder 'bigVector.xml'], x);
toc 

tic
x1 = load([thisFolder 'bigVector.xml']);
toc 

test.checkExpectation(1:99999, x1);
test.evaluateAllExpectations();

%% --------------------------------------------
% Get json from object
%---------------------------------------------- 
obj1_struct_json = tojson(obj1_struct);
obj1_class1_json = tojson(obj1_class1);
obj1_class2_json = tojson(obj1_class2);
obj1_class3_json = tojson(obj1_class3);

test = UnitTesting('Simple.IO.MXML.tojson');

json1 = ['{"type":"struct","value":{"data":{"type":"struct","value":{"abc":["abc","xyz","123"],' ...
                                   '"xyz":[1,2,3,4,5,6,7,8,9,10],'...
                                   '"inner":{"type":"struct","value":{"abc":["abc","xyz","123"],'...
                                                                     '"xyz":[1,2,3,4,5,6,7,8,9,10]}},'...
                                   '"mixedCell":{"type":"cell","isList":true,'...
                                                '"value":["kmn",[1,2,3,4,5,6,7,8,9,10],{"type":"struct","value":{"a":"a","b":[1,2,3]}}]}}}}}'];
test.checkExpectation(json1, regexprep(obj1_struct_json, '\s+', ' '), 'Simple.IO.MXML.tojson(obj1_struct)');
json2 = ['{"type":"struct","value":{"data":{"type":"Simple.IO.MXML.Tests.Class1","value":{"x":"x","y":[1,2,3,4,5,6,7,8,9,10],"list":{"type":"Simple.IO.MXML.Tests.IterableImplForTest","isList":true,"value":[1,2,3,4,5,6,7,8,9,10]}}}}}'];
test.checkExpectation(json2, regexprep(obj1_class1_json, '\s+', ' '), 'Simple.IO.MXML.tojson(obj1_class1)');
json3 = ['{"type":"struct","value":{"data":{"type":"Simple.IO.MXML.Tests.Class2",'...
    '"value":{"a":"a","b":[1,2,3,4,5,6,7,8,9,10],"c":{"type":"struct","value":{"abc":["abc","xyz","123"],' ...
                                  '"xyz":[1,2,3,4,5,6,7,8,9,10],'...
        '"inner":{"type":"struct","value":{"abc":["abc","xyz","123"],'...
                                          '"xyz":[1,2,3,4,5,6,7,8,9,10]}}}},'...
    '"d":"blah blah blha"}}}}'];
test.checkExpectation(json3, regexprep(obj1_class2_json, '\s+', ' '), 'Simple.IO.MXML.tojson(obj1_class2)');
json4 = '{"type":"struct","value":{"data":{"type":"Simple.IO.MXML.Tests.Class3","value":{"k":[1,2,3,4,5,6,7,8,9,10],"l":"1:10","m":{"type":"struct","value":{"a":[1,2,3],"b":"^_^"}}}}}}';
test.checkExpectation(json4, regexprep(obj1_class3_json, '\s+', ' '), 'Simple.IO.MXML.tojson(obj1_class3)');

test.evaluateAllExpectations();

%% --------------------------------------------
% parse json
%---------------------------------------------- 
obj1_struct_fromJson = load(json1, 'json');
obj1_class1_fromJson = load(json2, 'json');
obj1_class2_fromJson = load(json3, 'json');
obj1_class3_fromJson = load(json4, 'json');

test = UnitTesting('Simple.IO.MXML.load(''json'')');

test.checkExpectation({'abc', 'xyz', '123'}, obj1_struct_fromJson.abc, 'Simple.IO.MXML.load(struct).abc');
test.checkExpectation(1:10, obj1_struct_fromJson.xyz, 'Simple.IO.MXML.load(struct).xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj1_struct_fromJson.inner.abc, 'Simple.IO.MXML.load(struct).inner.abc');
test.checkExpectation(1:10, obj1_struct_fromJson.inner.xyz, 'Simple.IO.MXML.load(struct).inner.xyz');
test.checkExpectation(3, length(obj1_struct_fromJson.mixedCell), 'Simple.IO.MXML.load(struct).mixedCell.length');
test.checkExpectation('kmn', obj1_struct_fromJson.mixedCell{1}, 'Simple.IO.MXML.load(struct).mixedCell{1}');
test.checkExpectation(1:10, obj1_struct_fromJson.mixedCell{2}, 'Simple.IO.MXML.load(struct).mixedCell{2}');
test.checkExpectation('a', obj1_struct_fromJson.mixedCell{3}.a, 'Simple.IO.MXML.load(struct).mixedCell{3}.a');
test.checkExpectation(1:3, obj1_struct_fromJson.mixedCell{3}.b, 'Simple.IO.MXML.load(struct).mixedCell{3}.b');

test.checkExpectation('x', obj1_class1_fromJson.x, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).x');
test.checkExpectation(1:10, obj1_class1_fromJson.y, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).y');
test.checkExpectation('Simple.IO.MXML.Tests.IterableImplForTest', class(obj1_class1_fromJson.list), 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).list.type');
test.checkExpectation(1:10, obj1_class1_fromJson.list.arr, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).list.arr');

test.checkExpectation('a', obj1_class2_fromJson.a, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).a');
test.checkExpectation(1:10, obj1_class2_fromJson.b, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).b');
test.checkExpectation({'abc', 'xyz', '123'}, obj1_class2_fromJson.c.abc, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.abc');
test.checkExpectation(1:10, obj1_class2_fromJson.c.xyz, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj1_class2_fromJson.c.inner.abc, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.inner.abc');
test.checkExpectation(1:10, obj1_class2_fromJson.c.inner.xyz, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.inner.xyz');
test.checkExpectation('blah blah blha', obj1_class2_fromJson.d, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).d');

test.checkExpectation('string', obj7_class2.a, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).a');
test.checkExpectation(1:10, obj7_class2.b, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).b');
test.checkEmptyExpectation(obj7_class2.c, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).c');
test.checkExpectation('blah blah blha', obj7_class2.d, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).d');

test.checkExpectation(1:10, obj1_class3_fromJson.k, 'Simple.IO.MXML.Tests.Class3().k');
test.checkExpectation('1:10', obj1_class3_fromJson.l, 'Simple.IO.MXML.Tests.Class3().l');
test.checkExpectation(1:3, obj1_class3_fromJson.m.a, 'Simple.IO.MXML.Tests.Class3().m.a');
test.checkExpectation('^_^', obj1_class3_fromJson.m.b, 'Simple.IO.MXML.Tests.Class3().m.b');

test.evaluateAllExpectations();

%% --------------------------------------------
% Save to Simple.IO.MXML file
%----------------------------------------------
test = UnitTesting('Simple.IO.MXML.save/load json file');

tic
save([thisFolder 'string.json'], thisFolder);
save([thisFolder 'obj1_struct.json'], obj1_struct);
save([thisFolder 'obj1_class1.json'], obj1_class1);
save([thisFolder 'obj1_class2.json'], obj1_class2);
save([thisFolder 'obj1_class3.json'], obj1_class3);
toc

%----------------------------------------------
% Validate file contents
%----------------------------------------------
fid = fopen([thisFolder 'string.json']);
content = fread(fid, '*char')';
fclose(fid);
test.checkExpectation(['{"type":"struct","value":{"data":"' strrep(thisFolder, '\', '\\') '"}}'], content, 'Simple.IO.MXML.Tests.save(string)');

fid = fopen([thisFolder 'obj1_struct.json']);
content = fread(fid, '*char')';
fclose(fid);
test.checkExpectation(json1, content, 'Simple.IO.MXML.Tests.save(string)');

fid = fopen([thisFolder 'obj1_class1.json']);
content = fread(fid, '*char')';
fclose(fid);
test.checkExpectation(json2, content, 'Simple.IO.MXML.Tests.save(string)');

fid = fopen([thisFolder 'obj1_class2.json']);
content = fread(fid, '*char')';
fclose(fid);
test.checkExpectation(json3, content, 'Simple.IO.MXML.Tests.save(string)');

fid = fopen([thisFolder 'obj1_class3.json']);
content = fread(fid, '*char')';
fclose(fid);
test.checkExpectation(json4, content, 'Simple.IO.MXML.Tests.save(string)');

%----------------------------------------------
% Load from Simple.IO.MXML file
%----------------------------------------------
tic
str_fromjson = load([thisFolder 'string.json']);
obj1_struct_fromJson = load([thisFolder 'obj1_struct.json']);
obj1_class1_fromJson = load([thisFolder 'obj1_class1.json']);
obj1_class2_fromJson = load([thisFolder 'obj1_class2.json']);
obj1_class3_fromJson = load([thisFolder 'obj1_class3.json']);
toc



test.checkExpectation(thisFolder, str_fromjson, 'Simple.IO.MXML.load(string)');

test.checkExpectation({'abc', 'xyz', '123'}, obj1_struct_fromJson.abc, 'Simple.IO.MXML.load(struct).abc');
test.checkExpectation(1:10, obj1_struct_fromJson.xyz, 'Simple.IO.MXML.load(struct).xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj1_struct_fromJson.inner.abc, 'Simple.IO.MXML.load(struct).inner.abc');
test.checkExpectation(1:10, obj1_struct_fromJson.inner.xyz, 'Simple.IO.MXML.load(struct).inner.xyz');
test.checkExpectation(3, length(obj1_struct_fromJson.mixedCell), 'Simple.IO.MXML.load(struct).mixedCell.length');
test.checkExpectation('kmn', obj1_struct_fromJson.mixedCell{1}, 'Simple.IO.MXML.load(struct).mixedCell{1}');
test.checkExpectation(1:10, obj1_struct_fromJson.mixedCell{2}, 'Simple.IO.MXML.load(struct).mixedCell{2}');
test.checkExpectation('a', obj1_struct_fromJson.mixedCell{3}.a, 'Simple.IO.MXML.load(struct).mixedCell{3}.a');
test.checkExpectation(1:3, obj1_struct_fromJson.mixedCell{3}.b, 'Simple.IO.MXML.load(struct).mixedCell{3}.b');

test.checkExpectation('x', obj1_class1_fromJson.x, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).x');
test.checkExpectation(1:10, obj1_class1_fromJson.y, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).y');
test.checkExpectation('Simple.IO.MXML.Tests.IterableImplForTest', class(obj1_class1_fromJson.list), 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).list.type');
test.checkExpectation(1:10, obj1_class1_fromJson.list.arr, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class1()).list.arr');

test.checkExpectation('a', obj1_class2_fromJson.a, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).a');
test.checkExpectation(1:10, obj1_class2_fromJson.b, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).b');
test.checkExpectation({'abc', 'xyz', '123'}, obj1_class2_fromJson.c.abc, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.abc');
test.checkExpectation(1:10, obj1_class2_fromJson.c.xyz, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.xyz');
test.checkExpectation({'abc', 'xyz', '123'}, obj1_class2_fromJson.c.inner.abc, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.inner.abc');
test.checkExpectation(1:10, obj1_class2_fromJson.c.inner.xyz, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).c.inner.xyz');
test.checkExpectation('blah blah blha', obj1_class2_fromJson.d, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()).d');

test.checkExpectation('string', obj7_class2.a, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).a');
test.checkExpectation(1:10, obj7_class2.b, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).b');
test.checkEmptyExpectation(obj7_class2.c, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).c');
test.checkExpectation('blah blah blha', obj7_class2.d, 'Simple.IO.MXML.load(Simple.IO.MXML.Tests.Class2()_2).d');

test.checkExpectation(1:10, obj1_class3_fromJson.k, 'Simple.IO.MXML.Tests.Class3().k');
test.checkExpectation('1:10', obj1_class3_fromJson.l, 'Simple.IO.MXML.Tests.Class3().l');
test.checkExpectation(1:3, obj1_class3_fromJson.m.a, 'Simple.IO.MXML.Tests.Class3().m.a');
test.checkExpectation('^_^', obj1_class3_fromJson.m.b, 'Simple.IO.MXML.Tests.Class3().m.b');

test.evaluateAllExpectations();