"
I model an abstract type of result for the run of a test case.
"
Class {
	#name : #DTTestResultType,
	#superclass : #Object,
	#category : #'DrTests-TestsRunner-Results'
}

{ #category : #factory }
DTTestResultType class >> backgroundColor [
	^ self subclassResponsibility
]

{ #category : #factory }
DTTestResultType class >> error [
	^ DTErrorResultType new
]

{ #category : #factory }
DTTestResultType class >> fail [
	^ DTFailResultType new
]

{ #category : #factory }
DTTestResultType class >> pass [
	^ DTPassResultType new
]

{ #category : #factory }
DTTestResultType class >> skipped [
	^ DTSkippedResultType new
]

{ #category : #factory }
DTTestResultType class >> textColor [
	^ TestResult defaultColorText
]

{ #category : #testing }
DTTestResultType >> isError [
	^ false
]

{ #category : #testing }
DTTestResultType >> isFail [
	^ false
]

{ #category : #testing }
DTTestResultType >> isPass [
	^ false
]

{ #category : #testing }
DTTestResultType >> isSkipped [
	^ false
]

{ #category : #accessing }
DTTestResultType >> name [
	^ self subclassResponsibility
]

{ #category : #accessing }
DTTestResultType >> pluralName [
	^ self name , 's'
]
