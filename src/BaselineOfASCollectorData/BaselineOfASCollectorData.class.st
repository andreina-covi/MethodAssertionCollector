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
		spec package: 'ASCollectorData' with: [ spec requires: #( 'NeoCSV' ) ]
	]
]
