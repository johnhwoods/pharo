Class {
	#name : #ReProperMethodProtocolNameForFileInOutRule,
	#superclass : #ReProperMethodProtocolNameRule,
	#category : #'Renraku-Rules'
}

{ #category : #idioms }
ReProperMethodProtocolNameForFileInOutRule class >> protocolIdiom [ 

	^self use: 'file in/out' insteadOf: #('filein/out' 'fileIn/Out' 'fileIn/out' 'filein/Out' 'file-in/out')
]
