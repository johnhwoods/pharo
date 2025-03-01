Class {
	#name : #RBRemoveParameterParametrizedTest,
	#superclass : #RBAbstractRefactoringTest,
	#category : #'Refactoring2-Transformations-Tests-Parametrized'
}

{ #category : #tests }
RBRemoveParameterParametrizedTest class >> testParameters [
	^ ParametrizedTestMatrix new
		addCase: { #rbClass -> RBRemoveParameterRefactoring };
		addCase: { #rbClass -> RBRemoveParameterTransformation};
		yourself
]

{ #category : #accessing }
RBRemoveParameterParametrizedTest >> constructor [ 
	^ #removeParameter:in:selector:
]

{ #category : #'failure tests' }
RBRemoveParameterParametrizedTest >> testNonExistantName [
	self shouldFail: (self createRefactoringWithArguments: 
		{ 'asdf' . RBBasicLintRuleTestData . #checkClass: }).
	self shouldFail: (self createRefactoringWithArguments:  
		{ 'aSmalllintContext' . RBBasicLintRuleTestData . #checkClass1: })
]

{ #category : #'failure tests' }
RBRemoveParameterParametrizedTest >> testPrimitiveMethods [
	| refactoring |
	(model classNamed: #Object) 
		compile: 'foo123: a <primitive: 100> ^#() primitiveFailed'
		classified: #(#accessing).
	refactoring := self createRefactoringWithModel: model 
		andArguments: { 'a' . Object . #foo123: }.
	self shouldFail: refactoring
]

{ #category : #'failure tests' }
RBRemoveParameterParametrizedTest >> testReferenceArgument [
	| refactoring |
	(model classNamed: #Object) 
		compile: 'methWith: arg1 ^ arg1 * 8'
		classified: #(#accessing).
	refactoring := self createRefactoringWithModel: model 
		andArguments: { 'arg1' . Object . #methWith: }.
	self shouldFail: refactoring
]

{ #category : #tests }
RBRemoveParameterParametrizedTest >> testRemoveParameter [
	| refactoring class |
	refactoring := self createRefactoringWithArguments: 
		{ 'anArg' . RBRefactoryTestDataApp . ('rename' , 'ThisMethod:') asSymbol }.
	self proceedThroughWarning: [ self executeRefactoring: refactoring ].
	class := refactoring model classNamed: #RBRefactoryTestDataApp.
	self assert: (class parseTreeFor: #renameThisMethod) equals: (self parseMethod: 'renameThisMethod
								^self').
	self assert: (class parseTreeFor: #callMethod) equals: (self parseMethod: 'callMethod
								^(self renameThisMethod)').
	self deny: (class directlyDefinesMethod: ('rename' , 'ThisMethod:') asSymbol)
]
