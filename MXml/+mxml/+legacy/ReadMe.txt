mxml.legacy package (Matlab-XML) is a standalone package designed for serializing
and deserializing objects(structs\classes) into\from XML\Json files. This format is useful
for transfering a complete object model between Matlab and other working environments,
such as .Net, Java, Javascript, Python, etc.
Parsing DOM objects to structs was taken from:
https://www.mathworks.com/help/matlab/ref/xmlread.html

Author: TADA

***************************************************************************
Main methods:
obj = mxml.legacy.load(filePath, [format]) (format = 'json' or 'xml')
obj = mxml.legacy.load(xmlOrJsonString, format)
mxml.legacy.save(filePath, obj, [format])
mxml.legacy.toxml(obj)
mxml.legacy.tojson(obj)

The load\save\toxml methods have a functionality for saving a data object and a metadata object in the same file.
when saving to/loading from file, format is optional, if format is not specified, it will be decided from the file extension:
.json for json format and anything else for xml format

***************************************************************************
The general format of the generated XML looks like this:
<document type="struct">
<data type="struct">
	<propertyName1 type="propertyType1" [isList="true"]>
		[Content]
	</propertyName1>
	<propertyName2 type="cell" isList="true">
		<entry type="entryType1" [isList="true"]>[Content]</entry>
		<entry type="entryType2" [isList="true"]>[Content]</entry>
		<entry type="entryType3" [isList="true"]>[Content]</entry>
	</propertyName2>
	<propertyName3 type="propertyType3" [isList="true"]>
		[Content]
	</propertyName3>
</data>
</document>

***************************************************************************
The package has a builtin class factory, which instantiates according to class name.

Class factory public static methods:
mxml.legacy.Factory.instance - Class factory singleton instance
mxml.legacy.Factory.terminate - Clears class factory instance from all registered Ctors, Good for when a refresh of the factory is needed
mxml.legacy.Factory.init(factoryInitializer) - Initializes the class factory using a factoryInitializer object which has a method with the signature: initFactory(factory);

Class factory public methods:
addConstructor(this, className, ctorFunction) -
	Adds a ctor for the specified class to the list of ctors
construct(this, className) -
	Invokes the registered ctor of the class with the specified name.
	If no ctor is registered, a default ctor is created dynamically.
	The default ctor invokes the constructor method of the calss and iteratively sets the values of all public proeprties to the values in the XML file
cunstructEmpty(this, className, data) - Used for the construction of an empty object of a specific type
hasCtor(this, className) - Determines whether the speicified class name has a registered ctor
reset(this) - clears all registered ctors. Good for when a refresh of the factory is needed
isempty(this) - true if has no registered ctors, false otherwise.

***************************************************************************
Saving to Json format:
The regular object graph will be stripped of data-types once serialized
to JSON format.
In this implementation primitive types such as numerics, logicals,
char-arrays, do not recieve the added typing convention to minimize the
object graph and the json size. This however removes the type
reversibility of these types, i.e, int and double are treated similarly
thus when parsing back from json, int32 types will be parsed into double
and so on.

for instance:
a = struct('id', '', 'children', struct('name', {'a', 'b'}, 'value', {1, 2}), 'class', someClassDef)

jsonizes into the following object graph:
a = struct('id', ''),...
           'children', struct('type', 'struct', 'isList', true, 'value', [struct('name', 'a', 'value', 1), struct('name', 'b', 'value', 2)],...
           'class', struct('type', 'someClassDef', 'value', struct(all properties of someClassDef))

which in turn is encoded into this json:
{ "id":"",
  "children":{"type":"struct", "isList":true, "value":[{"name":"a", "value":1}, 
                                                       {"name":"b", "value":2}]},
  "class":{"type":"someClassDef", "value":{"prop1":value1,"prop2":value2,...}} }