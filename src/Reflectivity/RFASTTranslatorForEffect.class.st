"
WORKAROUND: copy of OCASTTranslatorForEffect

Will be removed when the new Translor design is in place
"
Class {
	#name : #RFASTTranslatorForEffect,
	#superclass : #RFASTTranslator,
	#category : #'Reflectivity-Compiler'
}

{ #category : #'inline messages' }
RFASTTranslatorForEffect >> emitAnd: aMessageNode [
	
	super emitAnd: aMessageNode.
	methodBuilder popTop.
]

{ #category : #'inline messages' }
RFASTTranslatorForEffect >> emitIfFalse: aMessageNode [

	valueTranslator visitNode: aMessageNode receiver.
	methodBuilder jumpAheadTo: #else if: true.
		self visitInlinedBlockNode: aMessageNode arguments first.
	methodBuilder jumpAheadTarget: #else.
]

{ #category : #'inline messages' }
RFASTTranslatorForEffect >> emitIfNotNil: aMessageNode [
	| args |
	valueTranslator visitNode: aMessageNode receiver.
	args := aMessageNode arguments.
	args first arguments ifNotEmpty: [ args first arguments first binding emitStore: methodBuilder ].
	methodBuilder pushLiteral: nil.
	methodBuilder send: #==.
	methodBuilder jumpAheadTo: #end if: true.
	self visitInlinedBlockNode: args first.
	methodBuilder jumpAheadTarget: #end.
]

{ #category : #'inline messages' }
RFASTTranslatorForEffect >> emitIfTrue: aMessageNode [

	valueTranslator visitNode: aMessageNode receiver.
	methodBuilder jumpAheadTo: #else if: false.	
		self visitInlinedBlockNode: aMessageNode arguments first.
	methodBuilder jumpAheadTarget: #else.
]

{ #category : #'visitor - double dispatching' }
RFASTTranslatorForEffect >> emitMessageNode: aMessageNode [ 

	super emitMessageNode: aMessageNode.
	methodBuilder popTop.
]

{ #category : #'inline messages' }
RFASTTranslatorForEffect >> emitOr: aMessageNode [

	super emitOr: aMessageNode.
	methodBuilder popTop.
]

{ #category : #'visitor - double dispatching' }
RFASTTranslatorForEffect >> visitArrayNode: anArrayNode [ 
	"An arrayNode may have side effect, for example: '{self foo}'. So we cannot just generate nothing for this node."

	super visitArrayNode: anArrayNode.
	methodBuilder popTop.
]

{ #category : #'visitor - double dispatching' }
RFASTTranslatorForEffect >> visitAssignmentNode: anAssignmentNode [ 

	super visitAssignmentNode: anAssignmentNode .
	methodBuilder popTop.
]

{ #category : #'visitor - double dispatching' }
RFASTTranslatorForEffect >> visitBlockNode: aBlockNode [ 
	"even though the code is never executed, we generate it to make sure that we 
	can map bytecode and access temps"
	super visitBlockNode: aBlockNode.
	methodBuilder popTop
]

{ #category : #'visitor - double dispatching' }
RFASTTranslatorForEffect >> visitLiteralArrayNode: aLiteralNode [
	"when visiting a literal array for effect, we could push it and then pop it, but we do nothing"
	methodBuilder addLiteral: aLiteralNode value
]

{ #category : #'visitor - double dispatching' }
RFASTTranslatorForEffect >> visitLiteralNode: aLiteralNode [
	"when visiting a literal for effect, we could push it and then pop it, but we do nothing"
	methodBuilder addLiteral: aLiteralNode value
]

{ #category : #'visitor - double dispatching' }
RFASTTranslatorForEffect >> visitParseErrorNode: anErrorNode [  

	super visitParseErrorNode: anErrorNode.
	methodBuilder popTop.
]

{ #category : #'visitor - double dispatching' }
RFASTTranslatorForEffect >> visitSequenceNode: aSequenceNode [
	
	self emitPreamble: aSequenceNode.
	self emitMetaLinkBefore: aSequenceNode.
		
	aSequenceNode hasMetalinkAfter ifTrue: [ ^ self visitSequenceWithAfter: aSequenceNode  ].
	
	aSequenceNode hasMetalinkInstead
		ifTrue: [ self emitMetaLinkInstead: aSequenceNode ]
		ifFalse: [ aSequenceNode statements do: [:each | self visitNode: each]. ].
	aSequenceNode hasMetalinkInstead ifTrue: [aSequenceNode parent isMethod 
			ifTrue: [methodBuilder returnTop]
			ifFalse: [methodBuilder popTop]]
]

{ #category : #'visitor - double dispatching' }
RFASTTranslatorForEffect >> visitVariableNode: aVariableNode [
	
	| binding |
	
	self emitPreamble: aVariableNode.
	self emitMetaLinkBefore: aVariableNode.
	
	aVariableNode hasMetalinkInstead
		ifTrue: [ self emitMetaLinkInstead: aVariableNode ].
		
	"when visiting a variable for effect, we could push it and then pop it, but we do nothing"
	binding := aVariableNode binding.
	(binding isLiteralVariable or: [ binding isUndeclaredVariable ])
		ifTrue: [ methodBuilder addLiteral: binding ].
		
	self emitMetaLinkAfterNoEnsure: aVariableNode.
]
