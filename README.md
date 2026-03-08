-- Universal Save Instance — Rayfield UI
-- Paste into your executor and run in-game

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Save Instance",
    LoadingTitle = "Save Instance",
    LoadingSubtitle = "by Universal SSI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SaveInstance",
        FileName = "Config"
    },
    KeySystem = false,
})

-- ══ TABS ══

local SaveTab    = Window:CreateTab("💾 Save",     4483362458)
local OptionsTab = Window:CreateTab("⚙️ Options",  4483362458)
local InfoTab    = Window:CreateTab("ℹ️ Info",     4483362458)

-- ══════════════════════════════════════════════════
--  OPTIONS TAB — Settings
-- ══════════════════════════════════════════════════

OptionsTab:CreateSection("What To Copy")

local copyPlayers = true
local copyWorkspace = true
local copyLighting = true
local copyReplicatedStorage = true
local copyServerStorage = false
local copyStarterGui = true
local copyStarterPack = true
local copyServerScriptService = false

OptionsTab:CreateToggle({
    Name = "Copy Workspace",
    CurrentValue = copyWorkspace,
    Flag = "CopyWorkspace",
    Callback = function(v) copyWorkspace = v end,
})

OptionsTab:CreateToggle({
    Name = "Copy Players (Characters)",
    CurrentValue = copyPlayers,
    Flag = "CopyPlayers",
    Callback = function(v) copyPlayers = v end,
})

OptionsTab:CreateToggle({
    Name = "Copy Lighting",
    CurrentValue = copyLighting,
    Flag = "CopyLighting",
    Callback = function(v) copyLighting = v end,
})

OptionsTab:CreateToggle({
    Name = "Copy ReplicatedStorage",
    CurrentValue = copyReplicatedStorage,
    Flag = "CopyReplicatedStorage",
    Callback = function(v) copyReplicatedStorage = v end,
})

OptionsTab:CreateToggle({
    Name = "Copy StarterGui",
    CurrentValue = copyStarterGui,
    Flag = "CopyStarterGui",
    Callback = function(v) copyStarterGui = v end,
})

OptionsTab:CreateToggle({
    Name = "Copy StarterPack",
    CurrentValue = copyStarterPack,
    Flag = "CopyStarterPack",
    Callback = function(v) copyStarterPack = v end,
})

OptionsTab:CreateToggle({
    Name = "Copy ServerStorage (may fail client-side)",
    CurrentValue = copyServerStorage,
    Flag = "CopyServerStorage",
    Callback = function(v) copyServerStorage = v end,
})

OptionsTab:CreateToggle({
    Name = "Copy ServerScriptService (may fail client-side)",
    CurrentValue = copyServerScriptService,
    Flag = "CopySSS",
    Callback = function(v) copyServerScriptService = v end,
})

OptionsTab:CreateSection("Strength / Decompile Settings")

local scriptDecompile = true
local noscripts = false
local deobfuscate = false
local scriptContext = true

OptionsTab:CreateToggle({
    Name = "Decompile Scripts",
    CurrentValue = scriptDecompile,
    Flag = "ScriptDecompile",
    Callback = function(v)
        scriptDecompile = v
        -- if decompile is off, noscripts must be on to skip scripts entirely
        if not v then
            Rayfield:Notify({
                Title = "Heads Up",
                Content = "Scripts won't be decompiled — they'll be saved as empty stubs.",
                Duration = 4,
            })
        end
    end,
})

OptionsTab:CreateToggle({
    Name = "Skip Scripts Entirely (faster save)",
    CurrentValue = noscripts,
    Flag = "NoScripts",
    Callback = function(v) noscripts = v end,
})

OptionsTab:CreateToggle({
    Name = "Attempt Deobfuscation",
    CurrentValue = deobfuscate,
    Flag = "Deobfuscate",
    Callback = function(v) deobfuscate = v end,
})

OptionsTab:CreateToggle({
    Name = "Include ScriptContext (LocalScripts etc.)",
    CurrentValue = scriptContext,
    Flag = "ScriptContext",
    Callback = function(v) scriptContext = v end,
})

OptionsTab:CreateSection("File")

local fileName = "SavedGame"
local fileFormat = ".rbxlx"

