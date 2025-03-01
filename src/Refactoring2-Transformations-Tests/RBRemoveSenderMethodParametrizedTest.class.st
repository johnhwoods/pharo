Class {
	#name : #RBRemoveSenderMethodParametrizedTest,
	#superclass : #RBWithDifferentsArgumentsParametrizedTest,
	#category : #'Refactoring2-Transformations-Tests-Parametrized'
}

{ #category : #tests }
RBRemoveSenderMethodParametrizedTest class >> testParameters [

	^ ParametrizedTestMatrix new
		addCase: { #rbClass -> RBRemoveSenderRefactoring .
					  #constructor -> #remove:inMethod:forClass: .
					  #index -> 1};
		addCase: { #rbClass -> RBRemoveMessageSendTransformation .
					  #constructor -> #messageSend:inMethod:inClass: .
					  #index -> 2};
		yourself
]

{ #category : #'failure tests' }
RBRemoveSenderMethodParametrizedTest >> testClassDoesNotExist [
	
	self shouldFail: (self createRefactoringWithArguments:
		{{(14 to: 17) . #byteAt:} . 
		#methodBefore .
		#RBMessageSendTransformationTest})
]

{ #category : #'failure tests' }
RBRemoveSenderMethodParametrizedTest >> testIsDirectlyUsed [
	| refactoring methodName |
	methodName := ('caller', '2') asSymbol.
	refactoring := self createRefactoringWithArguments: 
		{ { (58 to: 73) . #foo: } . 
		methodName . 
		#RBRefactoryTestDataApp }.
	self setupInlineExpressionFor: refactoring toReturn: false.
	self flag: 'TODO: refactoring2'.
"	self shouldFail: refactoring."
]

{ #category : #'failure tests' }
RBRemoveSenderMethodParametrizedTest >> testIsDirectlyUsed2 [
	| refactoring |
	refactoring := self createRefactoringWithArguments: 
		{{(25 to: 39). #isVariable} . 
		#returnsBooleanAndOther . 
		#RBRefactoryTestDataApp}.
	self setupInlineExpressionFor: refactoring toReturn: false.
	self flag: 'TODO: refactoring2'
"	self shouldFail: refactoring."
]

{ #category : #'failure tests' }
RBRemoveSenderMethodParametrizedTest >> testMethodDoesNotExist [
	self shouldFail: (self createRefactoringWithArguments:  
		{{(14 to: 17) . #foo: }. 
		#badMessage1 . 
		#RBRefactoryTestDataApp})
]

{ #category : #'failure tests' }
RBRemoveSenderMethodParametrizedTest >> testNonExistantSelector [
	self shouldFail: (self createRefactoringWithArguments:  
		{{(14 to: 17) . #foo: }. 
		#checkClass1: . 
		#RBRefactoryTestDataApp})
]

{ #category : #tests }
RBRemoveSenderMethodParametrizedTest >> testRemoveMessageInsideBlock [
	| refactoring methodName |
	methodName := ('caller', '1') asSymbol.
	refactoring := self createRefactoringWithArguments: 
		{ { (	90 to: 105) .#printString } . 
			methodName . 
			#RBRefactoryTestDataApp }.
			
	self setupInlineExpressionFor: refactoring toReturn: false.
	self executeRefactoring: refactoring .

	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: methodName) equals: (self parseMethod: 'caller1
	| anObject |
	anObject := 5.
	self called: anObject + 1
		on1: 
			[:each | 
			^anObject]')
]

{ #category : #tests }
RBRemoveSenderMethodParametrizedTest >> testRemoveSenderIntoCascaded2Message [
	| refactoring transformedMethod afterRefactoring1 afterRefactoring2 |
	afterRefactoring1 := self parseMethod: 'inlineMethod
	| temp |
	self foo.
	temp := self bar.
	^ temp'.
	afterRefactoring2 := self parseMethod: 'inlineMethod
	| temp |
	temp := self
		        foo;
		        bar.
	^ temp'.
	self proceedThroughWarning: 
		[ refactoring := self createRefactoringWithArguments: 
			{ { (33 to: 62) . #inlineMethod } . 
			#inlineMethod . 
			#RBRefactoryTestDataApp}.
		self setupInlineExpressionFor: refactoring toReturn: false.
		self executeRefactoring: refactoring ].
	transformedMethod := ((refactoring model classNamed: #RBRefactoryTestDataApp) 
	parseTreeFor: #inlineMethod).
	self assert: (transformedMethod = afterRefactoring1 or: [ transformedMethod = afterRefactoring2])
]

{ #category : #tests }
RBRemoveSenderMethodParametrizedTest >> testRemoveSenderIntoCascaded3Message [
	| refactoring transformedMethod afterRefactoring1 afterRefactoring2 |
	afterRefactoring1 := self parseMethod: 'referencesConditionFor: aClass

	| environment association anObject |
	anObject := RBCondition withBlock: [ 
		            association := Smalltalk globals
			                           associationAt: aClass name
			                           ifAbsent: [ 
			                           self refactoringError:
				                           ''Could not find class'' ].
		            environment := (self environment referencesTo:
			                            association)
		                           |
		                           (self environment referencesTo:
			                            aClass name).
		            environment isEmpty ].
	anObject errorMacro: aClass , '' is referenced.<n>Browse references?''.
	^ anObject yourself' .
	afterRefactoring2 := self parseMethod: 'referencesConditionFor: aClass
	| environment association |
	^ (RBCondition withBlock: [ 
			   association := Smalltalk globals
				                  associationAt: aClass name
				                  ifAbsent: [ 
					                  self refactoringError: ''Could not find class'' ].
			   environment := (self environment referencesTo: association)
			                  | (self environment referencesTo: aClass name).
			   environment isEmpty ])
		  errorMacro: aClass , '' is referenced.<n>Browse references?'';
		  yourself'.
	self proceedThroughWarning: 
		[ refactoring := self createRefactoringWithArguments:
			{{(	64 to: 461) . #errorBlock:}. 
				#referencesConditionFor: . 
				#RBRefactoryTestDataApp}.
	self setupInlineExpressionFor: refactoring toReturn: false.
	self executeRefactoring: refactoring ].
	transformedMethod := ((refactoring model classNamed: #RBRefactoryTestDataApp) 
	parseTreeFor: #referencesConditionFor:).
	self assert: (transformedMethod = afterRefactoring1 or: [transformedMethod = afterRefactoring2])
]

{ #category : #tests }
RBRemoveSenderMethodParametrizedTest >> testRemoveSenderIntoCascadedMessage [
	| refactoring methodName |
	methodName := ('called:', 'on:') asSymbol.
	self proceedThroughWarning: 
		[ refactoring := self createRefactoringWithArguments:  
			{{(	31 to: 75) . #cr}.
			methodName . 
			#RBRefactoryTestDataApp}.
	self setupInlineExpressionFor: refactoring toReturn: false.
	
	self executeRefactoring: refactoring ].
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: methodName) 
		equals: (self parseMethod: 'called: anObject on: aBlock 
			Transcript show: anObject printString.
			aBlock value')
]

{ #category : #tests }
RBRemoveSenderMethodParametrizedTest >> testRemoveSimpleSenderOfMessage [
	| refactoring methodName transformedMethod afterRefactoring1 afterRefactoring2 |
	afterRefactoring1 := self parseMethod: 'caller1
	| anObject arg1 |
	anObject := 5.
	arg1 := anObject + 1'.
	afterRefactoring2 :=  self parseMethod: 'caller1
	| anObject |
	anObject := 5'.
	methodName := ('caller', '1') asSymbol.
	refactoring := self createRefactoringWithArguments:  
			{{(	40 to: 120) . #called:on1:} . 
			methodName . 
			#RBRefactoryTestDataApp}.
	self setupInlineExpressionFor: refactoring toReturn: false.
	self executeRefactoring: refactoring .
	transformedMethod := ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: methodName) .
	self assert: (transformedMethod = afterRefactoring1 or: [transformedMethod = afterRefactoring2 ])
]
