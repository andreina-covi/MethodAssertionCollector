Class {
	#name : #ASHTMLFormatter,
	#superclass : #RBSimpleFormatter,
	#instVars : [
		'assertions',
		'colorize'
	],
	#category : #ASCollectorData
}

{ #category : #formatting }
ASHTMLFormatter class >> format: aParseTree withAssertions: collection [
	^ self new
		indent: 0;
		assertions: collection;
		format: aParseTree
]

{ #category : #accessing }
ASHTMLFormatter >> assertions: collection [
	(collection isCollection and: [ collection notEmpty ])
		ifFalse: [ ^ self ].
	assertions := WaitfreeQueue new.
	collection do: [ :item | assertions nextPut: item ]
]

{ #category : #'private-formatting' }
ASHTMLFormatter >> formatMethodPatternFor: aMethodNode [
	aMethodNode arguments
		ifEmpty: [ codeStream nextPutAll: ('<b>', aMethodNode selector, '</b>') ]
		ifNotEmpty: [ self privateFormatMethodPatternMonoLineFor: aMethodNode ]
]

{ #category : #'private-formatting' }
ASHTMLFormatter >> formatSelectorAndArguments: aMessageNode firstSeparator: firstBlock restSeparator: restBlock [
	aMessageNode isUnary
		ifTrue: [ self space.
			codeStream nextPutAll: aMessageNode selector ]
		ifFalse: [ aMessageNode selectorParts
				with: aMessageNode arguments
				do: [ :selector :argument | 
					self space.
					self
						indentAround: [ colorize
								ifTrue: [ codeStream
										nextPutAll: '<span style="color:#6495ed">' , selector , '</span>' ]
								ifFalse: [ codeStream
										nextPutAll: '<span style="color:#b7d4d3">' , selector , '</span>' ].
							self handleLineForArgument: argument ] ] ]
]

{ #category : #initialization }
ASHTMLFormatter >> initialize [
	super initialize.
	colorize := false
]

{ #category : #private }
ASHTMLFormatter >> newLines: anInteger [
	|size|
	anInteger + self indentString size = 0
		ifTrue: 
			[ codeStream space ].
	anInteger
		timesRepeat: 
			[ codeStream nextPutAll:'<br/>' ].
	lineStart := codeStream position.
	size := 20 * self indent.
	codeStream nextPutAll:' <b style="padding-left: ', size asString,'px;"></b>'.
]

{ #category : #private }
ASHTMLFormatter >> privateFormatMethodPatternMonoLineFor: aMethodNode [
	self
		with: aMethodNode selectorParts
		and: aMethodNode arguments
		do: [:key :arg | 
			codeStream nextPutAll: ('<b>',key,'</b>').
			self space.
			self visitNode: arg ]
		separatedBy: [ self space ]	
]

{ #category : #visiting }
ASHTMLFormatter >> visitMessageNode: aMessageNode [
	(aMessageNode selector = #assert:
		and: [ assertions notNil
				and: [ assertions peek formattedCode = aMessageNode formattedCode ] ])
		ifTrue: [ assertions nextOrNil ifNotNil: [ colorize := true ] ].
	"colorize := true ]
		ifFalse: [ colorize := false ]."
	self
		visitNode: aMessageNode receiver;
		formatSelectorAndArguments: aMessageNode
	"colorize := false"
]

{ #category : #visiting }
ASHTMLFormatter >> visitVariableNode: aVariableNode [
	colorize
		ifTrue: [ codeStream
				nextPutAll: '<span style="color:#6495ed">' , aVariableNode name , '</span>' ]
		ifFalse: [ codeStream
				nextPutAll: '<span style="color:#b7d4d3">' , aVariableNode name , '</span>' ]
]
