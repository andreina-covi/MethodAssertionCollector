Class {
	#name : #ASPage,
	#superclass : #SBSRootComponent,
	#instVars : [
		'sourceCode',
		'updatedText',
		'recommender',
		'newCode',
		'assertions'
	],
	#category : #ASCollectorData
}

{ #category : #testing }
ASPage class >> canBeRoot [
	^ true
]

{ #category : #accessing }
ASPage class >> contextRoot [

	^ 'assertion'
]

{ #category : #initialization }
ASPage >> initialize [
	super initialize.
	sourceCode := ''.
	newCode := ''.
	updatedText := false.
	recommender := ASRecommendator new.
	assertions := OrderedCollection new
]

{ #category : #rendering }
ASPage >> renderContentOn: html [
	html
		form: [ html
				containerFluid: [ html
						break;
						break.
					html
						heading: 'Smalltalk - Assertion suggestion tool';
						horizontalRule.
					html listGroup beHorizontal
						with: [ html listGroupItem
								flexFill;
								with: [ html textArea
										style: 'height: 400px; min-width: 100%';
										value: sourceCode;
										callback: [ :text | 
											text ~= sourceCode
												ifTrue: [ updatedText := true ].
											sourceCode := text ] ].
							html listGroupItem
								flexFill;
								with: [ html paragraph
										style: 'height: 400px; min-width: 100%';
										with: [ updatedText
												ifTrue: [ html html: (ASHTMLFormatter format: newCode withAssertions: assertions) ] ] ] ].
					html break.
					html formButton bePrimary
						callback: [ self suggestAssertions ];
						with: 'Suggest assertions' ] ]
]

{ #category : #hooks }
ASPage >> style [ 
	^ ''
]

{ #category : #'as yet unclassified' }
ASPage >> suggestAssertions [
	| ast |
	ast := RBParser parseMethod: sourceCode.
	assertions := self suggestAssertions: (ast arguments collect: #name).
	self updatePage: ast
]

{ #category : #'as yet unclassified' }
ASPage >> suggestAssertions: collection [
	^ collection
		flatCollect: [ :string | recommender suggestAssertion: string ]
]

{ #category : #updating }
ASPage >> updatePage: ast [
	(assertions isCollection and: [ assertions notEmpty ])
		ifFalse: [ newCode := ast.
			^ self ].
	ast body addNodesFirst: assertions.
	newCode := ast	"RBSimpleFormatter format:"
]
