#!/vendor/bin/sh

fos_flags_path='/proc/idme/fos_flags'
dev_flags_path='/proc/idme/dev_flags'
FOS_DEV_FLAGS_NO_STR=256
FOS_DEV_FLAGS_USB_MODE_PHERIPHERAL=0x1
FOS_FLAGS_ADB_ROOT=2
FOS_DEV_FLAGS_STR_LESS_DELAY=0x8

# populate ro.nrdp.oemmodel
idme_mfr_name=`/vendor/bin/cat /proc/idme/mfr_name`
idme_mfr_model=`/vendor/bin/cat /proc/idme/mfr_model`
idme_prod_model=`/vendor/bin/cat /proc/idme/product_model`
prop_ome_model=$idme_mfr_name"_"$idme_mfr_model
# for settings use
/vendor/bin/setprop ro.product.oemmodel $prop_ome_model
/vendor/bin/setprop ro.nrdp.oemmodel $prop_ome_model
# for netflix use
/vendor/bin/setprop ro.vendor.nrdp.oemmodel $prop_ome_model
# set product model
#/vendor/bin/setprop ro.vendor.product.model $idme_prod_model
#refer https://issues.labcollab.net/browse/PRIMROSE-677
/vendor/bin/setprop ro.vendor.product.model_trigger $idme_prod_model
#/vendor/bin/setprop ro.product.model $idme_prod_model

IDME_MODEL_NAME=`/vendor/bin/cat /proc/idme/model_name`
/vendor/bin/setprop ro.vendor.amlogic.idme.model_name "$IDME_MODEL_NAME"

#set ro.poweron.src and sys.poweron.src based on wakeup reason
power_on_reason=`/vendor/bin/cat /sys/devices/platform/aml_pm/suspend_reason`
case $power_on_reason in
    13)
        /vendor/bin/setprop ro.poweron.src "app_1"
        /vendor/bin/setprop sys.poweron.src "app_1"
        ;;
    14)
        /vendor/bin/setprop ro.poweron.src "app_2"
        /vendor/bin/setprop sys.poweron.src "app_2"
        ;;
    15)
        /vendor/bin/setprop ro.poweron.src "app_3"
        /vendor/bin/setprop sys.poweron.src "app_3"
        ;;
    9)
        /vendor/bin/setprop ro.poweron.src "app_4"
        /vendor/bin/setprop sys.poweron.src "app_4"
        ;;
    *)
        /vendor/bin/setprop ro.poweron.src "unknown"
        /vendor/bin/setprop sys.poweron.src "unknown"
esac

# set suspend blocker per FOS_DEV_FLAGS_NO_STR
dev_flags=`/vendor/bin/cat $dev_flags_path`
dev_flags=0x$dev_flags
if [ $(($dev_flags & $FOS_DEV_FLAGS_NO_STR)) != "0" ] ; then
    /vendor/bin/setprop odm.hold.wakelock.idme y
fi

if [ $(($dev_flags & $FOS_DEV_FLAGS_STR_LESS_DELAY)) != "0" ] ; then
    /vendor/bin/setprop sys.str.delay_before_str 10000
fi

# enable USB device mode if ADB is enabled
if [ $(($dev_flags & $FOS_DEV_FLAGS_USB_MODE_PHERIPHERAL)) != "0" ] ; then
    /vendor/bin/setprop vendor.usb.debugging.init y
else
    /vendor/bin/setprop vendor.usb.debugging.init n
fi

# disable rescue when adb root flage is set
fos_flags=`/vendor/bin/cat $fos_flags_path`
fos_flags=0x$fos_flags
if [ $(($fos_flags & $FOS_FLAGS_ADB_ROOT)) != "0" ] ; then
    /vendor/bin/setprop persist.odm.disable_rescue true
fi

# set ro.product.region based on idme region
idme_region=`/vendor/bin/cat /proc/idme/region`
/vendor/bin/setprop ro.product.region "$idme_region"

# only do it once after full flash or factory reset
if [[ ! -f /data/vendor/storemode_flag ]]; then
	if [ "$idme_region" == "CA" ] ; then
		/vendor/bin/setprop odm.locale "fr-CA"
	fi

	if [ "$idme_region" == "US" ] ; then
		/vendor/bin/setprop odm.locale "en-US"
	fi

    if [ "$idme_region" == "ES" ] ; then
        /vendor/bin/setprop odm.locale "es-ES"
    fi
fi

oem_data=`/vendor/bin/cat /proc/idme/oem_data`
if [[ $oem_data == *hazel-tm* ]]; then
    /vendor/bin/setprop persist.bluetooth.avrcpversion "avrcp15"
fi

if [[ $oem_data == *hazel-hh* ]] || [[ $oem_data == *hazel-tm* ]]; then
    echo "enable acr for $oem_data " > /dev/kmsg
    /vendor/bin/setprop audio.amazon.acr.enabled 1
fi
