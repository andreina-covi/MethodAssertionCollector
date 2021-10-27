Class {
	#name : #ASSelectorCollectorVisitor,
	#superclass : #ASVisitor,
	#instVars : [
		'variableName',
		'oldVariableName'
	],
	#category : #'ASSuggesterAssertion-Visitor'
}

{ #category : #'instance creation' }
ASSelectorCollectorVisitor >> newVariableName: string [ 	
	variableName := string
]

{ #category : #'as yet unclassified' }
ASSelectorCollectorVisitor >> revertVariableName [
	variableName := oldVariableName 
]

{ #category : #visiting }
ASSelectorCollectorVisitor >> visitMessageNode: messageNode [
	self visitNode: messageNode receiver.
	messageNode arguments
		do:
			[ :each | self visitNode: each ]
]

{ #category : #visiting }
ASSelectorCollectorVisitor >> visitSequenceNode: sequenceNode [ 
	sequenceNode statements do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
ASSelectorCollectorVisitor >> visitVariableNode: variableNode [
oldVariableName ifNil: [ 
	oldVariableName := variableNode name ].
	variableNode name: variableName
]