OptionsTab:CreateInput({
    Name = "Output File Name",
    PlaceholderText = "SavedGame",
    RemoveTextAfterFocusLost = false,
    Callback = function(v)
        if v and v ~= "" then fileName = v end
    end,
})

local formatOptions = {".rbxlx", ".rbxl"}
local selectedFormat = ".rbxlx"

OptionsTab:CreateDropdown({
    Name = "File Format",
    Options = formatOptions,
    CurrentOption = {".rbxlx"},
    Flag = "FileFormat",
    Callback = function(v) selectedFormat = v[1] or ".rbxlx" end,
})

-- ══════════════════════════════════════════════════
--  SAVE TAB — The button
-- ══════════════════════════════════════════════════

SaveTab:CreateSection("Run Save Instance")

SaveTab:CreateParagraph({
    Title = "How It Works",
    Content = "Saves the full game world to your executor's workspace folder as an .rbxlx file. Configure what to copy in the Options tab first, then hit the button below.",
})

SaveTab:CreateButton({
    Name = "🧀 Give Me the Cheddar",
    Callback = function()
        Rayfield:Notify({
            Title = "Saving...",
            Content = "Starting save — this may take a moment.",
            Duration = 3,
        })

        task.spawn(function()
            local ok, err = pcall(function()

                -- Build options from UI state
                local Options = {
                    -- Script handling
                    noscripts       = noscripts,
                    decompile       = scriptDecompile,
                    scriptcontext   = scriptContext,

                    -- Services to include
                    -- SSI uses a "SavePlayers" style flag
                    SavePlayers     = copyPlayers,

                    -- File output
                    -- SSI saves to workspace/<filename>.rbxlx by default
                    -- We can't fully control the path from Options but we set what we can
                }

                -- Build ignored services list based on toggles
                local ignoredServices = {}
                if not copyWorkspace          then table.insert(ignoredServices, "Workspace") end
                if not copyLighting           then table.insert(ignoredServices, "Lighting") end
                if not copyReplicatedStorage  then table.insert(ignoredServices, "ReplicatedStorage") end
                if not copyServerStorage      then table.insert(ignoredServices, "ServerStorage") end
                if not copyStarterGui         then table.insert(ignoredServices, "StarterGui") end
                if not copyStarterPack        then table.insert(ignoredServices, "StarterPack") end
                if not copyServerScriptService then table.insert(ignoredServices, "ServerScriptService") end

                if #ignoredServices > 0 then
                    Options.IgnoredServices = ignoredServices
                end

                -- Load and run SSI
                local Params = {
                    RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
                    SSI = "saveinstance",
                }

                local synsaveinstance = loadstring(
                    game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true),
                    Params.SSI
                )()

                synsaveinstance(Options)
            end)

            if ok then
                Rayfield:Notify({
                    Title = "✅ Done!",
                    Content = "Game saved to your executor workspace folder.",
                    Duration = 6,
                })
            else
                Rayfield:Notify({
                    Title = "❌ Save Failed",
                    Content = tostring(err):sub(1, 120),
                    Duration = 8,
                })
                warn("[SSI] Error:", err)
            end
        end)
    end,
})

SaveTab:CreateSection("Last Save Info")

SaveTab:CreateParagraph({
    Title = "Output Location",
    Content = "Files save to: [Executor Folder] / workspace / " .. fileName .. selectedFormat,
})

-- ══════════════════════════════════════════════════
--  INFO TAB
-- ══════════════════════════════════════════════════

InfoTab:CreateSection("About")

InfoTab:CreateParagraph({
    Title = "Universal Syn Save Instance",
    Content = "Open-source save instance library by the luau team. Saves the current game's DataModel to a .rbxlx file you can open in Roblox Studio.",
})

InfoTab:CreateParagraph({
    Title = "Docs",
    Content = "https://luau.github.io/UniversalSynSaveInstance/api/SynSaveInstance",
})

InfoTab:CreateParagraph({
    Title = "Tips",
    Content = "• Decompile ON = slower but you get script source\n• Skip Scripts = fastest save, no code\n• ServerStorage/SSS often fail client-side — leave off unless you know they're accessible\n• Larger games take longer — be patient after hitting the button",
})

-- Done
Rayfield:LoadConfiguration()
