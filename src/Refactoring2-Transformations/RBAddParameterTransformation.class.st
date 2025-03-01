Class {
	#name : #RBAddParameterTransformation,
	#superclass : #RBChangeMethodNameTransformation,
	#instVars : [
		'newArgs',
		'senders'
	],
	#category : #'Refactoring2-Transformations-Model'
}

{ #category : #adding }
RBAddParameterTransformation class >> addParameterToMethod: aSelector in: aClass newSelector: newSelector permutation: aColl1 newArgs: aColl2 [ 
	^ self new 
		addParameterToMethod: aSelector
		in: aClass
		newSelector: newSelector
		permutation: aColl1
		newArgs: aColl2
]

{ #category : #adding }
RBAddParameterTransformation class >> model: aRBSmalltalk addParameterToMethod: aSelector in: aClass newSelector: newSelector permutation: aColl1 newArgs: aColl2 [ 
	^ self new
		model: aRBSmalltalk;
		addParameterToMethod: aSelector
		in: aClass
		newSelector: newSelector
		permutation: aColl1
		newArgs: aColl2;
		yourself
]

{ #category : #adding }
RBAddParameterTransformation >> addParameterToMethod: aSelector in: aClass newSelector: newSel permutation: aColl1 newArgs: aColl2 [
	self 
		renameMethod: aSelector
		in: aClass
		to: newSel
		permutation: aColl1.
	newArgs := aColl2.
]

{ #category : #adding }
RBAddParameterTransformation >> canReferenceVariable: aString in: aClass [ 
	(aClass definesVariable: aString) ifTrue: [^true].
	(self model includesGlobal: aString asSymbol) ifTrue: [^true].
	^(self poolVariableNamesFor: aClass) includes: aString
]

{ #category : #adding }
RBAddParameterTransformation >> checkSendersAccessTo: name [

	(#('self' 'super') includes: name) ifTrue: [ ^ self ].
	self senders
		detect: [ :each | (self canReferenceVariable: name in: each) not ]
		ifFound: [ :violatorClass | 
			self
				refactoringError:
					('<1s> doesn''t appear to be defined in <2p>'
						expandMacrosWith: name
						with: violatorClass) ]
]

{ #category : #adding }
RBAddParameterTransformation >> checkVariableReferencesIn: aParseTree [

	| searcher |

	searcher := self parseTreeSearcher.
	searcher
		matches: '`var'
		do: [ :aNode :answer | 
			| name |

			name := aNode name.
			( aNode whoDefines: name ) ifNil: [ self checkSendersAccessTo: name ]
			].
	searcher executeTree: aParseTree
]

{ #category : #adding }
RBAddParameterTransformation >> modifyImplementorParseTree: parseTree in: aClass [
	| argNames index |
	argNames := newArgs collect: [ :arg | | newArg |
		newArg := self safeVariableNamed: arg newName for: aClass temporaries: (parseTree temporaryNames, parseTree argumentNames).
	index := 0.
		newArg ].
	parseTree 
		renameSelector: newSelector
		andArguments: ((permutation 
			collect: [ :e | parseTree argumentNames at: e ifAbsent: [ index := index +1.
				argNames at: index	] ]) 
				collect: [:e | RBVariableNode named: e ]).
	self renameArgumentsIn: parseTree.
]

{ #category : #adding }
RBAddParameterTransformation >> myConditions [
	^RBCondition withBlock: 
		[oldSelector numArgs < newSelector numArgs 
			ifFalse: 
				[self refactoringFailure: newSelector printString, 
				' doesn''t have the proper number of arguments.'].
		self newArgs do: [	:arg | self verifyInitializationExpressionOf: arg value1 ].
		true]
]

{ #category : #adding }
RBAddParameterTransformation >> newArgs [
	^ newArgs ifNil: [ newArgs := { } ]
]

{ #category : #adding }
RBAddParameterTransformation >> newSelectorString [
	| stream keywords indexNewArgs |
	stream := WriteStream on: String new.
	keywords := newSelector keywords.
	indexNewArgs := 0.
	permutation
		doWithIndex: 
			[:each :index |
			stream nextPutAll: (keywords at: index).
			each < 0
				ifTrue: 
					[ indexNewArgs := indexNewArgs - 1.
					stream
						nextPut: $(;
						nextPutAll: (newArgs at: indexNewArgs * -1) value1;
						nextPut: $)]
				ifFalse: 
					[stream
						nextPutAll: ' ``@arg';
						nextPutAll: each printString].
			stream nextPut: $ ].
	^stream contents
]

{ #category : #adding }
RBAddParameterTransformation >> parseTreeRewriter [
	| rewriteRule oldString newString |
	rewriteRule := self parseTreeRewriterClass new.
	oldString := self buildSelectorString: oldSelector.
	newString := self newSelectorString.
	rewriteRule replace: '``@object ' , oldString
		with: '``@object ' , newString.
	^rewriteRule
]

{ #category : #adding }
RBAddParameterTransformation >> renameArgumentsIn: parseTree [
	| newArgNames |
	newArgNames := newArgs collect: [ :arg | arg name ].	
	self renameMap do: [ :arg |
		(newArgNames includes: arg name) ifFalse: [ 
		(self parseTreeRewriterClass rename: arg name to: arg newName) executeTree: parseTree
	] ]
]

{ #category : #adding }
RBAddParameterTransformation >> safeVariableNameFor: aClass temporaries: allTempVars [ 
	| baseString index newString |
	newString := baseString := 'anObject'.
	index := 0.
	
	[(allTempVars includes: newString) 
		or: [aClass definesInstanceVariable: newString]] 
			whileTrue: 
				[index := index + 1.
				newString := baseString , index printString].
	^newString
]

{ #category : #adding }
RBAddParameterTransformation >> safeVariableNamed: argName for: aClass temporaries: allTempVars [ 
	| baseString index newString |
	((allTempVars includes: argName) 
		or: [aClass definesInstanceVariable: argName]) ifFalse: [ ^ argName ].
	newString := baseString := 'anObject'.
	index := 0.
	
	[(allTempVars includes: newString) 
		or: [aClass definesInstanceVariable: newString]] 
			whileTrue: 
				[index := index + 1.
				newString := baseString , index printString].
	^newString
]

{ #category : #adding }
RBAddParameterTransformation >> senders [

	senders
		ifNil: [ senders := Set new.
			self model allReferencesTo: oldSelector do: [ :each | senders add: each modelClass ]
			].
	^ senders
]

{ #category : #adding }
RBAddParameterTransformation >> storeOn: aStream [ 
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' addParameterToMethod: #';
		nextPutAll: oldSelector;
		nextPutAll: ' in: '.
	class storeOn: aStream.
	aStream
		nextPutAll: ' newSelector: #';
		nextPutAll: newSelector;
		nextPutAll: ' permutation: ';
		nextPutAll: permutation asString;
		nextPutAll: ' newArgs: '''.
	newArgs storeOn: aStream.
	aStream
		nextPutAll: ''')'.
]

{ #category : #adding }
RBAddParameterTransformation >> verifyInitializationExpressionOf: initializer [
	| tree |
	tree := self parserClass
		parseExpression: initializer
		onError: [ :msg :index | self refactoringFailure: 'Illegal initialization code because:.', msg ].
	tree isValue
		ifFalse: [ self refactoringFailure: 'The initialization code cannot be a return node or a list of statements' ].
	self checkVariableReferencesIn: tree.
]
