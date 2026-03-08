local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local cfg = {
	noscripts = false,
	decompile = true,
	deobfuscate = false,
	scriptcontext = true,
	copytoplevel = true,
	copyterrain = true,
	copyplayers = true,
	saveplayers = false,
	maxthreads = 20,
	timeout = 60,
	filename = "SavedGame",
	format = "rbxlx",
	theme = "Default",
	services = {
		Workspace = true,
		Lighting = true,
		ReplicatedStorage = true,
		ReplicatedFirst = true,
		StarterGui = true,
		StarterPack = true,
		StarterPlayer = true,
		Teams = true,
		SoundService = true,
		Chat = true,
		LocalizationService = false,
		TestService = false,
		ServerStorage = false,
		ServerScriptService = false,
	}
}

local saveInProgress = false

local themes = {
	"Default", "Amber/Black", "Aqua", "BrightBlue",
	"Dark", "Green", "Light", "Ocean", "Serenity",
}

local Window = Rayfield:CreateWindow({
	Name = "Save Instance",
	Icon = 0,
	LoadingTitle = "Save Instance",
	LoadingSubtitle = "the strongest decompiler",
	Theme = cfg.theme,
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "SaveInstance",
		FileName = "Config",
	},
	KeySystem = false,
})

local SaveTab     = Window:CreateTab("Save",     4483362458)
local ServicesTab = Window:CreateTab("Services", 4483362458)
local ScriptsTab  = Window:CreateTab("Scripts",  4483362458)
local AdvancedTab = Window:CreateTab("Advanced", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- helpers

local SSI_URL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.luau"

local function loadSSI()
	return loadstring(game:HttpGet(SSI_URL, true), "saveinstance")()
end

local function buildIgnored()
	local t = {}
	for service, enabled in pairs(cfg.services) do
		if not enabled then table.insert(t, service) end
	end
	return t
end

local function buildOptions(overrides)
	local opts = {
		noscripts     = cfg.noscripts,
		decompile     = cfg.decompile,
		deobfuscate   = cfg.deobfuscate,
		scriptcontext = cfg.scriptcontext,
		copytoplevel  = cfg.copytoplevel,
		copyterrain   = cfg.copyterrain,
		saveplayers   = cfg.saveplayers,
		maxthreads    = cfg.maxthreads,
		timeout       = cfg.timeout,
		filepath      = cfg.filename .. "." .. cfg.format,
	}
	if cfg.copyplayers then opts.SavePlayers = true end
	local ignored = buildIgnored()
	if #ignored > 0 then opts.IgnoredServices = ignored end
	if overrides then
		for k, v in pairs(overrides) do opts[k] = v end
	end
	return opts
end

local function runSave(options, label, para)
	if saveInProgress then
		Rayfield:Notify({ Title = "Already running", Content = "Wait for current save to finish.", Duration = 3 })
		return
	end
	saveInProgress = true
	if para then para:Set("Status", label .. "...") end
	task.spawn(function()
		local start = tick()
		local ok, err = pcall(function()
			loadSSI()(options)
		end)
		local elapsed = math.floor(tick() - start)
		saveInProgress = false
		if ok then
			if para then para:Set("Status", ("Done in %ds"):format(elapsed)) end
			Rayfield:Notify({ Title = "Done", Content = ("Saved in %ds"):format(elapsed), Duration = 5 })
		else
			if para then para:Set("Status", "Failed — check console") end
			Rayfield:Notify({ Title = "Failed", Content = tostring(err):sub(1, 120), Duration = 8 })
			warn("[SSI]", err)
		end
	end)
end

-- SAVE TAB

SaveTab:CreateSection("Output")

SaveTab:CreateInput({
	Name = "File Name",
	PlaceholderText = "SavedGame",
	RemoveTextAfterFocusLost = false,
	Callback = function(v)
		if v ~= "" then cfg.filename = v end
	end,
})

SaveTab:CreateDropdown({
	Name = "Format",
	Options = {"rbxlx", "rbxl"},
	CurrentOption = {"rbxlx"},
	Flag = "Format",
	Callback = function(v) cfg.format = v[1] or "rbxlx" end,
})

SaveTab:CreateSection("Run")

local statusPara = SaveTab:CreateParagraph({ Title = "Status", Content = "Ready." })

SaveTab:CreateButton({
	Name = "Give Me the Cheddar",
	Callback = function()
		runSave(buildOptions(), "Saving", statusPara)
	end,
})

SaveTab:CreateButton({
	Name = "Quick Save  (no scripts)",
	Callback = function()
		runSave(buildOptions({
			noscripts  = true,
			decompile  = false,
			filepath   = cfg.filename .. "_quick." .. cfg.format,
		}), "Quick saving", statusPara)
	end,
})

SaveTab:CreateButton({
	Name = "Scripts Only",
	Callback = function()
		local allServices = {}
		for k in pairs(cfg.services) do table.insert(allServices, k) end
		runSave({
			decompile       = cfg.decompile,
			deobfuscate     = cfg.deobfuscate,
			scriptcontext   = cfg.scriptcontext,
			IgnoredServices = allServices,
			filepath        = cfg.filename .. "_scripts." .. cfg.format,
			maxthreads      = cfg.maxthreads,
			timeout         = cfg.timeout,
		}, "Saving scripts", statusPara)
	end,
})

-- SERVICES TAB

ServicesTab:CreateSection("Core")

ServicesTab:CreateToggle({ Name = "Workspace",          CurrentValue = cfg.services.Workspace,          Flag = "sWorkspace",    Callback = function(v) cfg.services.Workspace = v end })
ServicesTab:CreateToggle({ Name = "Terrain",            CurrentValue = cfg.copyterrain,                 Flag = "sTerrain",      Callback = function(v) cfg.copyterrain = v end })
ServicesTab:CreateToggle({ Name = "Players",            CurrentValue = cfg.copyplayers,                 Flag = "sPlayers",      Callback = function(v) cfg.copyplayers = v end })
ServicesTab:CreateToggle({ Name = "Save Player Data",   CurrentValue = cfg.saveplayers,                 Flag = "sSavePlayers",  Callback = function(v) cfg.saveplayers = v end })
ServicesTab:CreateToggle({ Name = "Lighting",           CurrentValue = cfg.services.Lighting,           Flag = "sLighting",     Callback = function(v) cfg.services.Lighting = v end })
ServicesTab:CreateToggle({ Name = "ReplicatedStorage",  CurrentValue = cfg.services.ReplicatedStorage,  Flag = "sRepStorage",   Callback = function(v) cfg.services.ReplicatedStorage = v end })
ServicesTab:CreateToggle({ Name = "ReplicatedFirst",    CurrentValue = cfg.services.ReplicatedFirst,    Flag = "sRepFirst",     Callback = function(v) cfg.services.ReplicatedFirst = v end })

ServicesTab:CreateSection("Starter")

ServicesTab:CreateToggle({ Name = "StarterGui",     CurrentValue = cfg.services.StarterGui,     Flag = "sGui",    Callback = function(v) cfg.services.StarterGui = v end })
ServicesTab:CreateToggle({ Name = "StarterPack",    CurrentValue = cfg.services.StarterPack,    Flag = "sPack",   Callback = function(v) cfg.services.StarterPack = v end })
ServicesTab:CreateToggle({ Name = "StarterPlayer",  CurrentValue = cfg.services.StarterPlayer,  Flag = "sPlayer", Callback = function(v) cfg.services.StarterPlayer = v end })

ServicesTab:CreateSection("Other")

ServicesTab:CreateToggle({ Name = "Teams",               CurrentValue = cfg.services.Teams,               Flag = "sTeams",   Callback = function(v) cfg.services.Teams = v end })
ServicesTab:CreateToggle({ Name = "SoundService",        CurrentValue = cfg.services.SoundService,        Flag = "sSound",   Callback = function(v) cfg.services.SoundService = v end })
ServicesTab:CreateToggle({ Name = "Chat",                CurrentValue = cfg.services.Chat,                Flag = "sChat",    Callback = function(v) cfg.services.Chat = v end })
ServicesTab:CreateToggle({ Name = "LocalizationService", CurrentValue = cfg.services.LocalizationService, Flag = "sLocale",  Callback = function(v) cfg.services.LocalizationService = v end })
ServicesTab:CreateToggle({ Name = "TestService",         CurrentValue = cfg.services.TestService,         Flag = "sTest",    Callback = function(v) cfg.services.TestService = v end })

ServicesTab:CreateSection("Server-Side")

ServicesTab:CreateToggle({ Name = "ServerStorage",      CurrentValue = cfg.services.ServerStorage,      Flag = "sSS",  Callback = function(v) cfg.services.ServerStorage = v end })
ServicesTab:CreateToggle({ Name = "ServerScriptService", CurrentValue = cfg.services.ServerScriptService, Flag = "sSSS", Callback = function(v) cfg.services.ServerScriptService = v end })

ServicesTab:CreateSection("Bulk")

ServicesTab:CreateButton({
	Name = "Enable All",
	Callback = function()
		for k in pairs(cfg.services) do cfg.services[k] = true end
		cfg.copyterrain = true
		cfg.copyplayers = true
		Rayfield:Notify({ Title = "All enabled", Content = "", Duration = 2 })
	end,
})

ServicesTab:CreateButton({
	Name = "Disable All",
	Callback = function()
		for k in pairs(cfg.services) do cfg.services[k] = false end
		cfg.copyterrain = false
		cfg.copyplayers = false
		Rayfield:Notify({ Title = "All disabled", Content = "", Duration = 2 })
	end,
})

-- SCRIPTS TAB

ScriptsTab:CreateSection("Decompiler")

ScriptsTab:CreateToggle({ Name = "Decompile",                 CurrentValue = cfg.decompile,     Flag = "Decompile",     Callback = function(v) cfg.decompile = v end })
ScriptsTab:CreateToggle({ Name = "Deobfuscate",               CurrentValue = cfg.deobfuscate,   Flag = "Deobfuscate",   Callback = function(v) cfg.deobfuscate = v end })
ScriptsTab:CreateToggle({ Name = "Script Context",            CurrentValue = cfg.scriptcontext, Flag = "ScriptContext",  Callback = function(v) cfg.scriptcontext = v end })
ScriptsTab:CreateToggle({ Name = "Skip Scripts (fastest)",    CurrentValue = cfg.noscripts,     Flag = "NoScripts",     Callback = function(v) cfg.noscripts = v end })
ScriptsTab:CreateToggle({ Name = "Copy Top-Level Instances",  CurrentValue = cfg.copytoplevel,  Flag = "CopyTopLevel",  Callback = function(v) cfg.copytoplevel = v end })

ScriptsTab:CreateSection("Notes")

ScriptsTab:CreateParagraph({ Title = "Deobfuscate", Content = "Tries to reverse script obfuscation. Much slower. Only turn on if you need readable source." })
ScriptsTab:CreateParagraph({ Title = "Skip Scripts", Content = "Skips all script decompilation entirely. Fastest possible save but you get no code." })

-- ADVANCED TAB

AdvancedTab:CreateSection("Performance")

AdvancedTab:CreateSlider({ Name = "Max Threads", Range = {1, 50}, Increment = 1,  Suffix = "threads", CurrentValue = cfg.maxthreads, Flag = "MaxThreads", Callback = function(v) cfg.maxthreads = v end })
AdvancedTab:CreateSlider({ Name = "Timeout",     Range = {10, 300}, Increment = 5, Suffix = "s",      CurrentValue = cfg.timeout,    Flag = "Timeout",    Callback = function(v) cfg.timeout = v end })

AdvancedTab:CreateSection("Presets")

AdvancedTab:CreateButton({
	Name = "Max Quality",
	Callback = function()
		cfg.decompile = true cfg.deobfuscate = true cfg.scriptcontext = true
		cfg.noscripts = false cfg.copyterrain = true cfg.copyplayers = true
		cfg.copytoplevel = true cfg.maxthreads = 20 cfg.timeout = 180
		for k in pairs(cfg.services) do cfg.services[k] = true end
		Rayfield:Notify({ Title = "Max Quality", Content = "Everything on, decompile + deobfuscate.", Duration = 4 })
	end,
})

AdvancedTab:CreateButton({
	Name = "Max Speed",
	Callback = function()
		cfg.noscripts = true cfg.decompile = false cfg.deobfuscate = false
		cfg.copyterrain = false cfg.saveplayers = false
		cfg.maxthreads = 50 cfg.timeout = 30
		Rayfield:Notify({ Title = "Max Speed", Content = "No scripts, no terrain, max threads.", Duration = 4 })
	end,
})

AdvancedTab:CreateButton({
	Name = "Balanced",
	Callback = function()
		cfg.decompile = true cfg.deobfuscate = false cfg.scriptcontext = true
		cfg.noscripts = false cfg.copyterrain = true cfg.copyplayers = true
		cfg.copytoplevel = true cfg.maxthreads = 20 cfg.timeout = 60
		Rayfield:Notify({ Title = "Balanced", Content = "Good speed, full decompile, no deobfuscate.", Duration = 3 })
	end,
})

-- SETTINGS TAB

SettingsTab:CreateSection("Appearance")

SettingsTab:CreateDropdown({
	Name = "Theme",
	Options = themes,
	CurrentOption = {cfg.theme},
	Flag = "Theme",
	Callback = function(v)
		cfg.theme = v[1] or "Default"
		Rayfield:Notify({ Title = "Theme changed", Content = "Restart script to apply: " .. cfg.theme, Duration = 4 })
	end,
})

SettingsTab:CreateSection("Config")

SettingsTab:CreateButton({
	Name = "Save Config",
	Callback = function()
		Rayfield:SaveConfiguration()
		Rayfield:Notify({ Title = "Saved", Content = "", Duration = 2 })
	end,
})

SettingsTab:CreateButton({
	Name = "Reset to Default",
	Callback = function()
		cfg.noscripts = false cfg.decompile = true cfg.deobfuscate = false
		cfg.scriptcontext = true cfg.copytoplevel = true cfg.copyterrain = true
		cfg.copyplayers = true cfg.saveplayers = false cfg.maxthreads = 20
		cfg.timeout = 60 cfg.filename = "SavedGame" cfg.format = "rbxlx"
		for k in pairs(cfg.services) do cfg.services[k] = true end
		cfg.services.ServerStorage = false
		cfg.services.ServerScriptService = false
		cfg.services.LocalizationService = false
		cfg.services.TestService = false
		Rayfield:Notify({ Title = "Reset", Content = "All settings back to default.", Duration = 3 })
	end,
})

SettingsTab:CreateSection("About")

SettingsTab:CreateParagraph({ Title = "Save Instance", Content = "Powered by UniversalSynSaveInstance (github.com/luau/UniversalSynSaveInstance). Works on most executors that support HttpGet and file writing." })
SettingsTab:CreateParagraph({ Title = "Tips", Content = "Lower thread count if the game crashes. Server-side services usually fail on the client. Large games with deobfuscation can take several minutes." })

Rayfield:LoadConfiguration()
