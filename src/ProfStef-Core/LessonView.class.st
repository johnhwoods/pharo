"
A LessonView displays a Lesson instance.

LessonView new open
"
Class {
	#name : #LessonView,
	#superclass : #Object,
	#instVars : [
		'shoutMorph',
		'window',
		'sourceTextModel'
	],
	#category : #'ProfStef-Core'
}

{ #category : #gui }
LessonView class >> menuOn: aBuilder [
	<LessonViewContextMenu>
	
	(aBuilder item: #'Do it' translated)
		keyText: 'd';
		selector: #doIt;
		help: nil;
		iconName: #smallDoIt.
	(aBuilder item: #'Print it' translated)
		keyText: 'p';
		selector: #printIt;
		help: nil;
		iconName: #smallPrintIt.
	(aBuilder item: #'Inspect it' translated)
		keyText: 'i';
		selector: #inspectIt;
		help: nil;
		iconName: #smallInspectIt.
]

{ #category : #accessing }
LessonView >> bindings [

	"dynamic variable binding not needed for Lessons"

	^ Dictionary new
]

{ #category : #gui }
LessonView >> buildText [
	| scrolledText |
	scrolledText := self sourceTextModel newScrolledText
		beForSmalltalkScripting;
		beWrapped;
		yourself.
	scrolledText textArea font: StandardFonts codeFont.
	^ scrolledText
]

{ #category : #gui }
LessonView >> buildWindow [
	^ SystemWindow labelled: 'PrStef lesson'.
]

{ #category : #gui }
LessonView >> close [
	window delete.
]

{ #category : #accessing }
LessonView >> doItContext [
	^ nil
]

{ #category : #accessing }
LessonView >> doItReceiver [
	^ nil
]

{ #category : #initialization }
LessonView >> initialize [

	super initialize.
	window := self buildWindow.
	shoutMorph := self buildText.
	window addMorph: shoutMorph frame: (0 @ 0 corner: 1 @ 1).
	window extent: 600 @ 450.
]

{ #category : #testing }
LessonView >> isOpenInWindow [
	^ self currentWorld systemWindows includes: window
]

{ #category : #gui }
LessonView >> menu [
	^ (PragmaMenuBuilder pragmaKeyword: #LessonViewContextMenu model: self) menu.
]

{ #category : #gui }
LessonView >> open [
	"menu: #shoutMorphFillMenu:."
	window openInWorld
]

{ #category : #accessing }
LessonView >> selectedClassOrMetaClass [
	^ nil
]

{ #category : #accessing }
LessonView >> shoutAboutToStyle: aPluggableShoutMorphOrView [
	^ true
]

{ #category : #accessing }
LessonView >> shoutMorph [
	^ shoutMorph
]

{ #category : #gui }
LessonView >> shoutMorphFillMenu: aMenu [
	^ aMenu addAllFrom: self menu
]

{ #category : #gui }
LessonView >> showLesson: aLesson withTitle: aString [
	self window setLabel: aString.
	self sourceTextModel setText: aLesson lesson.
	self isOpenInWindow ifFalse: [ self open ]
]

{ #category : #accessing }
LessonView >> sourceTextModel [
	^ sourceTextModel ifNil: [ sourceTextModel := RubScrolledTextModel new interactionModel: self ].
]

{ #category : #accessing }
LessonView >> text [
	^ self sourceTextModel getText asString
]

{ #category : #accessing }
LessonView >> window [ 
	^ window
]
