"
This class defines the full reference help for the system.
(contents for the full API Help).

Just run ""HelpBrowser openOn: SystemReference"".




"
Class {
	#name : #SystemReference,
	#superclass : #Object,
	#classVars : [
		'ClassAPIHelpBuilderClass'
	],
	#category : #'HelpSystem-Core-Utilities'
}

{ #category : #'help topic creation' }
SystemReference class >> all [
	"HelpBrowser openOn: self all "
	
	^(self classAPIHelpBuilderClass new)
		rootToBuildFrom: ProtoObject;
		addSubclasses: true;
		addMethods: true;
		subclassesAsSeparateTopic: false;
		build;
		topicToBuild
]

{ #category : #'help topic creation' }
SystemReference class >> asHelpTopic [ 
	"HelpBrowser openOn: SystemReference"
	
	^self hierarchyFor: ProtoObject
]

{ #category : #'help topic creation' }
SystemReference class >> classAPIHelpBuilderClass [

	ClassAPIHelpBuilderClass ifNil: [ ClassAPIHelpBuilderClass := ClassAPIHelpBuilder ].
	^ ClassAPIHelpBuilderClass
]

{ #category : #'help topic creation' }
SystemReference class >> classAPIHelpBuilderClass: aClass [
	ClassAPIHelpBuilderClass := aClass
]

{ #category : #'help topic creation' }
SystemReference class >> forClass: aClass [
	|root topic |
	root := HelpTopic named: 'System reference for ', aClass name.
	topic := self classAPIHelpBuilderClass buildHelpTopicFrom: aClass.
	root addSubtopic: topic.
	^root
]

{ #category : #'help topic creation' }
SystemReference class >> hierarchyFor: aClass [
	 
	|root topic |
	root := HelpTopic named: 'System reference for ', aClass name.
	topic := self classAPIHelpBuilderClass new
					rootToBuildFrom: aClass;
					addSubclasses: true;
					addMethods: false;
					subclassesAsSeparateTopic: false;
					build;
					topicToBuild.
	root addSubtopic: topic.
	^root
]

{ #category : #'help topic creation' }
SystemReference class >> hierarchyWithMethodsFor: aClass [
	 
	|root topic |
	root := HelpTopic named: 'System reference for ', aClass name.
	topic := (self classAPIHelpBuilderClass new)
					rootToBuildFrom: aClass;
					addSubclasses: true;
					addMethods: true;
					subclassesAsSeparateTopic: true;
					build;
					topicToBuild.
	root addSubtopic: topic.
	^root
]
