# AWS ffmpeg Shell Script.

Bash script to convert audio files using ffmpeg from *.wav format to *.ogg format and check the integrity of the local files uploaded into an AWS s3 bucket.

## Prerequisites.

1. A valid connection to your AWS account. The user can use 'aws configure' command on the linux terminal to setup the required fields. The command is interactive, the AWS-CLI will prompt the user to enter additional information.
---
**IMPORTANT**: for the script operations to work correctly **json** must be chosen as the prefered output format during the **aws configure** process.

```sh
> aws configure

AWS Access Key ID [None]: your_AWS_access_key_ID
AWS Secret Access Key [None]: your_AWS_secret_access_key
Default region name [None]: your_default_region_name
Default output format [None]: json
```
---
2. Ensure you have ffmpeg installed on the local workstation/desktop.

```sh
ffmepg --version
```
---
Install FFmpeg on Ubuntu and Linux Mint

```sh
$ sudo apt update
$ sudo apt install ffmpeg
$ ffmpeg -version
```
---
Install FFmpeg on Debian
```sh
$ sudo apt update
$ sudo apt install ffmpeg
$ ffmpeg -version
```
---
Install FFmpeg on Arch Linux
 ```sh
 $ sudo pacman -S ffmpeg
$ yay -S ffmpeg-git
$ yay -S ffmpeg-full-git
$ ffmpeg -version
 ```

## Description.
