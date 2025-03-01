Class {
	#name : #ClyClassScopeTest,
	#superclass : #ClyLocalClassScopeTest,
	#category : #'Calypso-SystemQueries-Tests-Scopes'
}

{ #category : #running }
ClyClassScopeTest >> scopeClass [	
	^ClyClassScope
]

{ #category : #tests }
ClyClassScopeTest >> testClassEnumeration [
	scope := ClyClassScope ofAll: {ClyClass1FromP1Mock. ClyClass2FromP1Mock}.
	
	scope classesDo: [ :each | result add: each ].
	
	self assert: result asArray equals: {ClyClass1FromP1Mock. ClyClass2FromP1Mock}
]

{ #category : #tests }
ClyClassScopeTest >> testClassVarsEnumeration [
	scope := ClyClassScope ofAll: {Object. ClyClass1FromP1Mock}.	"last one has no class vars"
		
	scope classVariablesDo: [ :each | result add: each ].
	
	self assert: result size equals: 1.
	self
		assert: result anyOne
		equals: (ClyClassVariable on: Object classVariables first definedIn: Object)
]

{ #category : #tests }
ClyClassScopeTest >> testClassVarsEnumerationFromClassSideOfDefiningClass [
	scope := ClyClassScope of: Object class.
	
	scope classVariablesDo: [ :each | result add: each ].
	
	self assert: result size equals: 1.
	self
		assert: result anyOne
		equals: (ClyClassVariable on: Object classVariables first definedIn: Object)
]

{ #category : #tests }
ClyClassScopeTest >> testClassVarsEnumerationWhenTheyNotExist [
	scope := ClyClassScope of: ClyClass1FromP1Mock.
	
	scope classVariablesDo: [ :each | result add: each ].
	
	self assert: result isEmpty
]

{ #category : #tests }
ClyClassScopeTest >> testInstVarsEnumeration [
	scope := ClyClassScope of: ClyClass1FromP1Mock.

	scope instanceVariablesDo: [ :each | result add: each ].

	self assert: (result as: Set) equals: {
		ClyInstanceVariable named: #instanceSideVar2 definedIn: ClyClass1FromP1Mock.
		ClyInstanceVariable named: #instanceSideVar1 definedIn: ClyClass1FromP1Mock
	} asSet
]

{ #category : #tests }
ClyClassScopeTest >> testInstVarsEnumerationWhenThereAreNoVariables [
	scope := ClyClassScope of: Object.
	
	scope instanceVariablesDo: [ :each | result add: each ].
	
	self assert: result isEmpty
]

{ #category : #tests }
ClyClassScopeTest >> testMethodGroupsEnumeration [
	environment addPlugin: ClyDefaultSystemEnvironmentPlugin new.
	scope := ClyClassScope of: ClyClass1FromP1Mock in: environment.
	
	scope methodGroupsDo: [ :each | result add: each ].
	
	self
		assert: (result collect: #class as: Set)
		equals: {ClyAllMethodGroup. ClyTaggedMethodGroup} asSet.
	self
		assert: (result
				select: [ :each | each class = ClyTaggedMethodGroup ]
				thenCollect: #tag) sorted asArray
		equals: ClyClass1FromP1Mock tagsForMethods sorted asArray
]

{ #category : #tests }
ClyClassScopeTest >> testMethodsEnumeration [

	| expected |
	scope := ClyClassScope of: ClyClass1FromP1Mock.
	scope methodsDo: [ :each | result add: each selector ].
	expected := ClyClass1FromP1Mock localMethods collect: [:each | each selector].
	self assert: result sorted asArray equals: expected sorted asArray
]

{ #category : #tests }
ClyClassScopeTest >> testVariablesEnumerationForClassWithInstanceVariables [
	scope := ClyClassScope of: ClyClass1FromP1Mock.
	
	scope variablesDo: [ :each | result add: each ].
	
	self assert: (result as: Set) equals: {
		ClyInstanceVariable named: #instanceSideVar2 definedIn: ClyClass1FromP1Mock.
		ClyInstanceVariable named: #instanceSideVar1 definedIn: ClyClass1FromP1Mock
	} asSet
]

{ #category : #tests }
ClyClassScopeTest >> testVariablesEnumerationForObject [
	scope := ClyClassScope of: Object.
	
	scope variablesDo: [ :each | result add: each ].
	
	self assert: result size equals: 1.
	self
		assert: result anyOne
		equals: (ClyClassVariable on: Object classVariables first definedIn: Object)
]

{ #category : #tests }
ClyClassScopeTest >> testVariablesEnumerationForTwoClassesWithClassAndInstanceVars [
	scope := ClyClassScope ofAll: {Object. ClyClass1FromP1Mock}.
	
	scope variablesDo: [ :each | result add: each ].
	
	self assert: (result as: Set) equals: {
		ClyClassVariable named: #DependentsFields definedIn: Object.
		ClyInstanceVariable named: #instanceSideVar2 definedIn: ClyClass1FromP1Mock.
		ClyInstanceVariable named: #instanceSideVar1 definedIn: ClyClass1FromP1Mock
	} asSet
]

{ #category : #tests }
ClyClassScopeTest >> testVariablesEnumerationWhenThereAreNoVariables [
	scope := ClyClassScope of: ProtoObject.
	
	scope variablesDo: [ :each | result add: each ].
	
	self assert: result isEmpty
]
