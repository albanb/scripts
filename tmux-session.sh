#!/bin/bash
tmux -f $HOME/.config/tmux.conf -q has-session && tmux -f $HOME/.config/tmux.conf attach-session -d || tmux -f $HOME/.config/tmux.conf
