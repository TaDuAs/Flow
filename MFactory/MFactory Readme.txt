mfc.MFactory is a class-factory.
mfc.MFactory exposes several APIs to generate class constructors.

* With "Lazy-Load APIs" ctors are generated upon the first request for that class by mfc.MFactory
** With "Eager-Load APIs" ctors are generated actively upon registration. Typically ctors are registered at application startup

1. Class Constructor Registration
    1.1 Ctors can be actively registered programatically using the addConstructor method
        ** Eager-Loaded
    1.2 Classes can implement the descriptor interface (mfc.IDescriptor for handle classes and mfc.IDescriptorStruct for value classes)
        Using the descriptor interface classes can report metadata regarding what information is required by the class ctor
        * Lazy-Loaded
    1.3 Enumeration class ctors are auto-generated such that it is constructed either from
        numeric value (positive/negative integers) or from enumeration names (string/char)
        * Lazy-Loaded
    1.4 Class ctor is generated automatically assuming no values are required by the ctor
        All fields are set using property injection.
        * Lazy-Loaded

2. Class construction - use the construct method

3. Dependency Injection:
    mfc.MFactory can be supplied with an IoC.IContainerGetter to inject constructed instances of classes which implement the 
    class descriptor interface with dependencies from inversion of control container. This is useful when an instance requires 
    a dependency that cannot be constructed by the factory, such as application domain objects, GUI components, etc.

4. Mocking the factory:
    All classes that use the class factory should use the mfc.IFactory interface and not mfc.MFactory class.
    mfc.IFactory is fully abstract and can be mocked fairly easily.
    mfc.MFactory implements the entire mfc.IFactory interface and can be used at runtime as an mfc.IFactory instance.

5. Class descriptor interface parameter rules:
    Extract from fields:
        Parameter name is the name of the property, with or without
        '&' prefix
    Hardcoded string: 
        Parameter starts with a '$' sign. For instance, parameter
        value '$Pikachu' is translated into a parameter value of
        'Pikachu', wheras parameter value '$$Pikachu' will be
        translated into '$Pikachu' when it is sent to the ctor
    Optional ctor parameter (key-value pairs):
        Parameter name starts with '@'
    Get parameter value from dependency injection:
        Parameter name starts with '%'
    
    Example:

classdef DynamicCtorParams < mfc.IDescriptor
    properties (SetObservable)
        child1;
        child2;
        id;
        list;
        didSomething;
    end

    methods % meta dada definition
        function [ctorParams, defaultValues] = getMfcInitializationDescription(~)
            % The pairs of optional parameters will be translated by the factory to key-value parameters.
            % for instance {'@child1', 'child1'} will be translated to {'child1', [the value extracted from the child1 field in the extractor object]}
            ctorParams = {'id', '@child1', 'child1', '@child2', 'child2', '@list', 'list'};

            % The default values of mandatory parameters are denoted as key-value pairs where the name of the dependency is followed by the default value
            % when the ctor will be invoked, id value will be extracted from the extractors 'id' field if it exists, if it doesn't, the default value (here '')
            % will be sent instead.
            defaultValues = {'id', ''};
        end
        
        function this = DynamicCtorParamsModel(id, varargin)
            if nargin < 1; id = []; end
            p = inputParser();
            p.addOptional('child1', []);
            p.addOptional('child2', []);
            p.addOptional('list', []);
            p.parse(varargin{:});
            
            this.id = id;
            this.child1 = p.Results.child1;
            this.child2 = p.Results.child2;
            this.list = p.Results.list;
        end
    end
end

************************************
***** addConstructor overloads *****
************************************
Adds a constructor to generate instances of the type specified by className

addConstructor(factory, className, ctorClass):
  factory   - the mfc.MFactory object
  className - string scalar or character vector containing the
              name of the class to register ctor for
  ctorClass - implements mfc.IMCtor


addConstructor(factory, className, func):
  factory   - the mfc.MFactory object
  className - string scalar or character vector containing the
              name of the class to register ctor for
  func      - function handle with the following symbol:
              function instance = functionName(extractor)
                  where instance is the instance of the class and
                  extractor implements the
                  mfc.extract.IJitPropertyExtractor interface


addConstructor(factory, className, funcName):
  factory   - the mfc.MFactory object
  className - string scalar or character vector containing the
              name of the class to register ctor for
  funcName  - the name of a function with the following symbol:
              function instance = functionName(extractor)
                  where instance is the instance of the class and
                  extractor implements the
                  mfc.extract.IJitPropertyExtractor interface


************************************
******** construct overloads *******
************************************
Creates an instance of the type specified by className

instance = construct(factory, className):
Summary: Constructs the class specified by clssName without setting any of its properties,
         unless default values are described by class descriptor
Input:
    factory   - The mfc.MFactory object
    className - string scalar or character vector containing the
                name of the class to register ctor for


instance = construct(factory, className, extractor):
Summary: Constructs the class specified by clssName setting all property values available in the extractor
Input:
  factory   - the MFactory object
  className - string scalar or character vector containing the
              name of the class to register ctor for
  extractor - implements mfc.extract.IJitPropertyExtractor. Used to extract fields to inject to the class


instance = construct(factory, className, obj):
Summary: Constructs the class specified by clssName cloning all properties from obj
Input:
    factory   - The mfc.MFactory object
    className - string scalar or character vector containing the
                name of the class to register ctor for
    obj       - a struct or object to copy the fields from


instance = construct(factory, className, [name, value]):
Summary: Constructs the class specified by clssName. All properties to copy are sent as name-value pairs
Input:
    factory       - The mfc.MFactory object
    className     - string scalar or character vector containing the
                    name of the class to register ctor for
    [name, value] - a list of name-value pairs specifing the values
                    for the instance proeprties

