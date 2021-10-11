Class {
	#name : #ASRecommendation,
	#superclass : #Object,
	#instVars : [
		'dictRegex'
	],
	#category : #ASCollectorData
}

{ #category : #accessing }
ASRecommendation >> dictRegex [ 
	dictRegex ifNil: [ 
		dictRegex := Dictionary new 
		at: '\w*[cC]ollection\w*|\w+s$'
		put: (OrderedCollection new 
			add: 'isCollection';
			add: 'allSatisfy:';
			add: 'anySatisfy:';
			yourself
		);
		at: '\w*[cC]ollection\w*|\w*[sS]tring\w*|\w*[gG]roup\w*|\w+s$'
		put: (OrderedCollection new 
			add: 'isEmpty';
			add: 'isNotEmpty';
			yourself);
		at: '\w+s$' 
		put: (Array with: 'includes:');
		at: '\w*[iI]ndex\w*|\w*[nN]umber\w*|\w*[iI]nteger\w*|\w*[pP]osition\w*' 
		put: (OrderedCollection new
			add: '> 0';
			add: '> 1';
			add: '>= 0';
			add: 'isZero';
			add: 'isZero not';
			add: 'between: 0 and: X';
			add: 'between: 1 and: X';
			add: 'between: 0 and: X size';
			add: 'between: 1 and: X size';
			yourself
		);
		at: '\w+' put: (OrderedCollection new 
			add: 'isKindOf:';
			yourself);
		yourself	
	].
	^ dictRegex 
]

{ #category : #'as yet unclassified' }
ASRecommendation >> suggestAssertion: string [
	^ (self dictRegex associations 
		select: [ :assoc | string matchesRegex: assoc key])
		flatCollect: [:assoc | 
			assoc value collect: [ :assrt |
				String streamContents: [ :str |
					str nextPutAll: string;
					nextPut: Character cr;
					nextPutAll: assrt ] ] ]
]
