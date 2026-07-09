#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/recovery:15089664:a6d981372b8df188361fa6691255eced593ffb2c; then
  applypatch  EMMC:/dev/block/boot:7534592:d2cb1db46ead6b908056d16fd565e65edfff9f58 EMMC:/dev/block/recovery 5c7bbb573a8b82ee898796d45cfe4b61eb147907 15087616 d2cb1db46ead6b908056d16fd565e65edfff9f58:/system/recovery-from-boot.p && installed=1 && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
  [ -n "$installed" ] && dd if=/system/recovery-sig of=/dev/block/recovery bs=1 seek=15087616 && sync && log -t recovery "Install new recovery signature: succeeded" || log -t recovery "Installing new recovery signature: failed"
else
  log -t recovery "Recovery image already installed"
fi
