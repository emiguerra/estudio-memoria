#!/bin/zsh
# Doble clic para abrir el editor de la memoria.
cd "$(dirname "$0")"
( sleep 4; open "http://127.0.0.1:8790" ) &
python3 servidor_memoria.py
