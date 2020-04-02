#!/bin/sh

cd /home/fdroid/deltachat-android/jni/deltachat-core-rust
git reset --hard origin/master
cd ../..
git reset --hard origin/master

# Check for changes on GitHub:
git pull origin master > ../last-pull.txt
pullresult=`diff ../last-pull.txt ../uptodate.txt`
git submodule foreach git pull origin master > ../last-pull.txt 2>&1
pullresultsub=`diff ../last-pull.txt ../submodule-uptodate.txt`

# If there are no changes, neither in deltachat-android, nor in deltachat-core-rust, exit:
if [ -z "$pullresult" ] && [ -z "$pullresultsub" ]
then
	echo "No changes on remote, exiting nightly build script."
	exit 0
fi

# let the script fail if one build step fails
set -e

date=$(date '+%Y-%m-%d')

echo "Building deltachat-android nightly on commit $(git rev-parse HEAD)"

# Build instructions from https://github.com/deltachat/deltachat-android/#build-using-dockerfile
# Remove the files generated by the last build
sudo git clean -xffd
# Build the build container with docker
docker build . -t deltachat-android --no-cache > ~/build.log
# Prepare the build environment and Build the apk
docker run --name ndk-make-$date -v $(pwd):/home/app -w /home/app deltachat-android ./ndk-make.sh >> ~/build.log
docker run --rm -v $(pwd):/home/app -w /home/app deltachat-android ./gradlew assembleDebug --stacktrace >> ~/build.log
# Remove dangling docker container and image
docker container rm ndk-make-$date
docker rmi deltachat-android:latest -f

echo "Build output at /home/fdroid/deltachat-android/build/outputs/apk/gplay/debug/"

# Upload to download.delta.chat
rsync -vhr /home/fdroid/deltachat-android/build/outputs/apk/gplay/debug/*.apk android-nightly@download.delta.chat:/var/www/html/download/android/nightly/$date/

echo "Build uploaded to https://download.delta.chat/android/nightly/$date/" >> ~/build.log

rsync -vh ~/build.log android-nightly@download.delta.chat:/var/www/html/download/android/nightly/$date/

