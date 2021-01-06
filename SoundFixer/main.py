# TODO:
# 3. 


import os, posixpath, pathlib
from os.path import join
from os import listdir
from string import digits


def createWeaponSoundContainers(weaponsFolderPath):
	blacklistedWeaponFolderNames = ("ColtPython Backup", "DEPRECATED")

	for weaponFolderName in listdir(join("..", weaponsFolderPath)):
		if weaponFolderName not in blacklistedWeaponFolderNames:
			weaponFolderPath = join(weaponsFolderPath, weaponFolderName)

			# print(weaponFolderName, weaponFolderPath)

			soundContainer  = getWeaponSoundContainer(weaponFolderName, weaponFolderPath, "CompliSoundV2")
			soundContainer += getWeaponSoundContainer(weaponFolderName, weaponFolderPath, "Sounds")

			weaponIniInputPath = posixpath.join(weaponFolderPath, weaponFolderName) + ".ini"

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
			soundContainer += "\n\tAddSound = " + posixpath.join(weaponFolderPath, soundFolderName, soundNameNoNum).replace("\\", "/") + str(soundNameNum) + ".ogg"

		soundContainer += "\n\n"

	return soundContainer


def getSoundNames(weaponFolderPath, soundFolderName):
	soundNames = {}

	soundNameFolderPath = join("..", weaponFolderPath, soundFolderName)
	for soundName in listdir(soundNameFolderPath):
		soundNamePath = join(soundNameFolderPath, soundName)
		if os.path.isfile(soundNamePath):
			soundName, extension = os.path.splitext(soundName)
			soundNameNoNum = soundName.rstrip(digits)
			soundNames[soundNameNoNum] = soundNames.get(soundNameNoNum, 0) + 1

	return soundNames


def createVOSoundContainers(actorsPath):
	soundContainer = ""

	with open(join("..", actorsPath, "Shared.ini"), "r") as fileIn:
		soundContainer += fileIn.read()

	voiceOverFolderPath = join("..", actorsPath, "Shared/Sounds/VO")
	for faction in listdir(voiceOverFolderPath):
		factionPath = join(voiceOverFolderPath, faction)

		soundNames = {}
		for voiceOverReactionFolderName in listdir(factionPath):
			voiceOverReactionFolderPath = join(factionPath, voiceOverReactionFolderName)
			for soundName in listdir(voiceOverReactionFolderPath):
				voiceOverReactionFilePath = join(voiceOverReactionFolderPath, soundName).replace("\\", "/")
				if os.path.isfile(voiceOverReactionFilePath):
					soundName, extension = os.path.splitext(soundName)
					soundNameNoNum = soundName.rstrip(digits)
					if not soundNameNoNum in soundNames:
						soundNames[soundNameNoNum] = {"soundNameCount": 1, "folder": voiceOverReactionFolderName}
					else:
						soundNames[soundNameNoNum]["soundNameCount"] = soundNames[soundNameNoNum]["soundNameCount"] + 1

		for soundNameNoNum, values in soundNames.items():
			soundContainer += "\n\nAddSoundContainer = SoundContainer"
			soundContainer += "\n\tPresetName = " + soundNameNoNum + " " + faction
			soundContainer += "\n\tAttenuationStartDistance = 200"

			for soundNameNum in range(1, values["soundNameCount"] + 1):
				soundContainer += "\n\tAddSound = " + posixpath.join(actorsPath, "Shared/Sounds/VO", faction, values["folder"], soundNameNoNum).replace("\\", "/") + str(soundNameNum) + ".ogg"

	voiceOverOutputPath = posixpath.join("Output", actorsPath, "Shared.ini")

	try:
		os.makedirs(os.path.dirname(voiceOverOutputPath))
	except FileExistsError:
		pass

	with open(voiceOverOutputPath, "w") as fileOut:
		fileOut.write(soundContainer)


def createSandstormSoundContainers(folder1, foo):
	folder2 = posixpath.join(folder1, foo)

	sounds = {}
	for relativeSoundFolder, subfolders, soundFiles in os.walk(posixpath.join("..", folder2)):
		p = pathlib.Path(relativeSoundFolder)
		soundFolder = pathlib.Path(*p.parts[2:])

		for soundNameFull in soundFiles:
			soundName, extension = os.path.splitext(soundNameFull)
			soundNameNoNum = soundName.rstrip(digits)
			key = str(soundFolder / soundNameNoNum)
			sounds[key] = sounds.get(key, 0) + 1

	soundContainer = ""

	readSharedIniPath = posixpath.join("..", folder1, "Shared.ini")
	if os.path.isfile(readSharedIniPath):
		with open(readSharedIniPath, "r") as fileIn:
			soundContainer += fileIn.read()

	for path, soundCount in sounds.items():
		soundContainer += "\n\nAddSoundContainer = SoundContainer"
		soundContainer += "\n\tPresetName = " + path.replace("\\", "")
		soundContainer += "\n\tAttenuationStartDistance = 200"

		for soundNum in range(1, soundCount + 1):
			soundContainer += "\n\tAddSound = " + path.replace("\\", "/") + str(soundNum) + ".ogg"

	outputPath = posixpath.join("Output", folder1, "Shared.ini")

	try:
		os.makedirs(os.path.dirname(outputPath))
	except FileExistsError:
		pass

	with open(outputPath, "w") as fileOut:
		fileOut.write(soundContainer)


createWeaponSoundContainers("SandstormInsurgency.rte/Devices/Weapons/Handheld")
createWeaponSoundContainers("SandstormSecurity.rte/Devices/Weapons/Handheld")
createVOSoundContainers("SandstormInsurgency.rte/Actors")
createVOSoundContainers("SandstormSecurity.rte/Actors")
createSandstormSoundContainers("Sandstorm.rte/Actors", "Shared/Sounds")
createSandstormSoundContainers("Sandstorm.rte/Effects", "Sounds")
createSandstormSoundContainers("Sandstorm.rte/Devices", "Weapons/Shared/Sounds")

print("Converting done.")