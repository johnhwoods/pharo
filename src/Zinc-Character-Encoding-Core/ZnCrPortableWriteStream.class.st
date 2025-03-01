"
This class has been replaced by ZnNewLineWriterStream
"
Class {
	#name : #ZnCrPortableWriteStream,
	#superclass : #WriteStream,
	#instVars : [
		'stream',
		'cr',
		'lf',
		'previous'
	],
	#category : #'Zinc-Character-Encoding-Core'
}

{ #category : #'instance creation' }
ZnCrPortableWriteStream class >> on: aStream [

	^ self basicNew
		initialize;
		stream: aStream;
		yourself
]

{ #category : #initialize }
ZnCrPortableWriteStream >> initialize [

	super initialize.
	cr := Character cr.
	lf := Character lf.
]

{ #category : #accessing }
ZnCrPortableWriteStream >> newLine [
	previous := nil.
	stream nextPutAll: OSPlatform current lineEnding
]

{ #category : #accessing }
ZnCrPortableWriteStream >> nextPut: aCharacter [
	"Write aCharacter to the receivers stream.
	Convert all line end combinations, i.e cr, lf, crlf, to the platform convention"

	(previous == cr and: [ aCharacter == lf ]) ifFalse: [
		(aCharacter == cr or: [ aCharacter == lf ]) ifTrue: 
			[ self newLine ]
		ifFalse:
			[ stream nextPut: aCharacter ] ].
	previous := aCharacter.

]

{ #category : #accessing }
ZnCrPortableWriteStream >> stream: aWriteStream [ 
	stream := aWriteStream
]
