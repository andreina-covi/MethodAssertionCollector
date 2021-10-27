Class {
	#name : #BaselineOfASCollectorData,
	#superclass : #BaselineOf,
	#category : #BaselineOfASCollectorData
}

{ #category : #baselines }
BaselineOfASCollectorData >> baseline: spec [
	
	<baseline>
	spec for: #common do: [ 
		spec
			baseline: 'NeoCSV'
			with: [ spec repository: 'github://svenvc/NeoCSV/repository' ].
		spec 
			baseline: 'Bootstrap4'
			with: [ spec repository: 'github://astares/Seaside-Bootstrap4:master/src' ].
		spec 
			baseline: 'DataFrame'
			with: [ spec repository: 'github://PolyMathOrg/DataFrame/src' ].
		spec package: 'ASCollectorData' with: [ spec requires: #( 'NeoCSV' 'Bootstrap4' 'DataFrame' ) ]
	]
]
