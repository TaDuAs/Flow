MXML package (Matlab-XML) is a package for serializing/deserializing complete object graphs into text files
MXML supports XML and Json formats. The formatted text maintains Matlab types after deserialization.
MXML is useful for transfering a complete object model between Matlab and other working environments,
such as .Net, Java, Javascript, Python, etc.

Version 3.0 was a complete remake of the package and the API was reworked entirely from static classes to OOP serializer objects
Version 3.0 deserialization has improved performace compared to version 2.0 and is roughly 3 times faster.
Version 2.0 API is still available at the MXML (capital letters) package with the original (see MXml/LegacyCode/ReadMe.txt for details)
Version 3.0 uses the MFactory tool (mfc package) for class creation and the Collections package (lists package) for abstraction of list classes.

Current version: 3.0
Author: TADA, 2019

***************************************************************************
The API is OOP, and uses serializer objects which implement the mxml.ISerializer:
mxml.XmlSerializer
mxml.JsonSerializer

The mxml.ISerializer interface has 4 methods:
save(this, object, filePath); - serialize object and save to text file
object = load(this, filePath); - load data from text file and deserialize into a Matlab object
text = serialize(this, object); - serialize object into formatted text
object = deserialize(this, text); - deserialize formatted text into a Matlab object

***************************************************************************
The general format of the generated XML looks like this:
<document _type="struct">
	<propertyName1 _type="propertyType1" [_isList="true"] textProperty="your text goes here" anotherTextProperty="something else">
		[Content]
	</propertyName1>
	<propertyName2 _type="cell" _isList="true">
		<_entry _type="entryType1" [_isList="true"]>[Content]</_entry>
		<_entry _type="entryType2" [_isList="true"]>[Content]</_entry>
		<_entry _type="entryType3" [_isList="true"]>[Content]</_entry>
	</propertyName2>
	<propertyName3 _type="propertyType3" [_isList="true"]>
		[Content]
	</propertyName3>
</document>

supported object types:
Matlab classes and class arrays (no matrix support)
structs and struct arrays (no matrix support)
All numeric types and logicals (as scalars/vectors/matrices)
All text types (string/char/cellstr)
cell arrays (no matrix support)


***************************************************************************
The package uses mfc.MFactory for creation of class instances, (see MFactory/MFactory Readme.txt for details).

The mfc.MFactory supports extraction of data for construction of class instance using the mfc.extract.IJitPropertyExtractor API.
mxml package implements this API using the mxml.XmlFieldExtractor and mxml.JsonFieldExtractor classes

The mxml.XmlSerializer uses a dedicated FieldExtractor factory classes which implement the mxml.IFieldExtractorBuilder to generate field extractors
by default mxml.XmlSerializer uses mxml.XmlFieldExtractorBuilder to generate these field extractors

At the moment mxml.JsonSerializer is strongly coupled with the mxml.JsonFieldExtractor class, but in a future release will also use a dedicated factory class
in order to decouple these.

***************************************************************************
Saving to Json format:
The regular object graph will be stripped of data-types once serialized
to JSON format.
In this implementation primitive types such as numerics, logicals,
char-arrays, do not recieve the added typing convention to minimize the
output json size. This however removes the type
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