# AWS FFmpeg Shell Script.

Bash script to convert audio files using ffmpeg from *.wav format to *.ogg mono 64kbps format, check the integrity of the converted files before uploading the local files into an AWS-S3 API compatible bucket on [Backblaze B2](https://www.backblaze.com/) and [Bitfrost Storage Cloud](https://www.bifrostcloud.com/index.html).

## Prerequisites.
1. To use both the Backblaze B2 and Bifrost Cloud Storage, the user will need to create an account on the respective websites.
---

2.  AWS CLI is required for using Backblaze B2 and Bifrost Cloud Storage. You can install it on your Linux machine by running the following command:
```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

---
3. Once AWS CLI is installed, you will need to configure it to use your Backblaze B2 account and Bifrost Cloud Storage. You can do this by running the following command and providing your B2 account ID and application key when prompted:
---
**IMPORTANT**: for the script operations to work correctly **json** must be chosen as the prefered output format during the **aws configure** process.

```sh
> aws configure

AWS Access Key ID [None]: your_AWS_access_key_ID
AWS Secret Access Key [None]: your_AWS_secret_access_key
Default region name [None]: your_default_region_name
Default output format [None]: json
```
Users may need to configure several profiles for proper use of `aws-cli`

```sh
aws configure --profile kent-backblaze
```
```sh
aws configure --profile kent-bitfrost
```

---
4. Ensure you have ffmpeg installed on the local workstation/desktop.

```sh
ffmepg --version
```
<!-- --- -->
<!-- Install FFmpeg on Ubuntu and Linux Mint -->
<!---->
<!-- ```sh -->
<!-- $ sudo apt update -->
<!-- $ sudo apt install ffmpeg -->
<!-- $ ffmpeg -version -->
<!-- ``` -->
<!-- --- -->
<!-- Install FFmpeg on Debian -->
<!-- ```sh -->
<!-- $ sudo apt update -->
<!-- $ sudo apt install ffmpeg -->
<!-- $ ffmpeg -version -->
<!-- ``` -->
---
Install FFmpeg on Arch Linux
 ```sh
 $ sudo pacman -S ffmpeg
$ yay -S ffmpeg-git
$ yay -S ffmpeg-full-git
$ ffmpeg -version
 ```
---

5. Ensure Python and Pip are installed on the local desktop or server environment.

**Note**. This command is for Arch-based systems. If you are using a different distribution, use the package manager specific to your system.  

Install python by running the command:
```sh
sudo pacman -S python3
```
To install pip, run the following command:
```sh
sudo pacman -S python3-pip
```
Verify that Python and pip are installed correctly by running the following commands:
```sh
python3 --version
pip3 --version
```
---

6. Ensure that you have sufficient permissions to write to both the Backblaze B2 bucket and the Bifrost cloud storage bucket. If you encounter any permission issues, you may need to check your account settings or contact customer support for assistance.

Checking permission using aws-cli in Bifrost Cloud Storage
```sh
aws s3api get-bucket-acl --bucket "$bifrost_b2_bucket" --endpoint-url="$bifrost_endpoint_url" --profile "$bifrost_profile"
```

Checking permission using aws-cli in Backblaze B2
```sh
aws s3api get-bucket-acl --bucket "$backblaze_b2_bucket" --endpoint-url="$backblaze_endpoint_url" --profile "$backblaze_profile"
```
----

7. The provided script in this repository can be used to upload files to both Backblaze B2 and Bifrost cloud storage simultaneously. You can modify the script to suit your needs or use it as-is.
---

## Description.
The project is a command-line tool that automates the conversion of audio files from .wav to .ogg format using FFmpeg, a popular open-source software for audio and video processing. The converted files are encoded in mono with a bit rate of 64kbps. The tool then uses the AWS Command Line Interface (CLI) to upload the converted .ogg files to Backblaze B2 and Bifrost Cloud Storage, two popular cloud storage platforms.

The project is designed to be used in a Linux environment and assumes that both FFmpeg and AWS CLI are installed and configured properly. It provides a simple and efficient way to convert and upload audio files to cloud storage for backup, sharing, and distribution purposes.

Users can specify the source directory containing the .wav files and the destination bucket in Backblaze B2 and/or Bifrost Cloud Storage. The tool also provides logging functionality to keep track of the conversion and upload process.

This project is useful for anyone who needs to convert audio files to a compressed format and store them in the cloud for backup or distribution. It is particularly useful for individuals or small businesses that need to store audio files in two different cloud storage services for redundancy and security purposes.

### Script Environment
This script is designed to run on a Linux operating system. The following requirements must be met before running the script:

---
1. Environment Variables: The script requires the following environment variables to be set:

+ AWS_ACCESS_KEY_ID: Your AWS access key ID
+ AWS_SECRET_ACCESS_KEY: Your AWS secret access key
+ B2_APPLICATION_KEY_ID: Your Backblaze B2 application key ID
+ B2_APPLICATION_KEY: Your Backblaze B2 application key
+ BIFROST_ACCESS_KEY_ID: Your Bifrost access key ID
+ BIFROST_SECRET_ACCESS_KEY: Your Bifrost secret access key
+ BIFROST_BUCKET_NAME: The name of the Bifrost bucket to store the files
---

2. File Permissions: Ensure that the user running the script has read and write permissions in the directories where the .wav files are located, as well as in the directories where the converted .ogg files are stored.
---

3. Internet Connection: Ensure that the system has a stable internet connection to upload the converted files to Backblaze B2 and Bifrost Cloud Storage.
---

### Development Roadmap

- [x] Define the scope of the project
- [x] Set up an AWS environment
- [x] Install FFMPEG on AWS
- [ ] Create an AWS Lambda function
- [ ] Test the Lambda function
- [ ] Configure error handling
- [ ] Optimize the Lambda function
- [ ] Monitor and maintain the system
- [ ] Implement security and access controls
- [x] Document the system
