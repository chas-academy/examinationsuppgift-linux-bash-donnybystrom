#!/bin/bash

# Scriptet måste köras som root för att kunna skapa användare.
if [ "$EUID" -ne 0 ]; then
    echo "Fel: kör scriptet som root." >&2
    exit 1
fi