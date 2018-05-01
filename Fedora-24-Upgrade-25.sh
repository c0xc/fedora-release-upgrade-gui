#!/usr/bin/env bash

# Check dependencies
for d in zenity date; do
    if ! type $d >/dev/null 2>&1; then
        echo "Dependency not found: $d" >&2
        exit 1
    fi
done

# sudo function
function run_sudo
{
    file=$1

    if [ -t 0 ]; then
        # Interactive mode (terminal)
        sudo "$file"
    else
        if type kdesudo >/dev/null 2>&1; then
            kdesudo -c "$file"
        elif type kdesu >/dev/null 2>&1; then
            kdesu -n -c "$file"
        elif type gksudo >/dev/null 2>&1; then
            gksudo "$file"
        elif type gksu >/dev/null 2>&1; then
            gksu --su-mode "$file"
        else
            zenity --error --text \
                "gksu not found, cannot sudo non-interactively"
        fi
    fi
}

# Create script in /tmp
cd /tmp/ || exit 1
ts=$(date +%s)
file=".tmp_script.$$.$ts.sh"
if [ -e "$file" ]; then
    # File conflict
    exit 1
fi
cat << 'EOF' > "$file"
#!/usr/bin/env bash

# Temporary script

# Check if Fedora
if [[ ! -e /etc/fedora-release ]]; then
    text="This script is for Fedora only."
    zenity --error --text "$text"
    exit 1
fi

# Check old release version
OLD_VERSION=24
CURRENT_VERSION=$(cat /etc/os-release | grep VERSION_ID | cut -f2 -d'=')
NEXT_VERSION=$((CURRENT_VERSION+1))
if [[ ! "$CURRENT_VERSION" =~ ^[0-9]+$ ]]; then
    text="Error determining release version."
    zenity --error --text "$text"
    exit 1
fi
if [[ -n "$OLD_VERSION" && "$OLD_VERSION" != "$CURRENT_VERSION" ]]; then
    text="Current Fedora release version is $CURRENT_VERSION (expected $OLD_VERSION)."
    zenity --error --text "$text"
    exit 1
fi

# Ask
zenity --question --text "This is Fedora version $CURRENT_VERSION. Download upgrade to $NEXT_VERSION now?"
if [[ $? -ne 0 ]]; then
    exit
fi

# Update system-upgrade plugin
output=$(dnf install -y --best --allowerasing dnf-plugin-system-upgrade 2>&1)
if [[ $? -ne 0 ]]; then
    text="Error updating system-upgrade plugin!"
    text=$"$text"'\n'"$output"
    zenity --error --text "$text"
    exit 1
fi

# Download upgrade
output=$(dnf system-upgrade download -y --best --allowerasing --releasever $NEXT_VERSION 2>&1)
if [[ $? -ne 0 ]]; then
    ts=$(date +%s)
    file="/tmp/TMP_INFO_FEDORA_UPGRADE_$ts"
    echo "$output" >"$file"
    text="Error downloading system upgrade! See: $file"
    zenity --error --text "$text"
    exit 1
fi

# Ask
zenity --question --text "Upgrade to version $NEXT_VERSION downloaded successfully. Reboot and install upgrade now?"
if [[ $? -ne 0 ]]; then
    exit
fi

# Start upgrade
output=$(dnf system-upgrade reboot 2>&1)
if [[ $? -ne 0 ]]; then
    text="Error starting system upgrade!"
    text=$"$text"'\n'"$output"
    zenity --error --text "$text"
    exit 1
fi



EOF
chmod +x "$file"

# Run with sudo (gui support, not in terminal)
run_sudo "./$file"

# Clean up
rm "$file"



