Class {
	#name : #ClassUsedInInstructionStreamTest,
	#superclass : #SuperClassUsedInInstructionStreamTest,
	#instVars : [
		'expectedValue',
		'aProcess'
	],
	#category : #'Kernel-Tests-Extended-Methods'
}

{ #category : #examples }
ClassUsedInInstructionStreamTest >> aMethodSuspendedBeforeTheTerminateOfAnotherProcess [

	Processor activeProcess suspend.

	aProcess terminate.
	
	expectedValue := 42.
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> aMethodWithHalt [

	<haltOrBreakpointForTesting>

	Processor activeProcess suspend.
	self halt.
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> aMethodWithMNU [

	Processor activeProcess suspend.
	self iAmAnMNUMessage.
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> aMethodWithMustBeBooleanMNU [

	Processor activeProcess suspend.

	^ 2 ifTrue: [ 5 ] ifFalse: [ 7 ]
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> aMethodWithSuspendAndReturnANumber [

	Processor activeProcess suspend.
	^ 42.
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> aSuperMethod: anInteger with: anotherInteger [

	^ self error
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> callingAMethodSuspendedBeforeTheTerminateOfAnotherProcess [

	self aMethodSuspendedBeforeTheTerminateOfAnotherProcess
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> callingAMethodWithHalt [

	self aMethodWithHalt
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> callingAMethodWithMNU [

	self aMethodWithMNU
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> callingAMethodWithMustBeBooleanMNU [

	self aMethodWithMustBeBooleanMNU
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> callingAMethodWithSuspendAndReturnANumber [

	^ self aMethodWithSuspendAndReturnANumber
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> expectedValue [

	^ expectedValue
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> methodWithASuperBlock [

	^ [ super aSuperMethod: 1 with: 2 ]
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> methodWithASuperBlockWithoutArguments [

	^ [ super yourself ]
]

{ #category : #'instance creation' }
ClassUsedInInstructionStreamTest >> newMethodWithALotOfLiteralsToTestExtensions [

	| anArray |

	anArray := { 10. 11. 12. 13. 14. 15. 16. 17. 18. 19. 20. 21. 22. 23.
	           24. 25. 26. 27. 28. 29. 30. 31. 32. 33. 34. 35. 36. 37. 38.
	           39. 40. 41. 42. 43. 44. 45. 46. 47. 48. 49. 50. 51. 52. 53.
	           54. 55. 56. 57. 58. 59. 60. 61. 62. 63. 64. 65. 66. 67. 68.
	           69. 70. 71. 72. 73. 74. 75. 76. 77. 78. 79. 80. 81. 82. 83.
	           84. 85. 86. 87. 88. 89. 90. 91. 92. 93. 94. 95. 96. 97. 98.
	           99. 100. 101. 102. 103. 104. 105. 106. 107. 108. 109. 110.
	           111. 112. 113. 114. 115. 116. 117. 118. 119. 120. 121. 122.
	           123. 124. 125. 126. 127. 128. 129. 130 }.

	Array
		with: 'Those '
		with: 'are'
		with: 'a '
		with: ' lot'
		with: ' of '
		with: ' literals'
]

{ #category : #accessing }
ClassUsedInInstructionStreamTest >> process: aValue [ 
	
	aProcess := aValue
]

{ #category : #examples }
ClassUsedInInstructionStreamTest >> valueOfBlockWithSupersend [

	expectedValue := self methodWithASuperBlock value
]
