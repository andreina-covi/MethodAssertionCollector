Class {
	#name : #ASSelectorVisitor,
	#superclass : #ASVisitor,
	#instVars : [
		'groups',
		'equalVarname',
		'additionCollection',
		'varname',
		'unarySelectors'
	],
	#category : #'ASSuggesterAssertion-Visitor'
}

{ #category : #accessing }
ASSelectorVisitor >> groups [ 
	^ groups
]

{ #category : #initialization }
ASSelectorVisitor >> initialize [
	groups := OrderedCollection new.
	equalVarname := false.
	additionCollection := OrderedCollection new.
	unarySelectors := Set new
]

{ #category : #accessing }
ASSelectorVisitor >> varname: string [
	varname := string
]

{ #category : #visiting }
ASSelectorVisitor >> visitMessageNode: node [
	"(node receiver isVariable and: [ node receiver name = 'someShapes' ])
		ifTrue: [ self halt ]."

	(node isUnary and: [ node receiver isVariable ])
		ifTrue: [ self visitNode: node receiver.
			equalVarname
				ifTrue: [ groups add: node.
					additionCollection add: true.
					unarySelectors add: node selector.
					^ self ] ]
		ifFalse: [ (((node receiver isMessage
				and: [ #(#and: #or:) includes: node selector ])
				or: [ node receiver isVariable
						and: [ (#(#and: #or:) includes: node selector) not ] ])
				and: [ node selector numArgs = 1
						and: [ node arguments first isLiteralNode
								or: [ node arguments first isBlock ] ] ])
				ifTrue: [ | set |
					self visitNode: node receiver.
					self visitNode: node arguments first.
					set := additionCollection asSet.
					(equalVarname and: [(set isEmpty or: [ set size = 1 and: [ set includes: true ] ])])
						ifTrue: [ groups add: node.
							additionCollection add: true.
							^ self ] ] ].
	additionCollection add: false.
	equalVarname := false
]

{ #category : #visiting }
ASSelectorVisitor >> visitSelfNode: node [
	equalVarname := node name = varname
]

{ #category : #visiting }
ASSelectorVisitor >> visitSequenceNode: sequenceNode [
	sequenceNode statements size = 1
		ifFalse: [ additionCollection add: false.
			^ self ].
	sequenceNode statements do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
ASSelectorVisitor >> visitVariableNode: node [
	equalVarname := node name = varname
]
