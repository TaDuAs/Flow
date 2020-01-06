lists package contains several collection interfaces for collection classes and some implementations

***************************************************************************
APIs
***************************************************************************
lists.ICollection < handle
Summary:
A generic collection interface including several methods:

Indexing Methods:
value = getv(this, i)
Summary: Get value/s from collection in the ith index\index list

setv(this, i, value)
Summary: Set value/s in the collection, in the ith index/index list 

removeAt(this, i)
Summary: Remove value/s from collection at the ith index/index list

add(this, value)
Summary: Add value to collection

setVector(this, vector)
Summary: Replace the collection contents with a new collection


Size Polling Methods:
n = length(this)
Summary: Gets the length of the collection

b = isempty(this)
Summary: Determines whether the collection is empty

s = size(this, [dim])
Summary: Determines the size of the collection at the specified dimention


***************************************************************************
lists.IObservable < lists.ICollection
Summary:
An observable lists.ICollection. On top of the general lists.ICollection api,
it includes methods for getting available keys/indices and the collectionChanged event

Key Polling Methods:
b = containsIndex(this, i)
Summary: Determines whther the collection contains the index/key specified by i

keySet = keys(this);
Summary: Gets the full list of indices/key in the collection

Events:
collectionChanged
Summary: Raised when the collection is changed
See Also: lists.CollectionChangedEventData

***************************************************************************
Class List
***************************************************************************
lists.Map < lists.IObservable
Summary: This class is a wrapper for containers.Map which implements the 
lists.IObservable and lists.ICollection interfaces.

lists.ObservableArray < lists.IObservable
Summary: This class is a wrapper for matrices and cell arrays which
implements the lists.IObservable and lists.ICollection interfaces.

lists.Pipeline < lists.ICollection
Summary: This class is a pipeline which operates a process defined by the
list of contained lists.PipelineTask