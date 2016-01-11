# Backupscript

Backupscript is a script made by Robin Kelchtermans and Wouter Roozeleer for the course System Engineering 3.

Use the `-h` or `--help` flag to get the help function

## How to work with Backupscript

Make a config file in which you place the directories you want to back up. Once you run the script, it will ask you to show it where your config file is.

Use the `-z` or `--zip` flag to get a zipped version of your backup.

Use `tar -tvf` to see what is in the .tar file, if it's zipped `unzip` it first.

Use `tar -xvf` to Extract the .tar file. Again, if it's zipped `unzip` it first.

## What does the script do

This script will make an empty .tar file. You'll have to make a config file in which you'll place the directories you want to backup.
It uses the `date` command to make sure you'll never overwrite your previous backups and it's easier to sort.
