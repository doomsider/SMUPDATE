#!/bin/bash
# Starmade Selective upgrade script for BASH.  Please run in the parent or root directory of Starmade
# Requires curl to be installed
# Grab the releaseindex as a very long string variable
echo "This script will install/update StarMade from the master repo.  Use ./update.sh force to force a check on all files"
read -s -r -p "Press any key to continue..." -n 1 dummy
if command -v curl >/dev/null
then
	echo "Curl was found"
	releaseindex=$(curl http://files.star-made.org/releasebuildindex)
# Go to the end of the variable at the last .
	newversion=${releaseindex##*.}
	echo "newversion $newversion"
# Get the first version to compare
	cutstring=${newversion#*_}
	NEWSMVERSION1=${cutstring%_*}
	echo "NEWSMVERSION1 $NEWSMVERSION1"
# Get the second version to compare
	NEWSMVERSION2=${cutstring#*_}
	echo "NEWSMVERSION2 $NEWSMVERSION2"
# Gather the old version from the version.txt file in StarMade
	oldversion=$(cat StarMade/version.txt)
	if [ -z "$oldversion" ]
	then
		echo "No install found for StarMade"
		OLDSMVER1=0
		OLDSMVER2=0
	else
		echo "oldversion $oldversion"
	# Get the first version to compare
		cutstring=${oldversion#*#}
		OLDSMVER1=${cutstring%_*}
		echo "OLDSMVER1 $OLDSMVER1"
	# Get the second version to compare
		OLDSMVER2=${cutstring#*_}
		echo "OLDSMVER2 $OLDSMVER2"
	fi
# If the first or second newversion exceeds the first or second old version
	if [ "$NEWSMVERSION1" -gt "$OLDSMVER1" ] || [ "$NEWSMVERSION2" -gt "$OLDSMVER2" ] || [ "$1" = "force" ]
	then 
		echo "Newer Version Detected"
# Set the field seperator to new line and then store the chucksums as an array with each element being a line
		OLD_IFS=$IFS
		IFS=$'\n'
		releaseindex=( $(curl http://files.star-made.org$newversion/checksums) )
		IFS=$OLD_IFS
# Set line count to 0 then go through the array line by line until the array index is unset		
		LINECOUNT=0
		while [ -n "${releaseindex[$LINECOUNT]+set}" ] 
		do
			CURRENTSTRING=${releaseindex[$LINECOUNT]}
			#echo $CURRENTSTRING
# Format the current line by removing everything after the first space and then removing ./ in the beginning of the name		
			cutstring=${CURRENTSTRING%[[:space:]]*}
			cutstring=${cutstring%[[:space:]]*}
			CURRENTFILE=${cutstring/.\//}
# Formatfile was added here because when requesting web URL space should be replaced with %20
			FORMATFILE=${CURRENTFILE// /%20}
			cutstring=${CURRENTSTRING%[[:space:]]*}
			cutstring=${cutstring##*[[:space:]]}
			CURRENTCKSUM=${cutstring%%[[:space:]]*}
			OLDCKSUMSTRING=$(cksum "StarMade/$CURRENTFILE")
# Check to see if OLDCKSUMSTRING is set, if not this indicates the file does not exist
			if [ -z "$OLDCKSUMSTRING" ]
			then
				echo "No existing file found - downloading file"
# Makes sure directory structure is created if it does not exist for the file write
				if [ ! -f "StarMade/$CURRENTFILE" ]; then
					mkdir -p "StarMade/$CURRENTFILE"
					rm -r "StarMade/$CURRENTFILE"
				fi
				curl "http://files.star-made.org$newversion/$FORMATFILE" > "StarMade/$CURRENTFILE"
			else
				cutstring=${OLDCKSUMSTRING#*[[:space:]]}
				OLDCKSUM=${cutstring%%[[:space:]]*}
				echo "CURRENTFILE $CURRENTFILE CURRENTCKSUM $CURRENTCKSUM OLDCKSUM $OLDCKSUM"
# Check to see if the cksums differ
				if [ "$CURRENTCKSUM" -ne "$OLDCKSUM" ]
				then
# Download the new file and then copy it into the proper location
					echo "Updated file detected - downloading file"
# Makes sure directory structure is created if it does not exist for the file write
					if [ ! -f "StarMade/$CURRENTFILE" ]; then
						mkdir -p "StarMade/$CURRENTFILE"
						rm -r "StarMade/$CURRENTFILE"
					fi
					curl "http://files.star-made.org$newversion/$FORMATFILE" > "StarMade/$CURRENTFILE"
				else
					echo "Current file detected - no action"
				fi
			fi
			let LINECOUNT++
		done
# Added to make sure version.txt is updated.  Sometimes the checksum will match despite the file being different.  This behaviour seems to be limited to very small text files with minor differences that happen to equal each other according to the way checksum calculates file size.
		curl "http://files.star-made.org$newversion/version.txt" > "$CONFIGDTSD_INSTALLPATH/StarMade/version.txt"
	else
		echo "Version Current"
	fi
else
	echo "You must install Curl to run this"
fi
