# Overview

The `backup.sh` script helps you automatically save a folder you choose to both your computer and a remote storage service using `rclone`. It also has features to remove old backups and to notify you when the backup is done successfully.

## Configuration
1) Clone this repository 
```bash
git clone https://github.com/dhruvmistry2000/Project1.git
```
2) Install zip on you server.
For Ubuntu Server
```bash
sudo apt install -y zip
```
For RHEL Server
```bash
sudo yum install -y zip
```
For RHEL Server
```bash
sudo dnf install -y zip
```
3) Before running the script, you need to configure the following variables at the top of the script:

- `SOURCE_DIR`: The directory you want to back up.
- `BACKUP_DIR`: The local directory where backups will be stored.
- `REMOTE_NAME`: The name of the remote storage configured in `rclone`.
- `REMOTE_DIR`: The directory on the remote storage where backups will be stored.
- `DAYS_TO_KEEP`: The number of days to keep local backups before they are deleted *(By default i have set the value to 7)*.

4) In the send_notification function [backup.sh](backup.sh) file change the ip address to the machines ip address.
5) For backend confiuration refer to [Readme.md](Backend/Readme.md).

## rclone

Rclone is a command-line program that enables users to manage and synchronize files and directories between various cloud storage services and local file systems. It supports a wide range of cloud providers, including Google Drive, Dropbox, OneDrive, Amazon S3, and many others.

### Steps to Configure rclone

1) Install rclone using the following command in linux.
```bash
sudo -v ; curl https://rclone.org/install.sh | sudo bash
```
2) Check of rclone is installed or not.
```bash
rclone -v
```
If not use the first command again.
3) Now configure the rclone remote using the following command.
```bash
rclone config
```
4) Now we need to configure a new remote to press "n" and press "enter".
5) Give your desired name.In my configuration i haved named it "gdrive" and press "enter"..
6) Now choose the desired platfrom on which you want the remote backup to store. Here i have used Google Drive, so will give give "20" and press "enter".
7) This will ask for client_id and client_secret we can leave them empty and press "enter".
8) It will now ask for what kind of scope we want to give to. Scope means what kind of permssion we want this pc to give to the remote drive. I want to give "Full access all files, excluding Application Data Folder" permission, so will press 1 and press "enter".
9) This will ask for service_account_file, we can leave it empty and press "enter".
10) If we want to do more advance confiugration the "enter" "y" and press "enter".I don't want to do advance configuration so i will press "enter".
11) Now if the machine has a web-browser then press "y" and login into the account we want to save our remote backups.If not then it will give a command you will need to execute on a machine that has a web-browser and paste the command and then login into the account.Now in the command line you will get a key which you need to paste into the  config_token.
12) Now if you want to configure this as a shared drive then press "y". I don't want to so i will press "n" and press "enter".
13) Now it will ask if we want to keep the configred file, press "y" and then "enter" and then if you want to configure more remote drive then follow the steps again if not then press "q" and "enter".
14) To check if the configuration is saved or not use the following command.
```bash
rclone config show
```
This will show the configuration which we have done.

15) Now to test if the remote drive is configured or not use the command.This command will the files what are in the remote drive.Here / means the root.
```bash
rclone ls <remote_drive_name>:/
```
16) Now if this works properly make a new folder in the remote drive and then give the required values in backup.sh