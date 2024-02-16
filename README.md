# Introduction

This is a Lightroom Classic script, written in Lua. It auto applies some develop settings to selected photos.

Currently, it just auto sets the luminance and color noise reduction values, based on photo ISO speed. The fomula is:

- Luminance noise reduction = ISO speed / 33, but in range [5, 30]
- Color noise reduction = default AND, but no less than Luminance noise reduction

# How To Use

How to install:
1. Clone or download this repo.
2. Copy the **Auto Develop.lua** file to Lightroom Classic user scripts folder.
    - Lightroom Classic user scripts folder can be found by clicking the **Open User Scripts Folder** menu item under **Scripts** menu (the last menu, after **Help** menu).
    - Optionally, you can create a hard link, instead of copying the file.
3. Start/restart Lightroom Classic so that it can recognize this script.

How to run:
1. Switch to Lightroom Classic **Library** module.
2. Select some photos.
3. From the **Scripts** menu, run **Auto Develop**.
4. Wait for the operation to complete.

# Statements

- USE AT YOUR OWN RISK.
- I'm not responsible for any data corruption.
- Whether answering to any issues depends on my mood.

Tested with macOS Monterey + Lightroom Classic 13.0.1. High CPU usage when run this script. Do not know why yet. It's not easy to debug Lightroom scripts.