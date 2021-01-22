#!/bin/bash

# import configs
source .config

# remove temp folder if already files exists in folder
# Create temp directory, used -p to prvenet any
# error if directory alread exists
rm -rf $tempDir && mkdir -p $tempDir
git clone --no-checkout --depth 1 https://github.com/torvalds/linux $tempDir

# Generate some variables
backupDate=`date +%Y_%m_%d`
backupFileName="backup_$backupDate"
oldBackupDate=`date +%Y_%m_%d --date="-$keepOldBackupDays days"`
oldBackupName="backup_$oldBackupDays"
monthlyBackupDate=`date +%Y_%m_$monthlyBackupDay --date=-30 days`

cd $dataDir

tar czvf - --exclude=$excludeFolder .  | gpg --symmetric --cipher-algo aes256 --pinentry-mode loopback --passphrase $encryptPassphrase \
    -o "$tempDir/$backupFileName.$fileExtension"

cd $tempDir

git add $backupFileName.$fileExtension

git commit -m "add new backup $backupFileName" $backupFileName.$fileExtension

if [ $oldBackupDate -ne $monthlyBackupDate ]
then
git ls-tree --full-name --name-only -r HEAD | grep $oldBackupName && \
    git rm --cached "$oldBackupName" && \
    git commit -m "remove old Backup $oldBackupName"
fi

git push -u origin $remoteBranch

