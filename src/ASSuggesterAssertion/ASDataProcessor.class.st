Class {
	#name : #ASDataProcessor,
	#superclass : #Object,
	#instVars : [
		'data'
	],
	#classInstVars : [
		'instance'
	],
	#category : #'ASSuggesterAssertion-Collector'
}

{ #category : #accessing }
ASDataProcessor class >> instance [
	instance ifNil: [ instance := self new ].
	^ instance
]

{ #category : #'as yet unclassified' }
ASDataProcessor class >> instanceGiven: fileReference [ 
	self instance data isEmpty ifTrue: [ 
		instance processAndCreateData: fileReference
		 ].
	^ instance
]

{ #category : #initialization }
ASDataProcessor class >> resetInstance [
	instance := nil
]

{ #category : #'as yet unclassified' }
ASDataProcessor >> classifyByPatternOn: dataSerie [
	data regexsWithIds
		do: [ :association | 
			| varName |
			varName := dataSerie at: 'VarName'.
			(varName matchesRegex: association value)
				ifTrue: [ self
						processAndAddToData: (dataSerie at: 'Assertion')
						given: varName
						and: association ] ]
]

{ #category : #accessing }
ASDataProcessor >> data [ 
	^ data
]

{ #category : #'as yet unclassified' }
ASDataProcessor >> groupByUnaryMessage: ast given: string [
	| visitor |
	visitor := ASSelectorVisitor new varname: string.
	ast acceptVisitor: visitor.
	^ visitor groups
]

{ #category : #initialization }
ASDataProcessor >> initialize [
	data := ASData new 
	"Dictionary new"
]

{ #category : #'as yet unclassified' }
ASDataProcessor >> processAndAddToData: string1 given: string2 and: association [
	| ast collection |
	ast := RBParser parseExpression: string1.
	collection := self groupByUnaryMessage: ast given: string2.
	collection
		ifNotEmpty: [ data at: association at: string2 put: collection " ifAbsentPut: Dictionary new.
			(data at: string3)
				at: string2
				ifAbsentPut: [ OrderedCollection new ].
			((data at: string3) at: string2) addAll: collection" ]
]

{ #category : #'as yet unclassified' }
ASDataProcessor >> processAndCreateData: fileReference [
	| df |
	df := self readDataFrameFrom: fileReference.
	df asArrayOfRows do: [ :serie | self classifyByPatternOn: serie ].
	"data process"
]

{ #category : #'as yet unclassified' }
ASDataProcessor >> readDataFrameFrom: aFileReference [
	self assert: [ aFileReference notNil and: [ aFileReference exists ] ].
	^ DataFrame readFromCsv: aFileReference
]
