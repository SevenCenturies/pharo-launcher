"
I can be used to import an image into Pharo Launcher.

I move the image file and its associated changes file to the default location of Pharo Launcher images store.
"
Class {
	#name : #PhLImportImageCommand,
	#superclass : #PhLImageCommand,
	#instVars : [
		'importSiblings'
	],
	#category : #'PharoLauncher-Core-Commands'
}

{ #category : #converting }
PhLImportImageCommand >> asSpecCommand [
	^ super asSpecCommand
		iconName: #smallLoadProject;
		shortcutKey: $y meta;
		beDisabledWhenCantBeRun;
		yourself
]

{ #category : #'ui interaction' }
PhLImportImageCommand >> chooseNewImageNameFor: anImageName [
	^ self imagesPresenter newRequest
		title: 'An image with the name ', anImageName , ' already exists. Please choose a new name:';
		initialAnswer: (self imagesPresenter imageRepository makeUniqueImageName: anImageName);
		validateAnswer: [ :answer | (self imagesPresenter imageRepository hasImageNamed: answer) not ];
		request
]

{ #category : #executing }
PhLImportImageCommand >> execute [
	| answer |
	importSiblings := false.
	answer := self imagesPresenter newRequest
		title: 'What would you like to do?';
		chooseFrom:
			{ 'Import an image into Pharo Launcher images store (will move files)' .
			'Import the image directory (and all files it contains) into Pharo Launcher images store (will move files)' }.
	answer = 0 
		ifTrue: [ ^ self "cancel" ].
	answer = 2
		ifTrue: [ importSiblings := true ].
	self importImage.
]

{ #category : #executing }
PhLImportImageCommand >> import: imageFileRef [
	| infoMessage destFolderName imageRepository |
	destFolderName := imageFileRef basenameWithoutExtension.
	imageRepository := self imagesPresenter imageRepository.
	[ imageRepository ensureNoImageWithName: destFolderName ]
		on: PhLNameNotAvailableError
		do: [ destFolderName := self chooseNewImageNameFor: destFolderName ].
	destFolderName ifNil: [ ^ self "abort" ].
	
	importSiblings
		ifTrue: [ 
			imageRepository
				importImageNamed: imageFileRef
				andSiblingFilesto: destFolderName ]
		ifFalse:
			[ imageRepository importImage: imageFileRef to: destFolderName ].
	infoMessage := 'Image ' , imageFileRef fullName , ' imported!'.
	self imagesPresenter newInformation
		message: (infoMessage withNoLineLongerThan: 60);
		inform
]

{ #category : #executing }
PhLImportImageCommand >> importImage [
	| imageFile |
	imageFile := self imagesPresenter newFileRequest
		title: 'Import a Pharo image (will move image, changes file and pharo-local folder)';
		extensionsToShow: #('image');
		path: FileLocator home;
		chooseFile.
	imageFile ifNil: [ 
		self imagesPresenter newInformation 
			message: 'No path selected. Import failed.';
			inform.
		^ self ].
	imageFile asFileReference isDirectory ifTrue: [ 
		self imagesPresenter newInformation 
			message: 'The file selected is a directory and not a Pharo image. Import failed.';
			inform.
		^ self ].
	self import: imageFile
]

{ #category : #initialization }
PhLImportImageCommand >> initialize [
	super initialize.
	self
		name: 'Import';
		description:
			'Import into Pharo Launcher an existing Pharo image (and possibly its parent folder)'
]
