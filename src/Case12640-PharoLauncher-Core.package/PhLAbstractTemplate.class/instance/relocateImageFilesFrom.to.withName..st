private
relocateImageFilesFrom: extractionDirectory to: targetDirectory withName: targetName
	"Move the image files from anywhere within extractionDirectory (even subdirectories) to aDirectory and give the image the name aString"

	| imageFile changesFile |
	imageFile := extractionDirectory allFiles detect: [ :aFile | '*.image' match: aFile basename ].	"A changes file must have the same name and be in the same directory as the image file:"
	changesFile := imageFile parent / imageFile basenameWithoutExtension , 'changes'.
	imageFile = (targetDirectory / targetName , 'image')
		ifTrue: [ ^ self "no need to relocate" ].
	imageFile moveTo: targetDirectory / targetName , 'image'.
	changesFile moveTo: targetDirectory / targetName , 'changes'