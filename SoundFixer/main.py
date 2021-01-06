# TODO:
# 3. 


import os, posixpath
from os.path import join
from os import listdir
from string import digits


timesPrinted = 0


def createWeaponSoundContainers(weaponsFolderPath):
	blacklistedWeaponFolderNames = ("ColtPython Backup", "DEPRECATED")

	for weaponFolderName in listdir(join("..", weaponsFolderPath)):
		if weaponFolderName not in blacklistedWeaponFolderNames:
			weaponFolderPath = join(weaponsFolderPath, weaponFolderName)

			# print(weaponFolderName, weaponFolderPath)

			soundContainer =  getWeaponSoundContainer(weaponFolderName, weaponFolderPath, "CompliSoundV2")
			soundContainer += getWeaponSoundContainer(weaponFolderName, weaponFolderPath, "Sounds")

			weaponIniInputPath = posixpath.join(weaponFolderPath, weaponFolderName).replace("\\", "/") + ".ini"

			with open(join("..", weaponIniInputPath), "r") as fileIn:
				soundContainer += fileIn.read()

			weaponIniOutputPath = posixpath.join("Output", weaponIniInputPath)

			try:
				os.makedirs(os.path.dirname(weaponIniOutputPath))
			except FileExistsError:
				pass

			with open(weaponIniOutputPath, "w") as fileOut:
				fileOut.write(soundContainer)


def getWeaponSoundContainer(weaponFolderName, weaponFolderPath, soundFolderName):
	global timesPrinted
	
	soundContainer = ""

	wordsWithRestartOverlap = ("Reflection", "End")

	for soundNameNoNum, soundNameCount in getSoundNames(weaponFolderPath, soundFolderName).items():
		soundContainer += "AddSoundContainer = SoundContainer\n\tPresetName = "

		soundContainer += soundNameNoNum + " " + weaponFolderName

		soundContainer += "\n\tAttenuationStartDistance = "

		if soundFolderName == "CompliSoundV2":
			soundContainer += "250"
		else:
			soundContainer += "170"

		if any(word in soundNameNoNum for word in wordsWithRestartOverlap):
			soundContainer += "\n\tSoundOverlapMode = Restart"

		for soundNameNum in range(1, soundNameCount + 1):
			soundContainer += "\n\tAddSound = " + posixpath.join(weaponFolderPath, soundFolderName, soundNameNoNum) + str(soundNameNum) + ".ogg"

		soundContainer += "\n\n"

		timesPrinted += 1

	return soundContainer


def getSoundNames(weaponFolderPath, soundFolderName):
	soundNames = {}

	soundNameFolderPath = join("..", weaponFolderPath, soundFolderName)
	for soundName in listdir(soundNameFolderPath):
		soundNamePath = join(soundNameFolderPath, soundName)
		if os.path.isfile(soundNamePath):
			soundName, fileExtension = os.path.splitext(soundName)
			soundNameNoNum = soundName.rstrip(digits)
			soundNames[soundNameNoNum] = soundNames.get(soundNameNoNum, 0) + 1

	return soundNames


def createVOSoundContainers(actorsPath):
	soundContainer = ""

	with open(join("..", actorsPath, "Shared.ini"), "r") as fileIn:
		soundContainer += fileIn.read()

	voiceOverFolderPath = join(actorsPath, "Shared/Sounds/VO")
	voiceOverFolderInputPath = join("..", voiceOverFolderPath)
	for voiceOverFactionName in listdir(voiceOverFolderInputPath):
		voiceOverFactionNamePath = join(voiceOverFolderInputPath, voiceOverFactionName)
		for voiceOverReactionFolderName in listdir(voiceOverFactionNamePath):
			voiceOverReactionFolderPath = join(voiceOverFactionNamePath, voiceOverReactionFolderName)
			for voiceOverReactionFileName in listdir(voiceOverReactionFolderPath):
				voiceOverReactionFilePath = join(voiceOverReactionFolderPath, voiceOverReactionFileName)
				# print(voiceOverReactionFileName, voiceOverReactionFilePath)

	voiceOverOutputPath = posixpath.join("Output", actorsPath, "Shared.ini")

	try:
		os.makedirs(os.path.dirname(voiceOverOutputPath))
	except FileExistsError:
		pass

	with open(voiceOverOutputPath, "w") as fileOut:
		fileOut.write(soundContainer)


def getVOSoundContainer(weaponFolderName, weaponFolderPath, soundFolderName):
	global timesPrinted
	
	soundContainer = ""

	wordsWithRestartOverlap = ("Reflection", "End")

	for soundNameNoNum, soundNameCount in getSoundNames(weaponFolderPath, soundFolderName).items():
		soundContainer += "AddSoundContainer = SoundContainer\n\tPresetName = "

		soundContainer += soundNameNoNum + " " + weaponFolderName

		soundContainer += "\n\tAttenuationStartDistance = "

		if soundFolderName == "CompliSoundV2":
			soundContainer += "250"
		else:
			soundContainer += "170"

		if any(word in soundNameNoNum for word in wordsWithRestartOverlap):
			soundContainer += "\n\tSoundOverlapMode = Restart"

		for soundNameNum in range(1, soundNameCount + 1):
			soundContainer += "\n\tAddSound = " + posixpath.join(weaponFolderPath, soundFolderName, soundNameNoNum) + str(soundNameNum) + ".ogg"

		soundContainer += "\n\n"

		timesPrinted += 1

	return soundContainer


# def getVONames(weaponFolderPath, soundFolderName):
# 	soundNames = {}

# 	soundNameFolderPath = join("..", weaponFolderPath, soundFolderName)
# 	for soundName in listdir(soundNameFolderPath):
# 		soundNamePath = join(soundNameFolderPath, soundName)
# 		if os.path.isfile(soundNamePath):
# 			soundName, fileExtension = os.path.splitext(soundName)
# 			soundNameNoNum = soundName.rstrip(digits)
# 			soundNames[soundNameNoNum] = soundNames.get(soundNameNoNum, 0) + 1

# 	return soundNames


createWeaponSoundContainers(weaponsFolderPath="SandstormInsurgency.rte/Devices/Weapons/Handheld")
# createWeaponSoundContainers(weaponsFolderPath="SandstormSecurity.rte/Devices/Weapons/Handheld")
# createVOSoundContainers(actorsPath="SandstormInsurgency.rte/Actors")
# createVOSoundContainers(actorsPath="SandstormSecurity.rte/Actors")
print("Conversions: {}".format(timesPrinted))