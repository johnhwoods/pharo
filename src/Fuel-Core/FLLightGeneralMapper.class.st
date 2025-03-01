"
I know how to map an object to its default cluster. I can map every object.
"
Class {
	#name : #FLLightGeneralMapper,
	#superclass : #FLMapper,
	#category : #'Fuel-Core-Mappers'
}

{ #category : #'protected-mapping' }
FLLightGeneralMapper >> clusterClassForSmallInteger: aSmallInteger [

	aSmallInteger >= 0 ifTrue: [
		aSmallInteger <= 255 ifTrue: [^ FLPositive8SmallIntegerCluster].
		aSmallInteger <= 65535 ifTrue: [^ FLPositive16SmallIntegerCluster].
		aSmallInteger <= 16777215 ifTrue: [^ FLPositive24SmallIntegerCluster].
		aSmallInteger <= 4294967295 ifTrue: [^ FLPositive32SmallIntegerCluster].
		aSmallInteger <= 1152921504606846975 ifTrue: [^ FLPositive64SmallIntegerCluster].
	].
	aSmallInteger >= -128 ifTrue: [^ FLNegative8SmallIntegerCluster].
	aSmallInteger >= -32768 ifTrue: [^ FLNegative16SmallIntegerCluster].
	aSmallInteger >= -8388608 ifTrue: [^ FLNegative24SmallIntegerCluster].
	aSmallInteger >= -2147483648 ifTrue: [^ FLNegative32SmallIntegerCluster].
	aSmallInteger >= -1152921504606846976 ifTrue: [^ FLNegative64SmallIntegerCluster].

	self error: 'SmallInteger is out of range'
]

{ #category : #mapping }
FLLightGeneralMapper >> mapAndTrace: anObject [

	anObject fuelAccept: self
]

{ #category : #'protected-mapping' }
FLLightGeneralMapper >> mapAndTraceInstanceSideGlobal: aClassOrTrait [

	(self clusterKeyedByClusterName: FLGlobalClassCluster)
		add: aClassOrTrait traceWith: analysis
]

{ #category : #visiting }
FLLightGeneralMapper >> visitBytesObject: anObject [

	self mapAndTraceByObjectClass: anObject to: FLByteObjectCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitClass: aClass [

	self mapAndTraceInstanceSideGlobal: aClass
]

{ #category : #visiting }
FLLightGeneralMapper >> visitClassTrait: aClassTrait [

	self mapAndTraceByClusterName: aClassTrait to: FLGlobalClassSideCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitCompiledBlock: aCompiledBlock [
	self
		mapAndTraceByClusterName: aCompiledBlock
		to: ((aCompiledBlock method isInstalled not or: [ aCompiledBlock method isDoIt ])
			ifTrue: [ FLCompiledBlockCluster ]
			ifFalse: [ FLGlobalCompiledBlockCluster ])
]

{ #category : #visiting }
FLLightGeneralMapper >> visitCompiledMethod: aCompiledMethod [
	self
		mapAndTraceByClusterName: aCompiledMethod
		to: ((aCompiledMethod isInstalled not or: [aCompiledMethod isDoIt ])
			ifTrue: [ FLCompiledMethodCluster ]
			ifFalse: [ FLGlobalCompiledMethodCluster ])
]

{ #category : #visiting }
FLLightGeneralMapper >> visitDictionary: aDictionary [

	self mapAndTraceByObjectClass: aDictionary to: FLDictionaryCollectionCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitExternalAddress: anObject [
	self
		mapAndTraceByObjectClass: anObject
		to: FLExternalAddressCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitFixedObject: anObject [

	self mapAndTraceByObjectClass: anObject to: FLFixedObjectCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitGlobalSend: anObject name: globalName selector: aSymbol [

	(self clusterKeyedByClusterName: FLGlobalSendCluster)
		add: anObject name: globalName selector: aSymbol traceWith: analysis
]

{ #category : #visiting }
FLLightGeneralMapper >> visitHookPrimitive: anObject [

	self mapAndTraceByObjectClass: anObject to: FLHookPrimitiveCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitMetaclass: aMetaclass [

	self mapAndTraceByClusterName: aMetaclass to: FLGlobalClassSideCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitMetaclassForTraits: aMetaclass [
	self
		mapAndTraceByClusterName: aMetaclass
		to: FLGlobalClassSideCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitMethodContext: aMethodContext [

	self mapAndTraceByObjectClass: aMethodContext to: FLContextCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitNotSerializable: anObject [
	FLNotSerializable signalWith: anObject
]

{ #category : #visiting }
FLLightGeneralMapper >> visitPoint: aPoint [

	self mapAndTraceByClusterName: aPoint to: FLPointCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitRectangle: aRectangle [

	self mapAndTraceByClusterName: aRectangle to: FLRectangleCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitSimpleCollection: aCollection [
	self mapAndTraceByObjectClass: aCollection to: FLSimpleCollectionCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitSmallInteger: aSmallInteger [

	self mapAndTraceByClusterName: aSmallInteger to: (self clusterClassForSmallInteger: aSmallInteger)
]

{ #category : #visiting }
FLLightGeneralMapper >> visitSubstitution: anObject by: anotherObject [

	(self clusterKeyedByClusterName: FLSubstitutionCluster)
		add: anObject substitutedBy: anotherObject traceWith: analysis
]

{ #category : #visiting }
FLLightGeneralMapper >> visitSubstitution: anObject by: anotherObject onRecursionDo: aBlock [

	| cluster |
	cluster := self clusterKeyedByClusterName: FLSubstitutionCluster.

	(cluster isSubstitute: anObject)
		ifTrue: aBlock
		ifFalse: [
			cluster
				add: anObject
				substitutedBy: anotherObject
				traceWith: analysis ]
]

{ #category : #visiting }
FLLightGeneralMapper >> visitTrait: aTrait [

	self mapAndTraceInstanceSideGlobal: aTrait
]

{ #category : #visiting }
FLLightGeneralMapper >> visitTraitedMetaclass: aMetaclass [
	self
		mapAndTraceByClusterName: aMetaclass
		to: FLGlobalClassSideCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitVariableObject: anObject [

	self mapAndTraceByObjectClass: anObject to: FLVariableObjectCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitWeakObject: anObject [

	self mapAndTraceByObjectClass: anObject to: FLWeakVariableObjectCluster
]

{ #category : #visiting }
FLLightGeneralMapper >> visitWordsObject: anObject [

	self mapAndTraceByObjectClass: anObject to: FLWordObjectCluster
]
