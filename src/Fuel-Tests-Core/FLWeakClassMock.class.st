"
Test mock for a weak class
"
Class {
	#name : #FLWeakClassMock,
	#superclass : #FLPair,
	#type : #weak,
	#instVars : [
		'instVar1'
	],
	#category : #'Fuel-Tests-Core-Mocks'
}

{ #category : #accessing }
FLWeakClassMock >> instVar1 [
	^ instVar1
]

{ #category : #accessing }
FLWeakClassMock >> instVar1: anObject [
	instVar1 := anObject
]
