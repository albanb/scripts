#!/bin/bash

case $1 in
play)
mocp -G
;;
next)
mocp -f
;;
previous)
mocp -r
;;
esac
