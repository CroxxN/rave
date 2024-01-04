if ! command -v palera1n &> /dev/null
then
  printf "\n\x1b[1;33mWarning: palera1n-c not installed.\x1b[0m\n"
fi

if ! command -v sshpass &> /dev/null
then
  printf "\n\x1b[1;31mError: sshpass not installed.\x1b[0m\n"
  echo "Install sshpass and try again."
  exit 1
fi

echo "Downloading patch files..."
url=https://github.com/CroxxN/rave/raw/main/patch
wget "${url}"

echo "Downloading plist files..."
url=https://raw.githubusercontent.com/CroxxN/rave/main/com.bypass.mobileactivationd.plist
wget "${url}"

# exit 0 # IMPORTANT: Remove this line

echo "Mounting root partition"
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -p 4444 "root@localhost" 'mount -o rw,union,update /'
echo "Mounted!"

echo "Executing bypass"
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -p 4444 "root@localhost" 'mv -v /usr/libexec/mobileactivationd /usr/libexec/mobileactivationdBackup'
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -p 4444 "root@localhost" 'ldid -e /usr/libexec/mobileactivationdBackup > /usr/libexec/mobileactivationd.plist'
sshpass -p 'alpine' scp -O -rP 4444 -o StrictHostKeyChecking=no ./patch root@localhost:/usr/libexec/mobileactivationd
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -p 4444 "root@localhost" 'chmod 755 /usr/libexec/mobileactivationd'
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -p 4444 "root@localhost" 'ldid -S/usr/libexec/mobileactivationd.plist /usr/libexec/mobileactivationd'
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -p 4444 "root@localhost" 'rm -v /usr/libexec/mobileactivationd.plist'
sshpass -p 'alpine' scp -O -rP 4444 -o StrictHostKeyChecking=no ./com.bypass.mobileactivationd.plist root@localhost:/Library/LaunchDaemons/com.bypass.mobileactivationd.plist
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -p 4444 "root@localhost" 'launchctl load /Library/LaunchDaemons/com.bypass.mobileactivationd.plist'
sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no -p 4444 "root@localhost" 'launchctl reboot userspace'
echo "Done"

echo "Cleaning up files"

rm ./patch
rm ./com.bypass.mobileactivationd.plist
