curl -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
curl https://deb.nodesource.com/setup_current.x | sudo bash -
sudo apt install -y --no-install-recommends linux-modules-extra-$(uname -r) xvfb anbox gawk lzip adb nodejs privoxy ./google-chrome-stable_current_amd64.deb ffmpeg imagemagick
sudo apt purge -y mawk
rm -rf google-chrome-stable_current_amd64.deb
sudo curl --output-dir /var/lib/anbox -o android.img https://bitbucket.org/chaowenguo/android/raw/main/amd64.img
sudo awk -i inplace /container-manager/{sub\(/$/\,\"\ --use-rootfs-overlay\"\)}1 /usr/lib/systemd/system/anbox-container-manager.service
sudo awk -i inplace /session-manager/{sub\(/$/\,\"\ --single-window\ --window-size=1000\,1024\"\)}1 /usr/lib/systemd/user/anbox-session-manager.service
sudo systemctl start anbox-container-manager
sudo mkdir /dev/binderfs
sudo mount -t binder binder /dev/binderfs
Xvfb :99 &
systemctl --user set-environment DISPLAY=:99
sleep 30
ls /run | awk /anbox-container/
systemctl --user start anbox-session-manager
sleep 30
ps aux | awk /anbox/
adb wait-for-device
shell='sudo lxc-attach -q --clear-env -P /var/lib/anbox/containers -n default -v PATH=/sbin:/system/bin:/system/sbin:/system/xbin -v ANDROID_ASSETS=/assets -v ANDROID_DATA=/data -v ANDROID_ROOT=/system -v ANDROID_STORAGE=/storage -v ASEC_MOUNTPOINT=/mnt/asec -v EXTERNAL_STORAGE=/sdcard --'
while [[ $($shell /system/bin/sh -c getprop\ sys.boot_completed) != 1 ]]
do
    sleep 30
done
adb devices -l
curl -O https://f-droid.org/repo/com.termux_118.apk
adb install com.termux_118.apk
rm -rf com.termux_118.apk
PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm install playwright-chromium
DISPLAY=:99 node --input-type=module <<EOF
import {chromium} from 'playwright-chromium'
const browser = await chromium.launch({channel:'chrome', args:['--disable-blink-features=AutomationControlled', '--start-maximized'], headless:false})
const context = await browser.newContext()
const page = await context.newPage()
const client = await context.newCDPSession(page)
await client.send('Emulation.setScriptExecutionDisabled', {value:true})
await page.goto('https://m.apkpure.com/make-money-with-givvy-videos/com.givvyvideos/download')
const [download] = await globalThis.Promise.all([page.waitForEvent('download'), page.locator('a[href="https://d.apkpure.com/b/APK/com.givvyvideos?version=latest"]').nth(1).click()])
await download.saveAs('givvyVideos.apk')
await client.send('Emulation.setScriptExecutionDisabled', {value:false})
await browser.close()
EOF
adb install givvyVideos.apk
$shell /system/bin/sh <<EOF
am start -n com.termux/com.termux.app.TermuxActivity
sleep 30
settings put global window_animation_scale 0
settings put global transition_animation_scale 0
settings put global animator_duration_scale 0
am force-stop com.termux
EOF
#ffmpeg -f x11grab -i :99 givvyVideos.webm &
$shell /data/data/com.termux/files/usr/bin/bash <<EOF
am start -n com.givvyvideos/com.givvyvideos.shared.view.DefaultActivity 
tap()
{
    sleep 20
    sh /system/bin/uiautomator dump /data/local/tmp/ui.xml
    local array=(\$(/data/data/com.termux/files/usr/bin/gawk -vRS=\> -F\" /"\$1"/{gsub\(/[][\,]/\,\"\ \"\,\$\(NF-1\)\)\;print\$\(NF-1\)} /data/local/tmp/ui.xml))
    echo \${array[@]}
    input tap \$((\$((\${array[0]} + \${array[2]})) / 2)) \$((\$((\${array[1]} + \${array[3]})) / 2))
}
tap text=\"English\"
tap resource-id=\"com.givvyvideos:id\\\/saveButton\"
sleep 30
sh /system/bin/uiautomator dump /data/local/tmp/ui.xml
cat /data/local/tmp/ui.xml
EOF
DISPLAY=:99 import -window root screenshot.png

cat <<EOF
tap resource-id=\"us.current.android:id\\\/mailSignInButton\"
tap resource-id=\"us.current.android:id\\\/etEmail\"
input text chaowen.guo1@gmail.com
tap resource-id=\"us.current.android:id\\\/passwordField\"
input text $1
tap resource-id=\"us.current.android:id\\\/btnLogin\"
sleep 30
newsActivity='am start -n us.current.android/com.current.android.feature.news.ui.activities.NewsActivity'
\$newsActivity
tap resource-id=\"us.current.android:id\\\/controllers\"
sleep 30
\$newsActivity
sleep 30
sh /system/bin/uiautomator dump /data/local/tmp/ui.xml
toolbar=\$(/data/data/com.termux/files/usr/bin/gawk -vRS=\> -F[],] /resource-id=\"us.current.android:id\\\/toolbar\"/{print\$\(NF-1\)} /data/local/tmp/ui.xml)
sponsoredArticleCardView=\$(/data/data/com.termux/files/usr/bin/gawk -vRS=\> -F[],] /resource-id=\"us.current.android:id\\\/sponsoredArticleCardView\"/{print\\\$2\;exit} /data/local/tmp/ui.xml)
input swipe 0 \$sponsoredArticleCardView 0 \$toolbar 2000
sleep 30
sh /system/bin/uiautomator dump /data/local/tmp/ui.xml
array=(\$(/data/data/com.termux/files/usr/bin/gawk -vRS=\> -F\" /resource-id=\"us.current.android:id\\\/sponsoredArticleCardView\"/{gsub\(/[][\,]/\,\"\ \"\,\$\(NF-1\)\)\;print\$\(NF-1\)} /data/local/tmp/ui.xml))
echo \${array[@]}
halfWidth=\$((\$((\${array[0]} + \${array[2]})) / 2))
for out in {0..88}
do
    for i in \$(seq 1 \$((\$((\${#array[@]} / 4)) - 1)))
    do
	    input tap \$halfWidth \$((\$((\${array[\$((\$((4 * \$i)) - 3))]} + \${array[\$((\$((4 * \$i)) - 1))]})) / 2))
        sleep 30
        input keyevent 4
        sleep 5
    done
    \$newsActivity
    sleep 4
    input swipe 0 \$sponsoredArticleCardView 0 \$toolbar 3000
    sleep 3
    #input swipe \$halfWidth \${array[-3]} \$halfWidth \${array[1]} 5000
done
EOF
