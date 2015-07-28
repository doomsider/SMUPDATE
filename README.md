# SMUPDATE
Update script in BASH for Starmade

Script to update/install SM from BASH.  Uses curl so it must be installed.

This script will search for StarMade, if not found it will create a directory and install all the files from the Starmade repo. 

If starmade is found it will check every files' checksum versus the repo checksum and download and overwrite files that do not match the repo.  

If a file is not found it will download the file and create the directory structure to it.


To install
  
	wget https://raw.githubusercontent.com/doomsider/SMUPDATE/master/update.sh


To Run

	chmod +x update.sh
  
	./update.sh
