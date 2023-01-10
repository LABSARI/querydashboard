"
I am a query holder for a Java model: Inovelan.
"
Class {
	#name : #MiDQueriesHolder,
	#superclass : #MiAbstractQueriesHolder,
	#instVars : [
		'appServiceUID',
		'classes',
		'entryPointService',
		'dcrServicesQuery',
		'remoteService'
	],
	#category : #'MooseIDE-Preview-Queries'
}

{ #category : #testing }
MiDQueriesHolder class >> canBeAppliedOnModel: aMooseModel [

	^ true
]

{ #category : #queries }
MiDQueriesHolder >> DCRServices [

	"Les services DCR."

	<query>
	^ DQueryResult new
		  name: 'Les services DCR.';
		  group: 'Services DCR';
		  description:
			  'Ces services sont des classes proposant des (sous)services aux clients utilisant le mécanisme de configuration impliquant les attributs de la classe AppServiceUID.';
		  queryBlock: [ 
			  | m |
			  m := entryPointService methods detect: [ :m1 | 
					       m1 name = 'doRpcRequest' ].
			  ((m outgoingReferences collect: [ :r | r referredType ]) 
				   selectAsSet: [ :c | 
					   c isStub not and: [ 
							   c mooseName beginsWith: 'com::inovelan::gwt::dcr::server' ] ])
				  asMooseGroup ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> DTOClasses [

	"Les classes qui héritent de BaseModelData."

	<query>
	^ DQueryResult new
		  name: 'Les classes qui héritent de BaseModelData.';
		  group: 'Modèles de données';
		  description:
			  'Objets de transfert de données (DTO) utilisés notamment pour le renvoie de résultats des services.';
		  queryBlock: [ 
			  | bmds |
			  bmds := ((FQStringQuery
				            property: #name
				            comparator: #=
				            valueToCompare: 'BaseModelData') runOn: mooseModel) 
				          select: #isClass.
			  bmds flatCollect: [ :bmd | bmd subclassHierarchy reject: #isStub ] ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> DTOClassesUsedOnlyInClientSide [

	"Les classes qui héritent de BaseModelData utilisées uniquement coté client."

	<query>
	^ DQueryResult new
		  name:
			  'Les classes qui héritent de BaseModelData utilisées uniquement coté client.';
		  group: 'Modèles de données';
		  description:
			  'Ce sont des modèles utilisées par des clients pour stocker des données nécessaires au fonctionnement d''un ou plusieurs clients.';
		  queryBlock: [ 
			  self DTOClasses result select: [ :bmd | 
					  bmd incomingReferences notEmpty and: [ 
							  bmd incomingReferences allSatisfy: [ :i | 
									  i referencer mooseName includesSubstring: 'client' ] ] ] ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> DTOClassesUsedOnlyInServerSide [

	"Les classes qui héritent de BaseModelData utilisées uniquement coté serveur."

	<query>
	^ DQueryResult new
		  name:
			  'Les classes qui héritent de BaseModelData utilisées uniquement coté serveur.';
		  group: 'Modèles de données';
		  queryBlock: [ 
			  self DTOClasses result reject: [ :bmd | 
					  bmd isDead or: [ 
							  bmd incomingReferences anySatisfy: [ :i | 
									  i referencer mooseName includesSubstring: 'client' ] ] ] ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> DTODeadClasses [

	"Les classes non utilisées qui héritent de BaseModelData."

	<query>
	^ DQueryResult new
		  name: 'Les classes non utilisées qui héritent de BaseModelData.';
		  group: 'Modèles de données';
		  queryBlock: [ self DTOClasses result select: #isDead ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> GWTServiceImplementations [

	"Les implémentations de services GWT."

	<query>
	^ DQueryResult new
		  browsers: { MiSystemComplexityBrowser };
		  name: 'Les implémentations de services GWT.';
		  group: 'Services GWT';
		  queryBlock: [ 
			  remoteService := ((FQStringQuery
				                     property: #name
				                     comparator: #=
				                     valueToCompare: 'RemoteServiceServlet') 
				                    runOn: mooseModel) first.
			  remoteService subclassHierarchy reject: #isStub ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> GWTServiceUtilClasses [

	"Les classes Util des services GWT."

	<query>
	^ DQueryResult new
		  name: 'Les classes Util des services GWT.';
		  group: 'Services GWT';
		  queryBlock: [ 
			  | services |
			  remoteService := ((FQStringQuery
				                     property: #name
				                     comparator: #=
				                     valueToCompare: 'RemoteService') runOn:
					                    mooseModel) first.
			  services := remoteService subclassHierarchy reject: [ :c | 
					              c isInterface not or: [ c isStub ] ].
			  services
				  select: [ :c | 
					  c types notEmpty and: [ 
							  c types anySatisfy: [ :t | t name = 'Util' ] ] ]
				  thenCollect: [ :c | c types detect: [ :t | t name = 'Util' ] ] ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> GWTServices [

	"Les services GWT."

	<query>
	^ DQueryResult new
		  name: 'Les services GWT.';
		  group: 'Services GWT';
		  queryBlock: [ 
			  remoteService := ((FQStringQuery
				                     property: #name
				                     comparator: #=
				                     valueToCompare: 'RemoteService') runOn:
					                    mooseModel) first.
			  remoteService subclassHierarchy select: #isInterface ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> GWTServicesWithoutServicePrefix [

	"Les services GWT dont le nom ne termine pas par 'Service'"

	<query>
	^ DQueryResult new
		  name:
			  'Les services GWT dont le nom ne termine pas par ''Service''.';
		  group: 'Convention de nommage';
		  queryBlock: [ 
			  remoteService subclassHierarchy select: [ :i | 
					  i isInterface and: [ (i name endsWith: 'Service') not ] ] ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> abstractClassesWithoutAbstractPrefix [

	"Les classes abstraites dont le nom ne commence pas par 'Abstract'"

	<query>
	^ DQueryResult new
		  name:
			  'Les classes abstraites dont le nom ne commence pas par ''Abstract''';
		  group: 'Convention de nommage';
		  queryBlock: [ 
			  mooseModel allModelClasses select: [ :c | 
					  c isAbstract notNil and: [ (c name beginsWith: 'Abstract') not ] ] ];
		  yourself
]

{ #category : #accessing }
MiDQueriesHolder >> appServiceUID [

	^ appServiceUID
]

{ #category : #queries }
MiDQueriesHolder >> appServiceUIDSecondaryAttributes [

	"Les attributs secondaires de AppServiceUID."

	<query>
	^ DQueryResult new
		  name: 'Les attributs secondaires de AppServiceUID.';
		  group: 'AppServiceUID';
		  queryBlock: [ 
			  | secondaryAttributes |
			  secondaryAttributes := appServiceUID attributes reject: [ :a | 
					                         a accessors anySatisfy: [ :acc | 
							                         (self rootClass: acc)
							                         = entryPointService ] ].
			  secondaryAttributes select: [ :a | 
					  (a accessors
						   reject: [ :acc | acc mooseName includesSubstring: 'client' ]
						   thenCollect: [ :acc | self rootClass: acc ]) asSet size = 1 ] ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> appServiceUIDSecondaryAttributesUsedBySeveralServerClasses [

	"Les attributs secondaires de AppServiceUID utilisés dans plusieurs classes du serveur."

	<query>
	^ DQueryResult new
		  name:
			  'Les attributs secondaires de AppServiceUID utilisés dans plusieurs classes du serveur.';
		  group: 'AppServiceUID';
		  queryBlock: [ 
			  | secondaryAttributes |
			  secondaryAttributes := appServiceUID attributes reject: [ :a | 
					                         a accessors anySatisfy: [ :acc | 
							                         (self rootClass: acc)
							                         = entryPointService ] ].
			  secondaryAttributes select: [ :a | 
					  (a accessors
						   reject: [ :acc | acc mooseName includesSubstring: 'client' ]
						   thenCollect: [ :acc | self rootClass: acc ]) asSet size >= 2 ] ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> appServiceUIDSecondaryAttributesUsedOnlyByServerClasses [

	"Les attributs secondaires de AppServiceUID utilisés uniquement par des classes du serveur."

	<query>
	^ DQueryResult new
		  name:
			  'Les attributs secondaires de AppServiceUID utilisés uniquement par des classes du serveur.';
		  group: 'AppServiceUID';
		  queryBlock: [ 
			  | secondaryAttributes result |
			  secondaryAttributes := appServiceUID attributes reject: [ :a | 
					                         a accessors anySatisfy: [ :acc | 
							                         (self rootClass: acc)
							                         = entryPointService ] ].
			  result := secondaryAttributes select: [ :a | 
					            a accessors size > 1 and: [ 
							            a accessors allSatisfy: [ :acc | 
									            (self rootClass: acc) = appServiceUID or: [ 
											            (acc mooseName includesSubstring: 'client') not ] ] ] ] ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> appServiceUIDUnusedAttributes [

	"Les attributs de AppServiceUID accédés une seule fois, c'est à dire non utilisés."

	<query>
	^ DQueryResult new
		  name:
			  'Les attributs de AppServiceUID accédés une seule fois, c''est à dire non utilisés.';
		  group: 'AppServiceUID';
		  queryBlock: [ 
			  appServiceUID attributes select: [ :a | 
					  a incomingAccesses size = 1 ] ];
		  yourself
]

{ #category : #accessing }
MiDQueriesHolder >> classes [

	^ classes
]

{ #category : #queries }
MiDQueriesHolder >> clientsUsingAppServiceUIDAttributes [

	"Les clients qui utilisent des attributs de AppServiceUID"

	<query>
	^ DQueryResult new
		  name: 'Les clients qui utilisent des attributs de AppServiceUID.';
		  group: 'AppServiceUID';
		  queryBlock: [ 
			  | attributes |
			  attributes := appServiceUID attributes select: [ :a | 
					                a accessors size > 1 and: [ 
							                a accessors anySatisfy: [ :acc | 
									                (self rootClass: acc) ~= appServiceUID and: [ 
											                acc mooseName includesSubstring: 'client' ] ] ] ].

			  (attributes flatCollectAsSet: [ :a | 
					   (a accessors asOrderedCollection
						    select: [ :acc | 
							    (self rootClass: acc) ~= appServiceUID and: [ 
									    acc mooseName includesSubstring: 'client' ] ]
						    thenCollect: [ :acc | self rootClass: acc ]) asSet
						   asOrderedCollection ]) asOrderedCollection ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> deadEnums [

	"Les énumérations non utilisées."

	<query>
	^ DQueryResult new
		  name: 'Les énumérations non utilisées.';
		  group: 'Enumérations';
		  queryBlock: [ mooseModel allEnums select: #isDead ];
		  yourself
]

{ #category : #accessing }
MiDQueriesHolder >> entryPointService [

	^ entryPointService
]

{ #category : #queries }
MiDQueriesHolder >> enumsUsedOnlyInClientSide [

	"Les énumérations utilisées uniquement coté client."

	<query>
	^ DQueryResult new
		  name: 'Les énumérations utilisées uniquement coté client.';
		  group: 'Enumérations';
		  queryBlock: [ 
			  mooseModel allEnums select: [ :e | 
					  e incomingReferences allSatisfy: [ :r | 
							  r referencer mooseName includesSubstring: 'client' ] ] ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> enumsWithoutEPrefix [

	"Les énumérations dont le nom ne commence pas par 'E'"

	<query>
	^ DQueryResult new
		  name: 'Les énumérations dont le nom ne commence pas par ''E''.';
		  group: 'Convention de nommage';
		  browsers: { 
				  MiArchitecturalMapBrowser.
				  MiQueriesBrowser };
		  queryBlock: [ 
			  mooseModel allEnums select: [ :e | 
					  ((e name beginsWith: 'E') and: [ (e name at: 2) isUppercase ])
						  not ] ];
		  yourself
]

{ #category : #initialization }
MiDQueriesHolder >> initializeEntities [

	classes := mooseModel allModelClasses reject: [ :c | 
		           c isAnonymousClass ].

	appServiceUID := ((FQStringQuery
		                   property: #name
		                   comparator: #=
		                   valueToCompare: 'AppServiceUID') runOn: classes)
		                 first.

	entryPointService := ((FQStringQuery
		                       property: #name
		                       comparator: #=
		                       valueToCompare: 'InterfaceGenericDCRImpl') 
		                      runOn: classes) first.
	remoteService := ((FQStringQuery
		                   property: #name
		                   comparator: #=
		                   valueToCompare: 'RemoteService') runOn:
		                  mooseModel allClasses) first
]

{ #category : #queries }
MiDQueriesHolder >> interfacesWithoutIPrefix [

	"Les interfaces dont le nom ne commence pas par 'I'"

	<query>
	^ DQueryResult new
		  name: 'Les interfaces dont le nom ne commence pas par ''I''.';
		  group: 'Convention de nommage';
		  queryBlock: [ 
			  mooseModel allModelClasses select: [ :c | 
					  c isInterface and: [ 
							  ((c name beginsWith: 'I') and: [ (c name at: 2) isUppercase ])
								  not ] ] ];
		  yourself
]

{ #category : #queries }
MiDQueriesHolder >> methodsAccessingMoreThan100Attributes [

	"Les méthodes avec plus de 100 accès à des attributs."

	<query>
	^ DQueryResult new
		  name: 'Les méthodes avec plus de 100 accès à des attributs.';
		  group: 'Méthodes';
		  queryBlock: [ 
			  (FQNumericQuery
				   property: #numberOfAccesses
				   comparator: #>
				   valueToCompare: 100) runOn: mooseModel allModelMethods ];
		  yourself
]

{ #category : #initialization }
MiDQueriesHolder >> rootClass: aMooseEntity [

	| pt |
	(aMooseEntity isMethod not and: [ 
		 aMooseEntity isClass not and: [ aMooseEntity isPackage ] ]) 
		ifTrue: [ ^ nil ].
	pt := aMooseEntity parents anyOne.
	(aMooseEntity isType and: [ pt isClass not and: [ pt isPackage ] ]) 
		ifTrue: [ ^ aMooseEntity ].
	^ self rootClass: pt
]
