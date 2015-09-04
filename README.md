# Polar2Garmin
Synchronization tool for Polar Personal Trainer to Garmin Connect.

This is a command line tool for MacOSX.

Usage:

- Clone this repo to <DIRECTORY>
- Download and install garmin connect uploader tool: http://sourceforge.net/projects/gcpuploader/
- Fill in your credentials, weight, age, etc in sync-activities.sh
- Open a terminal and run sync-activities.sh as follows:

> cd <DIRECTORY>
> ./sync-activities.sh

The script will scrape the Polar Personal Trainer web site for new activities, downloads them to the polar sub directory, converts them to tcx for Garmin and uploads them to Garmin. Don't delete any of the files created in the subdirectory, they are used to keep track of activities that have already been synced.

Enjoy!