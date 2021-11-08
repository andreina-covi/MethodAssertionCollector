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
	#category : #'ASSuggesterAssertion-Page'
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
	| footer |
	html
		form: [ html
				containerFluid: [ html
						break;
						break.
					html
						heading: 'Smalltalk - Assertion suggestion tool';
						text:
							'This tool generates assertions according to the names of the arguments of a method. Enter a Smalltalk method in the left pane.';
						horizontalRule.
					html row
						with: [ html column variableWidth
								with: [ html textArea
										style: 'min-height: 500px; min-width: 100%; overflow:auto';
										value: sourceCode;
										callback: [ :text | 
											text ~= sourceCode
												ifTrue: [ updatedText := true ].
											sourceCode := text ] ].
							html column variableWidth
								with: [ html paragraph
										style: 'height: 500px; min-width: 100%; overflow:auto';
										with: [ updatedText
												ifTrue: [ html html: (ASHTMLFormatter format: newCode) ] ] ] ].
					html break.
					html formButton bePrimary
						callback: [ self suggestAssertions ];
						with: 'Suggest assertions' ] ].
	footer := html tag: 'footer'.
	footer attributes addClass: 'text-center text-lg-start text-muted'.
	footer
		with: [ html text: '© 2021 '.
			html anchor targetBlank 
				class: 'text-reset fw-bold';
				url: 'https://www.uchile.cl';
				with: 'Universidad de Chile'.
			html text: ' - '.
			html anchor targetBlank 
				class: 'text-reset fw-bold';
				url: 'http://objectprofile.com/';
				with: 'ObjectProfile' ]
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
	^ (collection
		flatCollect: [ :string | recommender suggestAssertions: string ]) collect: [ :str | RBParser parseExpression: str ]
]

{ #category : #updating }
ASPage >> updatePage: ast [
	(assertions isCollection and: [ assertions notEmpty ])
		ifFalse: [ newCode := ast.
			^ self ].
	ast body addNodesFirst: assertions.
	newCode := ast
]
