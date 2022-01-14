#!/bin/sh
if [ $(id -u) == "0" ]; then
	echo You should not be root user to use this script
else
	user=$USER

	# Adds event handler for brightness down
	if [ ! -f "/etc/acpi/events/backlightDown" ]; then
		sudo touch /etc/acpi/events/backlightDown
		echo 'event=video/brightnessdown' | sudo tee --append /etc/acpi/events/backlightDown > /dev/null
		echo 'action=/etc/acpi/handlers/blDown.sh %e' | sudo tee --append /etc/acpi/events/backlightDown > /dev/null
	fi
	# Adds brightness down script
	if [ ! -f "/etc/acpi/handlers/blDown.sh" ]; then
		sudo touch /etc/acpi/handlers/blDown.sh
		echo '#!/bin/sh' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo 'if [[ $5 == K* ]]; then' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '	bl_dev=/sys/class/backlight/intel_backlight' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '	bright=$(($(< $bl_dev/brightness)))' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '	max_bright=$(($(< $bl_dev/max_brightness)))' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '	if [[ $bright -gt $(($max_bright*3/10)) ]]; then' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '		echo $(($bright-$(($max_bright/10)))) >$bl_dev/brightness;' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '	else' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '		if [[ $(($bright-$(($max_bright/50)))) -le 0 ]]; then' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '			"0" >$bl_dev/brightness;' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '		else' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '			echo $(($bright-$(($max_bright/100)))) >$bl_dev/brightness;' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '		fi' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '	fi' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '	bright=$(($(< $bl_dev/brightness)))' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '	uid=$(id -u' $user ')' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		echo '	sudo -u' $user 'DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" tvolnoti-show -b $(($bright*100/$max_bright))' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		sudo echo 'fi' | sudo tee --append /etc/acpi/handlers/blDown.sh > /dev/null
		sudo chmod +x /etc/acpi/handlers/blDown.sh
	fi

	# Adds event handler for brightness up
	if [ ! -f "/etc/acpi/events/backlightUp" ]; then
		sudo touch /etc/acpi/events/backlightUp
		echo 'event=video/brightnessup' | sudo tee --append /etc/acpi/events/backlightUp > /dev/null
		echo 'action=/etc/acpi/handlers/blUp.sh %e' | sudo tee --append /etc/acpi/events/backlightUp > /dev/null
	fi
	# Adds brightness up script
	if [ ! -f "/etc/acpi/handlers/blUp.sh" ]; then
		echo '#!/bin/sh' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo 'if [[ $5 == K* ]]; then' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '	bl_dev=/sys/class/backlight/intel_backlight' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '	bright=$(($(< $bl_dev/brightness)))' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '	max_bright=$(($(< $bl_dev/max_brightness)))' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '	if [[ $bright -lt $(($max_bright*3/10)) ]]; then' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '		echo $(($bright+$(($max_bright/50)))) >$bl_dev/brightness;' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '	else' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '		if [[ $(($bright+$(($max_bright/10)))) -le $max_bright ]]; then' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '			echo $(($bright+$(($max_bright/10)))) >$bl_dev/brightness;' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '		else' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '			echo $(($max_bright)) >$bl_dev/brightness;' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '		fi' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '	fi' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '	bright=$(($(< $bl_dev/brightness)))' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '	uid=$(id -u' $user ')' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo '	sudo -u ' $user ' DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" tvolnoti-show -b $(($bright*100/$max_bright))' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		echo 'fi' | sudo tee --append /etc/acpi/handlers/blUp.sh > /dev/null
		sudo chmod +x /etc/acpi/handlers/blUp.sh
 	fi
fi
