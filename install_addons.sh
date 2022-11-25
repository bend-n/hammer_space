#!/usr/bin/env bash
rm -rf addons && mkdir addons
if [[ -d ~/godot-package-manager ]]; then
    cp -r ~/godot-package-manager/addons/godot-package-manager addons/gpm
else
    git clone --depth 1 https://github.com/you-win/godot-package-manager gpm/
    mv gpm/addons/godot-package-manager addons/gpm
    rm -r gpm/
fi
godot -s --no-window addons/gpm/cli.gd update
rm -r addons/gpm
