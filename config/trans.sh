#!/bin/bash

TRANS=$(wl-paste -p | trans -no-ansi -x 127.0.0.1:2080 :zh)

notify-send "$TRANS"
