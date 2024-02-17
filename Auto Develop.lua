--[[
MIT License

Copyright (c) 2024 https://github.com/shuangye/

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local LrTasks = import "LrTasks"
local catalog = import "LrApplication".activeCatalog()
local ProgressScope = import "LrProgressScope"
local LrDialogs = import "LrDialogs"
local LrLogger = import "LrLogger"

local scriptName = "Auto Develop"

-- Follow Lightroom Classic SDK Guide to see the logs
local myLogger = LrLogger("libraryLogger")  -- log file name; will be in ~/Documents/LrClassicLogs/
-- myLogger:enable("logfile")
-- myLogger:enable("print")


function mylog(content)
    local label = scriptName
    -- print("[" .. label .. "] " .. content)
    myLogger:trace("[" .. label .. "] " .. content)
end


function setDevelopSettings(settings, key, value)
    local changed = false
    local original = settings[key]
    if original ~= value then
        settings[key] = value
        changed = true
    end
    return changed
end


-- Handles one photo
function processPhoto(photo)
    local fileName = photo:getFormattedMetadata("fileName")
    local format = photo:getRawMetadata("fileFormat")
    if format == "VIDEO" then
        return
    end

    local iso = photo:getRawMetadata("isoSpeedRating")  -- a number
    if iso == nil then
        mylog(fileName .. ": unable to get ISO speed")
        return
    end

    local changed = false
    local developSettings = photo:getDevelopSettings()  -- a table
    local factor = 33    -- ISO <= 100: Luminance NR = 5; ISO >= 1000: Luminance NR = 30

    -- Luminance noise always exists. So limit the min value.
    -- Luminance noise reduction becomes less effective when > 30
    local luminanceNoiseReductionMin, luminanceNoiseReductionMax = 5, 30

    -- Convert to integer to prevent fake changed value in `setDevelopSettings()`
    -- Seems Lightroom internal Lua interpreter does not support `//` operator: unexpected symbol near '/'
    local luminanceNoiseReduction = math.floor(iso / factor)

    if luminanceNoiseReduction < luminanceNoiseReductionMin then
        luminanceNoiseReduction = luminanceNoiseReductionMin
    end
    if luminanceNoiseReduction > luminanceNoiseReductionMax then
        luminanceNoiseReduction = luminanceNoiseReductionMax
    end

    local colorNoiseReduction = developSettings["ColorNoiseReduction"]  -- number
    if colorNoiseReduction < luminanceNoiseReduction then
        colorNoiseReduction = luminanceNoiseReduction
    end

    mylog(fileName .. ": ISO = " .. iso .. ", will set luminance NR = " .. luminanceNoiseReduction .. ", color NR = " .. colorNoiseReduction)

    local ret = setDevelopSettings(developSettings, "LuminanceSmoothing", luminanceNoiseReduction)
    changed = changed or ret
    ret = setDevelopSettings(developSettings, "ColorNoiseReduction", colorNoiseReduction)
    changed = changed or ret
    if changed then
        catalog:withWriteAccessDo(scriptName, function(context)
            photo:applyDevelopSettings(developSettings, scriptName, false)
        end )
    end
end


LrTasks.startAsyncTask(function()
    -- If there is a selection, `catalog:getTargetPhotos()` returns the list of selected photos.
    -- Otherwise, it returns the entire list of photos in the filmstrip.
    -- Returning the entire list of photos in the filmstrip is not desired, so do nothing if no selection.
    if catalog:getTargetPhoto() == nil then
        mylog("No photos selected. Nothing to do.")
        return
    end

    local photos = catalog:getTargetPhotos()
    local count = #photos

    --[[
    prompt = "Will apply auto develop settings to " .. count .. " photo(s)..."
    local ret = LrDialogs.confirm(scriptName, prompt)
    if ret ~= "ok" then
        return
    end
    ]]

    local progressScope = ProgressScope({ title = scriptName, caption = scriptName, })

    for i, photo in ipairs(photos) do
        processPhoto(photo)
        -- LrTasks.sleep(2)    -- Simulate a time-consuming operation, to check whether the ProgressScope updates correctly.
        progressScope:setPortionComplete(i / count)
        progressScope:setCaption("Processing " .. i .. "/" .. count)
    end

    progressScope:done()
end )
