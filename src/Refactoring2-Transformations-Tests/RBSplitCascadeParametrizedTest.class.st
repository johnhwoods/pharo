Class {
	#name : #RBSplitCascadeParametrizedTest,
	#superclass : #RBAbstractRefactoringTest,
	#category : #'Refactoring2-Transformations-Tests-Parametrized'
}

{ #category : #tests }
RBSplitCascadeParametrizedTest class >> testParameters [
	^ ParametrizedTestMatrix new
		addCase: { #rbClass -> RBSplitCascadeRefactoring };
		yourself
]

{ #category : #accessing }
RBSplitCascadeParametrizedTest >> constructor [ 
	^ #split:from:in:
]

{ #category : #data }
RBSplitCascadeParametrizedTest >> methodWithCascades [
	| a |
	a := Object new initialize; asString.
	^ a
]

{ #category : #'failure tests' }
RBSplitCascadeParametrizedTest >> testMethodWithoutCascade [
	self shouldFail: (self createRefactoringWithArguments: 
		{ (54 to: 55) . ('an', 'InstVar:') asSymbol . RBBasicLintRuleTestData })
]

{ #category : #'failure tests' }
RBSplitCascadeParametrizedTest >> testNonExistantSelectorName [
	self shouldFail: (self createRefactoringWithArguments:
		{ (54 to: 55) . #foo . self class })
]

{ #category : #tests }
RBSplitCascadeParametrizedTest >> testSplitCascadeRefactoring [
	| refactoring |
	refactoring := self createRefactoringWithArguments:
		{ (54 to: 55) . #methodWithCascades . self class }.
	
	self executeRefactoring: refactoring.

	self assert: ((refactoring model classNamed: #RBSplitCascadeParametrizedTest) parseTreeFor: #methodWithCascades) equals: (self parseMethod: 'methodWithCascades
	| a receiver |
	receiver := Object new.
	receiver initialize.
	a := receiver asString.
	^ a')
]
