Class {
	#name : #ASHTMLFormatter,
	#superclass : #RBSimpleFormatter,
	#category : #'ASSuggesterAssertion-Page'
}

{ #category : #public }
ASHTMLFormatter class >> format: aParseTree [
	^ self new
		indent: 0;
		format: aParseTree
]

{ #category : #'private-formatting' }
ASHTMLFormatter >> formatMethodPatternFor: aMethodNode [
	aMethodNode arguments
		ifEmpty: [ codeStream nextPutAll: ('<b>', aMethodNode selector, '</b>') ]
		ifNotEmpty: [ self privateFormatMethodPatternMonoLineFor: aMethodNode ]
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
ASHTMLFormatter >> visitVariableNode: aVariableNode [
	| variableName |
	variableName := aVariableNode name.
	(#('self' 'super' 'thisContext')
		anySatisfy: [ :e | e = variableName ])
		ifTrue: [ codeStream
				nextPutAll: '<span style="color:#2ECC71">' , variableName , '</span>' ]
		ifFalse: [ codeStream
				nextPutAll: '<span style="color:#6495ed">' , variableName , '</span>' ]
]
