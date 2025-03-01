"
I visit an abstract syntax tree and generate IR (intermediate representation) instructions for each node by sending the appropriate message to my methodBuilder (an IRBuilder).  I hold onto my two subclasses 
OCASTTranslatorForValue for generating instructions for effect and value, and
OCASTTranslatorForEffect for generating instructions for effect only.

Which one to use depends on the AST nodes and whether the code will only be executed (for effect only) or if the value is used afterwards (for value).

For example, when translating a return, the value to return needs to be pushed on stack, so the valueTranslator is used:
visitReturnNode: aReturnNode 
	valueTranslator visitNode: aReturnNode value.
	methodBuilder returnTop.
	
Whereas, in #visitMethodNode:,  the effectTranslator is used, because no value is pushed on stack at the end of the method body:
...effectTranslator visitNode: aMethodNode body..

"
Class {
	#name : #OCASTTranslator,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'methodBuilder',
		'effectTranslator',
		'valueTranslator'
	],
	#classVars : [
		'OptimizedMessages'
	],
	#category : #'OpalCompiler-Core-Translator'
}

{ #category : #'class initialization' }
OCASTTranslator class >> initialize [

	OptimizedMessages := { 
		                     (#caseOf: -> #emitCaseOf:).
		                     (#caseOf:otherwise: -> #emitCaseOfOtherwise:).
		                     (#ifFalse: -> #emitIfFalse:).
		                     (#ifFalse:ifTrue: -> #emitIfFalseIfTrue:).
		                     (#ifNil: -> #emitIfNil:).
		                     (#ifNil:ifNotNil: -> #emitIfNilIfNotNil:).
		                     (#ifNotNil: -> #emitIfNotNil:).
		                     (#ifNotNil:ifNil: -> #emitIfNotNilIfNil:).
		                     (#ifTrue: -> #emitIfTrue:).
		                     (#ifTrue:ifFalse: -> #emitIfTrueIfFalse:).
		                     (#or: -> #emitOr:).
		                     (#and: -> #emitAnd:).
		                     (#timesRepeat: -> #emitTimesRepeat:).
		                     (#repeat -> #emitRepeat:).
		                     (#to:by:do: -> #emitToByDo:).
		                     (#to:do: -> #emitToDo:).
		                     (#whileFalse: -> #emitWhileFalse:).
		                     (#whileTrue: -> #emitWhileTrue:).
		                     (#whileFalse -> #emitWhileFalse:).
		                     (#whileTrue -> #emitWhileTrue:) } asDictionary
]

{ #category : #errors }
OCASTTranslator >> backendError: aMessage forNode: aNode [
		
	SyntaxErrorNotification 	
		inClass: Object
		withCode: aNode methodNode source
		doitFlag: false
		errorMessage: aMessage
		location: aNode startWithoutParentheses
]

{ #category : #initialization }
OCASTTranslator >> classForEffect [
	^OCASTTranslatorForEffect
]

{ #category : #initialization }
OCASTTranslator >> classForValue [
	^OCASTTranslatorForValue
]

{ #category : #accessing }
OCASTTranslator >> compilationContext [
	^methodBuilder compilationContext
]

{ #category : #'inline messages factored' }
OCASTTranslator >> emitAllButLastCases: cases [

	|  assocMessageNode  |
	
	1 to: cases size - 1 do: [:i |
		methodBuilder pushDup.
		assocMessageNode := cases at: i.
		valueTranslator visitInlinedBlockNode: assocMessageNode receiver.
		methodBuilder send: #=.
		methodBuilder jumpAheadTo: #next if: false.
		methodBuilder popTop.
		self visitInlinedBlockNode: assocMessageNode arguments first.
		methodBuilder jumpAheadTo: #end.
		methodBuilder jumpAheadTarget: #next.
	]
]

{ #category : #'inline messages' }
OCASTTranslator >> emitAnd: aMessageNode [

	valueTranslator visitNode: aMessageNode receiver.
	methodBuilder jumpAheadTo: #else if: false.
	valueTranslator visitInlinedBlockNode: aMessageNode arguments first.
	methodBuilder jumpAheadTo: #end.
	methodBuilder jumpAheadTarget: #else.
	methodBuilder pushLiteral: false. 
	methodBuilder jumpAheadTarget: #end.
]

{ #category : #'inline messages' }
OCASTTranslator >> emitCaseOf: aMessageNode [

	self 
		emitCaseOf: aMessageNode 
		otherwiseBlock: [ 
			methodBuilder pushReceiver.
			methodBuilder send: #caseError ]
]

{ #category : #'inline messages factored' }
OCASTTranslator >> emitCaseOf: aMessageNode otherwiseBlock: aBlock [

	| cases assocMessageNode  |
	
	cases := aMessageNode arguments first statements.
	valueTranslator visitNode: aMessageNode receiver.
	valueTranslator emitAllButLastCases: cases.
	
	"last case with otherwise"
	assocMessageNode := cases last.
	valueTranslator visitInlinedBlockNode: assocMessageNode receiver.
	methodBuilder send: #=.
	methodBuilder jumpAheadTo: #next if: false.
	valueTranslator visitInlinedBlockNode: assocMessageNode arguments first.
	methodBuilder jumpAheadTo: #end.
	methodBuilder jumpAheadTarget: #next.
	aBlock value.

	cases size timesRepeat: [methodBuilder jumpAheadTarget: #end].
	
	aMessageNode lastIsReturn 
		ifTrue: [
			(aMessageNode owningScope) isBlockScope 
				ifTrue: [methodBuilder blockReturnTop] 
				ifFalse: [methodBuilder returnTop]] 
		ifFalse: [self isEffectTranslator ifTrue: [methodBuilder popTop]].
]

{ #category : #'inline messages' }
OCASTTranslator >> emitCaseOfOtherwise: aMessageNode [

	self 
		emitCaseOf: aMessageNode 
		otherwiseBlock: [ valueTranslator visitInlinedBlockNode: aMessageNode arguments last ]
]

{ #category : #'inline messages factored' }
OCASTTranslator >> emitCondition: args boolean: aBoolean [
	"emits the jumps so that one of the 2 blocks in args is evaluated depending on boolean"
	
	methodBuilder jumpAheadTo: #else if: aBoolean.
	self visitInlinedBlockNode: args first.
	methodBuilder jumpAheadTo: #end.
	methodBuilder jumpAheadTarget: #else.
	self visitInlinedBlockNode: args last.
	methodBuilder jumpAheadTarget: #end.
]

{ #category : #'inline messages factored' }
OCASTTranslator >> emitIf: aMessageNode boolean: aBoolean [

	valueTranslator visitNode: aMessageNode receiver.
	
	self emitCondition: aMessageNode arguments boolean: aBoolean
]

{ #category : #'inline messages' }
OCASTTranslator >> emitIfFalse: aMessageNode [

	self shouldBeSentToValueOrEffectTranslator
]

{ #category : #'inline messages' }
OCASTTranslator >> emitIfFalseIfTrue: aMessageNode [

	self emitIf: aMessageNode boolean: true
]

{ #category : #'inline messages' }
OCASTTranslator >> emitIfNil: aMessageNode [

	valueTranslator visitNode: aMessageNode receiver.
	self isValueTranslator ifTrue: [ methodBuilder pushDup ].
	methodBuilder pushLiteral: nil.
	methodBuilder send: #==.
	methodBuilder jumpAheadTo: #else if: false.
	self isValueTranslator ifTrue: [ methodBuilder popTop ].
	self visitInlinedBlockNode: aMessageNode arguments first.
	methodBuilder jumpAheadTarget: #else.
]

{ #category : #'inline messages factored' }
OCASTTranslator >> emitIfNil: aMessageNode boolean: aBoolean [
	| args notNilBlock |
	
	valueTranslator visitNode: aMessageNode receiver.
	
	"emits the == nil code and push correct value on stack if the ifNotNil block has an argument"
	args := aMessageNode arguments.
	notNilBlock := aBoolean ifTrue: [args first] ifFalse: [args last].
	notNilBlock arguments ifNotEmpty: [ notNilBlock arguments first variable emitStore: methodBuilder ].
	methodBuilder pushLiteral: nil.
	methodBuilder send: #==.
	
	self emitCondition: args boolean: aBoolean
]

{ #category : #'inline messages' }
OCASTTranslator >> emitIfNilIfNotNil: aMessageNode [
	self emitIfNil: aMessageNode boolean: false
]

{ #category : #'inline messages' }
OCASTTranslator >> emitIfNotNil: aMessageNode [

	self shouldBeSentToValueOrEffectTranslator
]

{ #category : #'inline messages' }
OCASTTranslator >> emitIfNotNilIfNil: aMessageNode [
	self emitIfNil: aMessageNode boolean: true
]

{ #category : #'inline messages' }
OCASTTranslator >> emitIfTrue: aMessageNode [

	self shouldBeSentToValueOrEffectTranslator
]

{ #category : #'inline messages' }
OCASTTranslator >> emitIfTrueIfFalse: aMessageNode [
	
	self emitIf: aMessageNode boolean: false
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> emitMessageNode: aMessageNode [

	aMessageNode isCascaded ifFalse: [
		valueTranslator visitNode: aMessageNode receiver].
	aMessageNode arguments do: [:each | 
		valueTranslator visitNode: each].
	aMessageNode isSuperSend
		ifTrue: [methodBuilder send: aMessageNode selector toSuperOf: self compilationContext getClass]
		ifFalse: [methodBuilder send: aMessageNode selector].
]

{ #category : #'inline messages' }
OCASTTranslator >> emitOr: aMessageNode [

	valueTranslator visitNode: aMessageNode receiver.
	methodBuilder jumpAheadTo: #else if: false.
	methodBuilder pushLiteral: true. 
	methodBuilder jumpAheadTo: #end.
	methodBuilder jumpAheadTarget: #else.
	valueTranslator visitInlinedBlockNode: aMessageNode arguments first.
	methodBuilder jumpAheadTarget: #end.
]

{ #category : #'inline messages' }
OCASTTranslator >> emitRepeat: aMessageNode [
	| block |
	block := aMessageNode receiver.
	methodBuilder jumpBackTarget: #start.
	effectTranslator visitInlinedBlockNode: block.
	methodBuilder jumpBackTo: #start.
	self isValueTranslator ifTrue: [ methodBuilder pushLiteral: nil ]
]

{ #category : #'inline messages' }
OCASTTranslator >> emitTimesRepeat: aMessageNode [ 
	| limit block limitEmit |
	
	limit := aMessageNode receiver.
	block := aMessageNode arguments last.
	
	limitEmit := [valueTranslator visitNode: limit].
	"if the limit is not just a literal or a non-writable variable, make a temp store it there"
	(limit isLiteralNode or: [limit isVariable and: [limit variable isWritable not]]) ifFalse: [
		valueTranslator visitNode: limit.
		methodBuilder addTemp: #'0limit'.
		methodBuilder storeTemp: #'0limit'.
		methodBuilder popTop.
		limitEmit := [methodBuilder pushTemp: #'0limit']].

	"push start. allocate and initialize iterator"
	self isValueTranslator ifTrue: [ limitEmit value ].
	methodBuilder pushLiteral: 1.
	methodBuilder addTemp: #'0iterator'.
	methodBuilder storeTemp: #'0iterator'.
	methodBuilder popTop. 
	methodBuilder jumpBackTarget: #start.
	methodBuilder pushTemp: #'0iterator'.
	limitEmit value.
	methodBuilder send: #<=.
	methodBuilder jumpAheadTo: #done if: false.

	effectTranslator visitInlinedBlockNode: block.
	methodBuilder pushTemp: #'0iterator'.
	methodBuilder pushLiteral: 1.
	methodBuilder send: #+.
	methodBuilder storeTemp: #'0iterator'.
	methodBuilder popTop.
	methodBuilder jumpBackTo: #start.
	methodBuilder jumpAheadTarget: #done.
]

{ #category : #'inline messages' }
OCASTTranslator >> emitToByDo: aMessageNode [ 

	| step |
	
	step := aMessageNode arguments second.
	step isLiteralNode ifFalse: [self error: 'should not have been inlined'].
	step := step value.

	self emitToDo: aMessageNode step: step
]

{ #category : #'inline messages' }
OCASTTranslator >> emitToDo: aMessageNode [ 
	
	self emitToDo: aMessageNode step: 1
]

{ #category : #'inline messages factored' }
OCASTTranslator >> emitToDo: aMessageNode step: step [
	| limit block iterator limitEmit |
	
	limit := aMessageNode arguments first.
	block := aMessageNode arguments last.
	iterator := block arguments first variable.
	
	limitEmit := [valueTranslator visitNode: limit].
	"if the limit is not just a literal or a non-writable variable, make a temp store it there"
	(limit isLiteralNode or: [limit isVariable and: [limit variable isWritable not]]) ifFalse: [
		valueTranslator visitNode: limit.
		methodBuilder addTemp: ('0limit_', iterator name).
		methodBuilder storeTemp: ('0limit_', iterator name).
		methodBuilder popTop.
		limitEmit := [methodBuilder pushTemp: ('0limit_', iterator name)]].

	"push start. allocate and initialize iterator"
	valueTranslator visitNode: aMessageNode receiver.
	iterator emitStore: methodBuilder.	
	self isEffectTranslator ifTrue: [methodBuilder popTop]. 
	methodBuilder jumpBackTarget: #start.
	iterator emitValue: methodBuilder.	
	limitEmit value.
	methodBuilder send: (step > 0 ifTrue: [#<=] ifFalse: [#>=]).
	methodBuilder jumpAheadTo: #done if: false.

	effectTranslator visitInlinedBlockNode: block.
	iterator emitValue: methodBuilder.
	methodBuilder pushLiteral: step.
	methodBuilder send: #+.
	iterator emitStore: methodBuilder.
	methodBuilder popTop.
	methodBuilder jumpBackTo: #start.
	methodBuilder jumpAheadTarget: #done.
]

{ #category : #'inline messages factored' }
OCASTTranslator >> emitWhile: aMessageNode boolean: aBoolean [

	methodBuilder jumpBackTarget: #begin.
	valueTranslator visitInlinedBlockNode: aMessageNode receiver.
	methodBuilder jumpAheadTo: #end if: aBoolean.
	aMessageNode arguments ifNotEmpty: [ 
			effectTranslator visitInlinedBlockNode: aMessageNode arguments first].
	methodBuilder jumpBackTo: #begin.
	methodBuilder jumpAheadTarget: #end.
]

{ #category : #'inline messages' }
OCASTTranslator >> emitWhileFalse: aMessageNode [

	self emitWhile: aMessageNode boolean: true
]

{ #category : #'inline messages' }
OCASTTranslator >> emitWhileTrue: aMessageNode [

	self emitWhile: aMessageNode boolean: false
]

{ #category : #initialization }
OCASTTranslator >> initialize [

	methodBuilder := IRBuilder new.
	effectTranslator := self classForEffect basicNew.
	valueTranslator := self classForValue basicNew.
	effectTranslator setFromSimilar: self.
	valueTranslator setFromSimilar: self.
]

{ #category : #accessing }
OCASTTranslator >> ir [

	^ methodBuilder ir
]

{ #category : #testing }
OCASTTranslator >> isEffectTranslator [
	^self == effectTranslator
]

{ #category : #testing }
OCASTTranslator >> isValueTranslator [
	^self == valueTranslator
]

{ #category : #private }
OCASTTranslator >> privateEffectTranslator [
	^ effectTranslator
]

{ #category : #private }
OCASTTranslator >> privateMethodBuilder [
	^ methodBuilder
]

{ #category : #private }
OCASTTranslator >> privateValueTranslator [
	^ valueTranslator
]

{ #category : #initialization }
OCASTTranslator >> setFromSimilar: aSimilarTranslator [
	methodBuilder := aSimilarTranslator privateMethodBuilder.
	effectTranslator := aSimilarTranslator privateEffectTranslator.
	valueTranslator := aSimilarTranslator privateValueTranslator.
]

{ #category : #errors }
OCASTTranslator >> shouldBeSentToValueOrEffectTranslator [
	self error: 'should be sent only to valueTranslator or effectTranslator'
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> translateFullBlock: aBlockNode [

	methodBuilder mapToNode: aBlockNode.
	methodBuilder compilationContext: aBlockNode methodNode compilationContext.
	
	"args, then copied, then temps"
	methodBuilder addTemps: aBlockNode argumentNames.
	methodBuilder addTemps: aBlockNode scope inComingCopiedVarNames.
	methodBuilder addTemps: aBlockNode scope tempVarNamesWithoutArguments.
	methodBuilder numArgs: aBlockNode arguments size.
	
	aBlockNode scope tempVector ifNotEmpty: [
		methodBuilder 
			createTempVectorNamed: aBlockNode scope tempVectorName 
			withVars: aBlockNode scope tempVectorVarNames.
	].
	valueTranslator visitNode: aBlockNode body.
	methodBuilder mapToNode: aBlockNode body.
	methodBuilder addBlockReturnTopIfRequired.
	aBlockNode ir: self ir.
	^ aBlockNode ir compiledBlock: aBlockNode scope
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitArrayNode: anArrayNode [ 

	| elementNodes |
	
	anArrayNode statements size > 32 ifTrue: [^ self visitLargeArrayNode: anArrayNode ].
	
	elementNodes := anArrayNode children.
	elementNodes do: [:node | valueTranslator visitNode: node].
	methodBuilder pushConsArray: elementNodes size.
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitAssignmentNode: anAssignmentNode [ 

	valueTranslator visitNode: anAssignmentNode value.
	anAssignmentNode variable variable emitStore: methodBuilder
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitBlockNode: aBlockNode [
	| compiledBlock |
	aBlockNode arguments size >15 ifTrue: [self backendError: 'Too many arguments' forNode: aBlockNode ].
	aBlockNode isInlined ifTrue: [^ self visitInlinedBlockNode: aBlockNode ].
	
	compiledBlock := self compilationContext astTranslatorClass new translateFullBlock: aBlockNode.
	(self compilationContext optionCleanBlockClosure and: [ aBlockNode isClean ])
		ifTrue: [ methodBuilder pushLiteral: ((CleanBlockClosure new: 0) numArgs: compiledBlock numArgs; compiledBlock: compiledBlock)]
		ifFalse: [methodBuilder pushFullClosureCompiledBlock: compiledBlock copiedValues: aBlockNode scope inComingCopiedVarNames  ]
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitCascadeNode: aCascadeNode [ 

	valueTranslator visitNode: aCascadeNode receiver.
	aCascadeNode messages allButLastDo: [:node |
		methodBuilder pushDup.
		effectTranslator visitNode: node.
	].
	self visitNode: aCascadeNode messages last.
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitInlinedBlockNode: anOptimizedBlockNode [

	"We are visiting a scope that is not a block, but inlined in the outer context.
	This means: 
			- we do not create a Block
			- we call IRBuilder to add temps
	"
	
	methodBuilder mapToNode: anOptimizedBlockNode.
	anOptimizedBlockNode scope tempVector ifNotEmpty: [
		methodBuilder 
			createTempVectorNamed: anOptimizedBlockNode scope tempVectorName 
			withVars: anOptimizedBlockNode scope tempVectorVarNames.
	].
	methodBuilder addTemps: anOptimizedBlockNode scope tempVarNamesWithoutArguments.
	methodBuilder addTemps: anOptimizedBlockNode scope inComingCopiedVarNames.
	methodBuilder addTemps: anOptimizedBlockNode argumentNames.
	anOptimizedBlockNode isInlinedLoop ifTrue: [
		anOptimizedBlockNode scope tempVarNamesWithoutArguments do: [ :tempName |
			methodBuilder pushLiteral: nil.
			methodBuilder storeTemp: tempName.
			methodBuilder popTop.
		]].
	
	self visitNode: anOptimizedBlockNode body.
	methodBuilder popMap
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitLargeArrayNode: aRBArrayNode [ 
	"Long form: generates (Array braceStream: N) nextPut: a; nextPut: b; ...; braceArray"
	methodBuilder pushLiteralVariable: Array binding.
	methodBuilder pushLiteral: aRBArrayNode statements size.
	methodBuilder send: #braceStream:.
	aRBArrayNode statements do: [ :each |
		methodBuilder pushDup.
		valueTranslator visitNode: each.
		methodBuilder send: #nextPut:.
		methodBuilder popTop.
		].
	methodBuilder send: #braceArray.
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitLiteralArrayNode: aRBLiteralArrayNode [ 
	 
	methodBuilder pushLiteral: aRBLiteralArrayNode value.
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitLiteralNode: aLiteralNode [

	methodBuilder pushLiteral: aLiteralNode value.
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitMessageNode: aMessageNode [
	aMessageNode isInlined ifTrue: [
		methodBuilder addLiteral: aMessageNode selector. "so searching for senders will work"
		^self 
			perform: (OptimizedMessages at: aMessageNode selector)
			with: aMessageNode].
	^ self emitMessageNode: aMessageNode
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitMethodNode: aMethodNode [
	
	aMethodNode arguments size > 15 ifTrue: [self backendError: 'Too many arguments' forNode: aMethodNode ].

	methodBuilder compilationContext: aMethodNode compilationContext.
	methodBuilder addTemps: aMethodNode scope tempVarNames.
		
	methodBuilder properties: aMethodNode methodProperties.
	methodBuilder irPrimitive: aMethodNode primitiveFromPragma.
	aMethodNode pragmas do: [:each | self visitPragmaNode: each].
	methodBuilder numArgs: aMethodNode arguments size.
	
	aMethodNode scope tempVector ifNotEmpty: [
		methodBuilder 
			createTempVectorNamed: aMethodNode scope tempVectorName 
			withVars: aMethodNode scope tempVectorVarNames
	].
	effectTranslator visitNode: aMethodNode body.
	aMethodNode body lastIsReturn ifFalse:  [methodBuilder pushReceiver; returnTop]
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitNode: aNode [
	methodBuilder mapToNode: aNode.
	super visitNode: aNode.
	methodBuilder popMap.
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitParseErrorNode: anErrorNode [  
	methodBuilder 
		pushLiteralVariable: RuntimeSyntaxError binding;
		pushLiteral: anErrorNode;
		send: #signalSyntaxError:
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitPragmaNode: aPragmaNode [

	| var |
	methodBuilder addPragma: aPragmaNode asPragma.
	
	"if the pragma is a primitive that defines an error variable, we need to store error value 
	which is on the stack"
	aPragmaNode isPrimitiveError ifFalse: [ ^ self ].
	var := aPragmaNode methodNode scope lookupVar: aPragmaNode primitiveErrorVariableName.
	var emitStore: methodBuilder.
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitReturnNode: aReturnNode [ 

	valueTranslator visitNode: aReturnNode value.
	methodBuilder returnTop.
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitSequenceNode: aSequenceNode [ 

	self shouldBeSentToValueOrEffectTranslator
]

{ #category : #'visitor - double dispatching' }
OCASTTranslator >> visitVariableNode: aVariableNode [
	aVariableNode variable emitValue: methodBuilder
]
