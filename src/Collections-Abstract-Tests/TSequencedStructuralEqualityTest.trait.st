"
A trait for test purposes
"
Trait {
	#name : #TSequencedStructuralEqualityTest,
	#traits : 'TStructuralEqualityTest',
	#classTraits : 'TStructuralEqualityTest classTrait',
	#category : #'Collections-Abstract-Tests-Traits'
}

{ #category : #'tests - equality' }
TSequencedStructuralEqualityTest >> empty [
	
	^ self explicitRequirement
]

{ #category : #'tests - equality' }
TSequencedStructuralEqualityTest >> nonEmpty [
	
	^ self explicitRequirement
]

{ #category : #'tests - fixture' }
TSequencedStructuralEqualityTest >> test0TSequencedStructuralEqualityTest [

	self nonEmpty at: 1	"Ensures #nonEmpty is sequenceable"
]

{ #category : #'tests - fixture' }
TSequencedStructuralEqualityTest >> test0TStructuralEqualityTest [
	self empty.
	self nonEmpty.
	self assertEmpty: self empty.
	self denyEmpty: self nonEmpty
]

{ #category : #'tests - equality' }
TSequencedStructuralEqualityTest >> testEqualSign [
 
	self deny: (self empty = self nonEmpty)
]

{ #category : #'tests - equality' }
TSequencedStructuralEqualityTest >> testEqualSignForSequenceableCollections [

	self deny: (self nonEmpty = self nonEmpty asSet). 
	self deny: (self nonEmpty reversed = self nonEmpty).
	self deny: (self nonEmpty = self nonEmpty reversed)
]

{ #category : #'tests - equality' }
TSequencedStructuralEqualityTest >> testEqualSignIsTrueForEmptyButNonIdenticalCollections [
	
	self assert: self empty equals: self empty copy. 
	self assert: self empty copy equals: self empty.
	self assert: self empty copy equals: self empty copy
]

{ #category : #'tests - equality' }
TSequencedStructuralEqualityTest >> testEqualSignIsTrueForNonIdenticalButEqualCollections [
		
	self assert: self empty equals: self empty copy. 
	self assert: self empty copy equals: self empty.
	self assert: self empty copy equals: self empty copy.
		
	self assert: self nonEmpty equals: self nonEmpty copy. 
	self assert: self nonEmpty copy equals: self nonEmpty.
	self assert: self nonEmpty copy equals: self nonEmpty copy
]

{ #category : #'tests - equality' }
TSequencedStructuralEqualityTest >> testEqualSignOfIdenticalCollectionObjects [
	
	self assert: self empty equals: self empty. 
	self assert: self nonEmpty equals: self nonEmpty
]

{ #category : #'tests - equality' }
TSequencedStructuralEqualityTest >> testHasEqualElements [

	self deny: (self empty hasEqualElements: self nonEmpty).
	self deny: (self nonEmpty hasEqualElements: self nonEmpty asSet). 
	self deny: (self nonEmpty reversed hasEqualElements: self nonEmpty).
	self deny: (self nonEmpty hasEqualElements: self nonEmpty reversed)
]

{ #category : #'tests - equality' }
TSequencedStructuralEqualityTest >> testHasEqualElementsIsTrueForNonIdenticalButEqualCollections [
		
	self assert: (self empty hasEqualElements: self empty copy). 
	self assert: (self empty copy hasEqualElements: self empty).
	self assert: (self empty copy hasEqualElements: self empty copy).
		
	self assert: (self nonEmpty hasEqualElements: self nonEmpty copy). 
	self assert: (self nonEmpty copy hasEqualElements: self nonEmpty).
	self assert: (self nonEmpty copy hasEqualElements: self nonEmpty copy)
]

{ #category : #'tests - equality' }
TSequencedStructuralEqualityTest >> testHasEqualElementsOfIdenticalCollectionObjects [
	
	self assert: (self empty hasEqualElements: self empty). 
	self assert: (self nonEmpty hasEqualElements: self nonEmpty)
]
