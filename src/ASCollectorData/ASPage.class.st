Class {
	#name : #ASPage,
	#superclass : #SBSRootComponent,
	#instVars : [
		'sourceCode',
		'updatedText',
		'result',
		'recommender'
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
	result := nil.
	updatedText := false.
	recommender := ASRecommendation new
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
						with: [ 
							html listGroupItem
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
												ifTrue: [ html html: (RBSimpleFormatter format: result ost) ] ] ] ].
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
	
	| ast assertions |
	ast := RBParser parseMethod: sourceCode.
	assertions := self suggestAssertions: ast arguments.
	self update: ast with: assertions
]

{ #category : #'as yet unclassified' }
ASPage >> suggestAssertions: collection [
	^ collection collect: [ :string |
		recommender suggestAssertion: string
		 ]
	
]
