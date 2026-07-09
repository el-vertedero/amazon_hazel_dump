#!/vendor/bin/sh

echo "check hdcp status" > /dev/kmsg
result1=$(cat /sys/module/tvin_hdmirx/parameters/hdcp22_on)
if [ $result1 -ne 0 ]; then
	setprop ro.product.drm.hdcp22.rx  1
fi
result2=$(cat /sys/module/tvin_hdmirx/parameters/hdcp14_on)
if [ $result2 -ne 0 ]; then
	setprop ro.product.drm.hdcp14.rx  1
fi
