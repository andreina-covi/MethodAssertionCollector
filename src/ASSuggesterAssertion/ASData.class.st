Class {
	#name : #ASData,
	#superclass : #Object,
	#instVars : [
		'data',
		'regexsWithIds'
	],
	#category : #'ASSuggesterAssertion-Collector'
}

{ #category : #accessing }
ASData >> associations [ 
	^ data associations
]

{ #category : #accessing }
ASData >> at: association at: string put: collection [
	self assert: association notNil.
	self assert: (string notNil and: [ string notEmpty ]).
	data
		at: association
		ifAbsentPut: [ Dictionary new ].
		"ifAbsent: [ self error: 'Error to add the collection. review the data' ]."
	(data at: association)
		at: string
		ifAbsentPut: [ OrderedCollection new ].
	((data at: association) at: string) addAll: collection
]

{ #category : #accessing }
ASData >> collectionAt: association [
	^ (data at: association) values
]

{ #category : #initialization }
ASData >> initialize [ 
	data := Dictionary new
]

{ #category : #testing }
ASData >> isEmpty [ 
	^ data isEmpty
]

{ #category : #accessing }
ASData >> process [
	| dict |
	dict := Dictionary new.
	data associations
		do: [ :assoc | 
			| res freqs |
			"col := self collectionAt: assoc key."
			freqs := assoc value associations
				flatCollect: [ :ass | 
					ass value
						collect: [ :ast | 
							| fCode visitor |
							visitor := ASSelectorCollectorVisitor new.
							visitor newVariableName: assoc key key.
							ast acceptVisitor: visitor.
							fCode := ast formattedCode.
							visitor revertVariableName.
							ast acceptVisitor: visitor.
							fCode ] ].
			"freqs := visitor collection."
			res := Dictionary new.
			freqs
				do:
					[ :string | res at: string ifAbsentPut: [ freqs occurrencesOf: string ] ].
			dict
				at: assoc key key
				put:
					(res associations
						sort: [ :assoc1 :assoc2 | assoc1 value > assoc2 value ]) ].
	^ dict
]

{ #category : #accessing }
ASData >> regexsWithIds [
	regexsWithIds
		ifNil: [ regexsWithIds := OrderedCollection new
				add: 'collection' -> '\w*[cC]ollection\w*';
				add: 'array' -> '\w*[aA]rray\w*';
				add: 'string' -> '\w*[sS]tring\w*';
				add: 'group' -> '\w*[gG]roup\w*';
				add: 's' -> '\w+s$';
				add: 'index' -> '\w*[iI]ndex\w*';
				add: 'number' -> '\w*[nN]umber\w*';
				add: 'integer' -> '\w*[iI]nteger\w*';
				add: 'position' -> '\w*[pP]osition\w*';
				yourself ].
	^ regexsWithIds
]
