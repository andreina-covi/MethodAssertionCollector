Class {
	#name : #ASVisitor,
	#superclass : #Object,
	#category : #'ASSuggesterAssertion-Visitor'
}

{ #category : #visiting }
ASVisitor >> visitBlockNode: node [
	self visitNode: node body
]

{ #category : #visiting }
ASVisitor >> visitLiteralValueNode: literalNode [
	
]

{ #category : #visiting }
ASVisitor >> visitMessageNode: node [
]

{ #category : #visiting }
ASVisitor >> visitNode: node [
	node acceptVisitor: self
]

{ #category : #visiting }
ASVisitor >> visitSelfNode: node [
]

{ #category : #visiting }
ASVisitor >> visitSequenceNode: sequenceNode [
]

{ #category : #visiting }
ASVisitor >> visitVariableNode: node [
]
