# Introduction

This is a Lightroom Classic script, written in Lua. It auto applies some develop settings to selected photos.

Currently, it just auto sets the luminance and color noise reduction values, based on photo ISO speed. The fomula is:
- Luminance noise reduction = ISO speed / 33, but in range [5, 30]
- Color noise reduction = default, but no less than Luminance noise reduction

Some develop settings, such as Presence, Sharping, Post-Crop Vignetting, etc., can start with fixed values. This can be archieved by a user preset.
After applying a user preset, they should be tweaked case by case. They depend on the unique creativeness of a human, and cannot be simply calculated by a program.


# How To Use

## How To Install

1. Identify Lightroom Classic user scripts folder:
   - In macOS, it's `~/Library/Application Support/Adobe/Lightroom/Scripts/` by default.
   - In Windows, it's `C:\Users\<yourname>\AppData\Roaming\Adobe\Lightroom\Scripts\` by default.
   - If you do not see the **Scripts** menu (the last menu, after **Help** menu) in Lightroom Classic, manually create the folder above, and restart Lightroom Classic.
   - If you see the **Scripts** menu in Lightroom Classic, clicking the **Open User Scripts Folder** menu item will open the **Scripts** folder.
2. Clone or download this repo.
3. Copy the **Auto Develop.lua** script file to Lightroom Classic user scripts folder, or create a hard link to it.
4. Start/restart Lightroom Classic so that it can recognize this script.

## How To Run

1. Switch to Lightroom Classic **Library** module.
2. Select some photos.
3. From the **Scripts** menu, run **Auto Develop**.
4. Wait for the operation to complete.

## Tested

 - macOS Monterey + Lightroom Classic 13.
 - Windows 10 22H2 + Lightroom Classic 13.


# Statements

- USE AT YOUR OWN RISK.
- I'm not responsible for any data corruption.
- Whether answering any issues depends on what I feel.
