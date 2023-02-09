Class {
	#name : #MiBasicQueriesHolder,
	#superclass : #MiAbstractQueriesHolder,
	#instVars : [
		'classes',
		'packages'
	],
	#category : #'MooseIDE-Preview-Queries'
}

{ #category : #testing }
MiBasicQueriesHolder class >> canBeAppliedOnModel: aMooseModel [

	^ true
]

{ #category : #accessing }
MiBasicQueriesHolder >> classes [

	^ classes
]

{ #category : #accessing }
MiBasicQueriesHolder >> classes: anObject [

	classes := anObject
]

{ #category : #'queries - class' }
MiBasicQueriesHolder >> classesWithANumberOfAttributesSupTo: aNumber [
		<query>
	^ DQueryResult new
		  name: 'Classes with more than X attributes';
		  group: 'Classes';
		  queryBlock: [ 
			  self classes select: [ :c | c attributes size > aNumber ] ] ;
		  yourself
]

{ #category : #'queries - class' }
MiBasicQueriesHolder >> classesWithANumberOfMethodsSupTo: aNumber [
		<query>
	^ DQueryResult new
		  name: 'Classes with more than X methods';
		  group: 'Classes';
		  queryBlock: [ 
			  self classes select: [ :c | c methods  size > aNumber ] ] ;
		  yourself
]

{ #category : #initialization }
MiBasicQueriesHolder >> initializeEntities [

	classes := mooseModel allModelClasses reject: [ :c | 
		           c isException or: [ c isAnonymousClass ] ].
	
	packages := mooseModel allModelPackages .
]

{ #category : #'queries - packages' }
MiBasicQueriesHolder >> leafPackages [
		<query>
	^ DQueryResult new
		  name: 'Leaf Packages';
		  group: 'Packages';
		  queryBlock: [ 
			  self packages reject: [ :p | p children anySatisfy: [ :c | c isPackage ] ] ];
		  yourself
]

{ #category : #accessing }
MiBasicQueriesHolder >> packages [

	^ packages
]

{ #category : #accessing }
MiBasicQueriesHolder >> packages: anObject [

	packages := anObject
]

{ #category : #'queries - packages' }
MiBasicQueriesHolder >> packagesWithANumberOfClassesSupTo: aNumber [
		<query>
	^ DQueryResult new
		  name: 'Packages with more than X classes';
		  group: 'Packages';
		  queryBlock: [ 
			  self packages select: [ :p | (p types select: #isClass) size > aNumber ] ] ;
		  yourself
]
