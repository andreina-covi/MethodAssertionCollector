Class {
	#name : #ASDataCollector,
	#superclass : #Object,
	#instVars : [
		'packageScope'
	],
	#category : #'ASSuggesterAssertion-Collector'
}

{ #category : #'as yet unclassified' }
ASDataCollector >> collectAndSaveData: filename [
	self saveOnCsvFile: filename data: self collectData
]

{ #category : #'as yet unclassified' }
ASDataCollector >> collectAssertions: class ofMethod: selector given: set [
	| aBehavior originalMethod ast variables methodVars |
	aBehavior := class instanceSide.
	originalMethod := aBehavior compiledMethodAt: selector.
	ast := originalMethod ast.
	variables := Set new.
	variables addAll: ((ast arguments collect: #name) collect: [:arg | 'argument' -> arg ]).
	variables addAll: ((class instanceVariables collect: #name) 
		collect: [ :instVar | 'instanceVar' -> instVar ]).
	variables addAll: (ast body temporaryNames collect: [:tempName | 'temporaryVar' -> tempName ]).
	^ ast body statements select: [:stm | 
		stm isMessage and: [ (stm selector includesSubstring: 'assert:' ) 
		and: [
			methodVars := variables select: [ :assoc | self find: assoc on: stm ].
			methodVars notEmpty ] ] ]
	thenCollect: [ :stm | | vs |
		vs := methodVars collect: #value.
		set addAll: vs.
		OrderedCollection new 
			add: vs asArray;
			add: stm arguments first formattedCode;
			add: stm formattedCode; 
			add: selector;
			add: methodVars asArray; yourself ].
]

{ #category : #'as yet unclassified' }
ASDataCollector >> collectAssertionsOfClass: class with: set [
	^ class selectors
		flatCollect:
			[ :selector | self collectAssertions: class ofMethod: selector given: set ]
]

{ #category : #'as yet unclassified' }
ASDataCollector >> collectData [
	| classes collection vars |
	self assert: packageScope notEmpty.
	classes := self selectClassesOfPackages.
	collection := OrderedCollection new.
	vars := Set new.
	classes
		do:
			[ :cls | collection addAll: (self collectAssertionsOfClass: cls with: vars) ].
	^ collection
]

{ #category : #'as yet unclassified' }
ASDataCollector >> filterAssertionBody: collection [
	^ (collection collect: [ :assoc | 
		Array with: assoc key with: assoc value arguments first formattedCode ]) asSet
]

{ #category : #'as yet unclassified' }
ASDataCollector >> find: assoc on: node [
	(node isSelector or: [ node isLiteral ]) ifTrue: [
		^ node value = assoc value
		].
	node isVariable ifTrue: [ ^ node name = assoc value ].
	node isMessage ifTrue: [ 
		^ (self find: assoc on: node receiver) 
		or: [ node arguments 
			detect: [ :arg | self find: assoc on: arg ] 
			ifFound: [ true ] 
			ifNone: [ false ] ] ].
	node isBlock ifTrue: [ 
		^ node body statements detect: [ :stm | 
			self find: assoc on: stm ]
		ifFound: [ :stm | true ]
		ifNone: [ false ]
		 ].
	^ false
]

{ #category : #initialization }
ASDataCollector >> initialize [ 
	packageScope := ''
]

{ #category : #accessing }
ASDataCollector >> packageScope: string [
	self assert: (string notNil and: [string notEmpty ]).
	packageScope := string 
]

{ #category : #'as yet unclassified' }
ASDataCollector >> saveOnCsvFile: filename data: data [
	filename asFileReference ensureDelete.
	filename asFileReference writeStreamDo: [ :writeStream |
		(NeoCSVWriter on: writeStream)
 			writeHeader: #(VarNames Assertion FullAssertion Method InfoVariables);
			nextPutAll: data ]
]

{ #category : #'as yet unclassified' }
ASDataCollector >> selectClassesOfPackages [
	| packages |
	self
		assert: packageScope notEmpty
		description: 'Define the package scope'.
	packages := RPackageOrganizer default packages
		select: [ :p | packageScope match: p name asString ].
	^ (packages
		flatCollect: [ :package |
			| extensionNames |
			extensionNames := OrderedCollection new.
			package classes
				reject: [ :cl | 
					cl isTrait
						or: [ (extensionNames includes: cl name)
								or: [ cl isMeta or: [ cl isTestCase ] ] ] ] ]) asSet
		asOrderedCollection sort: [ :cl1 :cl2 | cl1 name < cl2 name ]
]

{ #category : #'as yet unclassified' }
ASDataCollector >> splitByArguments: collection [
	| col |
	col := OrderedCollection new.
	collection do: [ :assoc | 
		col addAll: (
			assoc key collect: [ :item | item -> assoc value ])
		 ].
	^ col
]
