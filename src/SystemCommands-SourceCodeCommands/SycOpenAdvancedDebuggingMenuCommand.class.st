"
I am a command to open the advanced debugging menu after a right click on the source code.
I show in the menu all commands annotated by SycAdvancedDebuggingMenuActivation
"
Class {
	#name : #SycOpenAdvancedDebuggingMenuCommand,
	#superclass : #SycOpenContextMenuCommand,
	#category : #'SystemCommands-SourceCodeCommands'
}

{ #category : #execution }
SycOpenAdvancedDebuggingMenuCommand >> activationStrategy [
	^SycAdvancedDebuggingMenuActivation
]

{ #category : #'context menu' }
SycOpenAdvancedDebuggingMenuCommand >> cmCommandClass [

	^ SycSourceCodeCmCommand
]

{ #category : #accessing }
SycOpenAdvancedDebuggingMenuCommand >> defaultMenuIconName [
	^ #smallDebug
]

{ #category : #accessing }
SycOpenAdvancedDebuggingMenuCommand >> defaultMenuItemName [

	^ 'Debugging'
]
