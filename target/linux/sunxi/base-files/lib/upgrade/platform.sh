platform_check_image() {
	case "$(board_name)" in
	xunlong,orangepi-zero3-spi)
		# sysupgrade.bin starts with the FIT kernel
		[ "$(get_magic_long "$1")" = "d00dfeed" ] && return 0
		echo "Invalid image type: expected a FIT (sysupgrade.bin)."
		return 1
		;;
	esac

	legacy_sdcard_check_image "$1"
}

platform_copy_config() {
	local partdev

	case "$(board_name)" in
	xunlong,orangepi-zero3-spi)
		# config is appended to rootfs_data by "mtd -j" in default_do_upgrade
		return 0
		;;
	esac

	if export_partdevice partdev 1; then
		mount -t vfat -o rw,noatime "/dev/$partdev" /mnt
		cp -af "$UPGRADE_BACKUP" "/mnt/$BACKUP_FILE"
		umount /mnt
	fi
}

platform_do_upgrade() {
	case "$(board_name)" in
	xunlong,orangepi-zero3-spi)
		PART_NAME=firmware
		default_do_upgrade "$1"
		;;
	*)
		legacy_sdcard_do_upgrade "$1"
		;;
	esac
}
