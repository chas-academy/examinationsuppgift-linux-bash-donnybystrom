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