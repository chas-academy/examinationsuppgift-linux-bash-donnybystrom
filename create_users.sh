#!/bin/bash

# Scriptet måste köras som root för att kunna skapa användare.
if [ "$EUID" -ne 0 ]; then
    echo "Fel: kör scriptet som root." >&2
    exit 1
fi

# Minst ett användarnamn ska skickas in som argument.
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 ..." >&2
    exit 1
fi

# Skapa alla användare först.
for username in "$@"; do
    if ! id "$username" &>/dev/null; then
        useradd -m "$username" || {
            echo "Kunde inte skapa användaren $username" >&2
            exit 1
        }
    fi
done

# Sätt upp kataloger och welcome.txt efter att alla användare finns.
for username in "$@"; do
    home_dir="/home/$username"
    groupname="$(id -gn "$username")"

    # Hämta alla användarnamn utom aktuell användare.
    existing_users="$(cut -d: -f1 /etc/passwd | grep -vx "$username")"

    # Skapa kataloger och sätt rättigheter (700 - Endast användaren får full CRUD till katalogerna).
    mkdir -p "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"
    chmod 700 "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"

    # Skapa welcome.txt med en hälsning och listan på andra användare.
    {
        echo "Välkommen $username"
        echo "$existing_users"
    } > "$home_dir/welcome.txt"

    # Sätt ägarskap på kataloger och welcome.txt
    chown -R "$username:$groupname" \
        "$home_dir/Documents" \
        "$home_dir/Downloads" \
        "$home_dir/Work" \
        "$home_dir/welcome.txt"

    # Sätt rättigheter på welcome.txt så att endast ägaren kan läsa + skriva till den.
    chmod 600 "$home_dir/welcome.txt"
done