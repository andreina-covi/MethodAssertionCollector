Class {
	#name : #BaselineOfASCollectorData,
	#superclass : #BaselineOf,
	#category : #BaselineOfASCollectorData
}

{ #category : #baselines }
BaselineOfASCollectorData >> baseline: spec [
	
	<baseline>
	spec for: #common do: [ 
		spec package: 'ASCollectorData'
	]
]
