#!/bin/bash

TRANS=$(wl-paste -p | trans -no-ansi -x 127.0.0.1:20173 :zh)

notify-send "$TRANS"
