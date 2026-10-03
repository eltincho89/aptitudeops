#!/bin/bash
set -ex
export LANG=C LC_ALL=C
plymouth-set-default-theme -R aptitudeops
dconf update
