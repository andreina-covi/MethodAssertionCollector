Class {
	#name : #ASRecommendator,
	#superclass : #Object,
	#instVars : [
		'dictRegex',
		'data',
		'dataProcessor',
		'fileReference',
		'dataOccurrences',
		'rules'
	],
	#category : #'ASSuggesterAssertion-Suggester'
}

{ #category : #'as yet unclassified' }
ASRecommendator >> assertionsOf: collection [ 
	^ collection collect: [ :str |
		String streamContents: [ :stream |
			stream nextPutAll: 'self assert: [';
				nextPutAll: str;
				nextPut: $]
			 ]
		 ]
]

{ #category : #'as yet unclassified' }
ASRecommendator >> assertionsOfCollectionsOf: block given: string2 [
	^ self
		assertionsOf:
			((block value: 'x')
				collect: [ :msg | 
					String
						streamContents: [ :stream | 
							stream
								nextPutAll: string2;
								nextPut: Character space;
								nextPutAll: 'allSatisfy: [ :x | ';
								nextPutAll: msg;
								nextPut: $] ] ])
]

{ #category : #'as yet unclassified' }
ASRecommendator >> collectAssertions: string1 given: string2 [
	^ self assertionsOf: (self collectMessages: string1 given: string2)
]

{ #category : #'as yet unclassified' }
ASRecommendator >> collectAssertionsOfCollectionsOf: string1 given: string2 [
	| regexs |
	regexs := self rules keys
		select: [ :key | string1 matchesRegex: key ].
	^ regexs
		ifEmpty: [ self
				assertionsOfCollectionsOf: [ :str | self collectMessages: string1 given: str ]
				given: string2 ]
		ifNotEmpty: [
			self
				assertionsOfCollectionsOf: (rules at: regexs first)
				given: string2 ]
]

{ #category : #'as yet unclassified' }
ASRecommendator >> collectMessages: string1 given: string2 [
	^ self
		rulesAt: string1
		ifPresent: [ :block | block value: string2 ]
		ifAbsent: [ | selectors |
			selectors := (Smalltalk allClasses
				select: [ :cls | 
					| bool intervals matcher regex clsName |
					clsName := cls name.
					bool := string1 matchesRegexIgnoringCase: '\w*' , clsName , '\w*'.
					bool
						ifFalse: [ matcher := RxMatcher forString: '^[A-Z]+'.
							intervals := matcher matchingRangesIn: clsName.
							intervals
								ifEmpty: [ bool := false ]
								ifNotEmpty: [ regex := clsName copyFrom: intervals first last to: clsName size.
									bool := string1
										matchesRegexIgnoringCase: '\w*' , regex , '\w*' ] ].
					bool ])
				flatCollect: [ :cls | 
					cls methods
						select: [ :mth | (#(#testing #queries) includes: mth protocol) and: [ mth selector isUnary ] ]
						thenCollect: [ :mth | mth selector ] ].
			self messagesGiven: selectors and: string2 ]
]

{ #category : #'as yet unclassified' }
ASRecommendator >> messagesGiven: collection and: string [
	^ collection
		collect: [ :str | 
			String
				streamContents: [ :stream | 
					stream
						nextPutAll: string;
						nextPut: Character space;
						nextPutAll: str ] ]
]

{ #category : #'as yet unclassified' }
ASRecommendator >> messagesOfCollection: string [
	^ self
				messagesGiven: #('isNotNil' 'isCollection' 'isNotEmpty' 'isEmpty')
				and: string
]

{ #category : #'as yet unclassified' }
ASRecommendator >> messagesOfInteger: string [
	^ self
				messagesGiven: #('isInteger' '> 0' '>= 0' 'isNotNil')
				and: string
]

{ #category : #'as yet unclassified' }
ASRecommendator >> messagesOfString: string [
	^ self messagesGiven: #('isNotNil' 'isString' 'isNotEmpty') and: string
]

{ #category : #'as yet unclassified' }
ASRecommendator >> messagessOfNumber: string [
	^ self messagesGiven: #('isNumber' 'isNotNil' '> 0' '>= 0') and: string
]

{ #category : #accessing }
ASRecommendator >> rules [
	rules
		ifNil: [ rules := Dictionary new
				at: '\w*[iI]nteger\w*'
					put: [ :string | self messagesOfInteger: string ];
				at: '\w*[iI]ndex\w*'
					put: [ :string | self messagesOfInteger: string ];
				at: '\w*[nN]umber\w*'
					put: [ :string | self messagessOfNumber: string ];
				at: '\w*[sS]tring\w*'
					put: [ :string | self messagesOfString: string ];
				at: '\w*[cC]ollection\w*'
					put: [ :string | self messagesOfCollection: string ];
				yourself ].
	^ rules
]

{ #category : #accessing }
ASRecommendator >> rulesAt: string ifPresent: block1 ifAbsent: block2 [
	^ self rules associations detect: [ :assoc | string matchesRegex: assoc key ] 
	ifFound: [ :assoc | block1 value: assoc value ]
	ifNone: [ block2 value ]
]

{ #category : #'as yet unclassified' }
ASRecommendator >> suggestAssertions: string [
	| matcher ranges coll |
	matcher := RxMatcher forString: '[cC]ollection[oO]f'.
	ranges := matcher matchingRangesIn: string.
	ranges
		ifNotEmpty: [ ^ (self collectAssertions: 'collection' given: string)
				union:
					(self
						collectAssertionsOfCollectionsOf: (string copyFrom: ranges last last to: string size)
						given: string) ].
	(string matchesRegex: '\w+s$')
		ifTrue: [ | colType |
			colType := self
				collectAssertionsOfCollectionsOf: (string copyFrom: 1 to: string size - 1)
				given: string.
			colType
				ifNotEmpty: [ coll := (self collectAssertions: 'collection' given: string)
						union: colType ] ].
	(coll isNil or: [ coll isEmpty ])
		ifTrue: [ coll := self collectAssertions: string given: string ].
	^ coll
]
