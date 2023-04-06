curl -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
curl https://deb.nodesource.com/setup_current.x | sudo bash -
sudo apt install -y --no-install-recommends linux-modules-extra-$(uname -r) xvfb anbox gawk lzip adb nodejs privoxy ./google-chrome-stable_current_amd64.deb ffmpeg
sudo apt purge -y mawk
rm -rf google-chrome-stable_current_amd64.deb
sudo curl --output-dir /var/lib/anbox -o android.img https://bitbucket.org/chaowenguo/android/raw/main/amd64.img
sudo awk -i inplace /container-manager/{sub\(/$/\,\"\ --use-rootfs-overlay\"\)}1 /usr/lib/systemd/system/anbox-container-manager.service
sudo awk -i inplace /session-manager/{sub\(/$/\,\"\ --single-window\ --window-size=1280\,1024\"\)}1 /usr/lib/systemd/user/anbox-session-manager.service
OPENGAPPS_RELEASEDATE=$(curl https://api.github.com/repos/opengapps/x86_64/releases/latest | awk -F\" /tag_name/{print\$\(NF-1\)})
OPENGAPPS_FILE=open_gapps-x86_64-7.1-pico-$OPENGAPPS_RELEASEDATE.zip
curl -L -O https://sourceforge.net/projects/opengapps/files/x86_64/$OPENGAPPS_RELEASEDATE/$OPENGAPPS_FILE
unzip $OPENGAPPS_FILE Core/*
for filename in Core/*.tar.lz
do
    tar -xf $filename -C Core
done
opengapps=/var/lib/anbox/rootfs-overlay/system/priv-app
sudo mkdir -p $opengapps
sudo cp -r $(find Core -type d -name "PrebuiltGmsCore") $opengapps
sudo cp -r $(find Core -type d -name "GoogleLoginService") $opengapps
sudo cp -r $(find Core -type d -name "Phonesky") $opengapps
sudo cp -r $(find Core -type d -name "GoogleServicesFramework") $opengapps
rm -rf Core $OPENGAPPS_FILE
sudo chown -R 100000:100000 $opengapps/Phonesky $opengapps/GoogleLoginService $opengapps/GoogleServicesFramework $opengapps/PrebuiltGmsCore
ls $opengapps
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
await page.goto('https://m.apkpure.com/earn-money-with-givvy-shorts/com.givvy.shorts/download')
const [download] = await globalThis.Promise.all([page.waitForEvent('download'), page.locator('a[href="https://d.apkpure.com/b/APK/com.givvy.shorts?version=latest"]').nth(1).click()])
await download.saveAs('givvyShorts.apk')
await client.send('Emulation.setScriptExecutionDisabled', {value:false})
await browser.close()
EOF
adb install givvyShorts.apk
sudo awk -i inplace /listen-address/{sub\(/127.0.0.1/\,\"0.0.0.0\"\)}1 /etc/privoxy/config
echo 'forward-socks5t   /  0.0.0.0:1080 .' | sudo tee -a /etc/privoxy/config
sudo systemctl restart privoxy
ssh -fNT -D 0.0.0.0:1080 -oStrictHostKeyChecking=no -oProxyCommand='ssh -oStrictHostKeyChecking=no -T guest@ssh.devcloud.intel.com' u180599@devcloud
$shell /system/bin/sh <<EOF
am start -n com.termux/com.termux.app.TermuxActivity
sleep 30
settings put global window_animation_scale 0
settings put global transition_animation_scale 0
settings put global animator_duration_scale 0
settings put global http_proxy 192.168.250.1:8118
am force-stop com.termux
EOF
#pm clear us.current.android
ffmpeg -f x11grab -i :99 givvyShorts.webm &
$shell /data/data/com.termux/files/usr/bin/bash <<EOF
am start -n com.givvy.shorts/com.givvy.shorts.shared.view.DefaultActivity
tap()
{
    sleep 30
    sh /system/bin/uiautomator dump /data/local/tmp/ui.xml
    local array=(\$(/data/data/com.termux/files/usr/bin/gawk -vRS=\> -F\" /\$1/{gsub\(/[][\,]/\,\"\ \"\,\$\(NF-1\)\)\;print\$\(NF-1\)} /data/local/tmp/ui.xml))
    echo \${array[@]}
    input tap \$((\$((\${array[0]} + \${array[2]})) / 2)) \$((\$((\${array[1]} + \${array[3]})) / 2))
}
tap resource-id=\"com.givvy.shorts:id\\\/googleLogin\"
sleep 30
sh /system/bin/uiautomator dump /data/local/tmp/ui.xml
tap resource-id=\"identifierId\"
input text chaowen.guo1@gmail.com
tap resource-id=\"identifierNext\"
tap text=\"Enter\ your\ password\"
input text $1
tap resource-id=\"passwordNext\"
tap content-desc=\"I\ agree\"
tap text=\"ACCEPT\"
tap text=\"English\"
tap resource-id=\"com.givvy.shorts:id\\\/nextButton\"
wm=(\$(wm size | /data/data/com.termux/files/usr/bin/gawk {sub\(/x/\,\"\ \"\,\\\$NF\)\;print\\\$NF}))
for i in {0..15}
do
    input swipe \$((\${wm[1]} / 2)) \$((\${wm[0]} - 10)) \$((\${wm[1]} / 2)) 0 2000
done
tap text=\"United\ States\"
tap resource-id=\"com.givvy.shorts:id\\\/nextButton\"
array=(\$(tap resource-id=\"com.givvy.shorts:id\\\/interestTextView\"))
echo \${array[@]}
for i in {1..4}
do
    echo \$((\$((\${array[\$((4 * \$i))]} + \${array[\$((\$((4 * \$i)) + 2))]})) / 2))
    echo \$((\$((\${array[\$((\$((4 * \$i)) + 1))]} + \${array[\$((\$((4 * \$i)) + 3))]})) / 2))
    input tap \$((\$((\${array[\$((4 * \$i))]} + \${array[\$((\$((4 * \$i)) + 2))]})) / 2)) \$((\$((\${array[\$((\$((4 * \$i)) + 1))]} + \${array[\$((\$((4 * \$i)) + 3))]})) / 2))
done
for i in {0..1}
do
    tap resource-id=\"com.givvy.shorts:id\\\/nextButton\"
done
tap resource-id=\"com.givvy.shorts:id\\\/startButton\"
input swipe \$((\${wm[1]} / 2)) \$((\${wm[0]} - 10)) \$((\${wm[1]} / 2)) 0 2000
sleep 1m
EOF
