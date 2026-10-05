local base =
    "https://raw.githubusercontent.com/sspeth000/robloxexplorer/main/"

local explorerSource =
    game:HttpGet(base .. "explorer.luau")

local scriptsSource =
    game:HttpGet(base .. "scripts.luau")


--------------------------------------------------
-- LOAD SCRIPTS
--------------------------------------------------

local scriptsChunk = loadstring(scriptsSource)

if not scriptsChunk then
    error("Failed to load scripts.luau")
end

local scripts = scriptsChunk()


--------------------------------------------------
-- LOAD EXPLORER
--------------------------------------------------

local explorerChunk = loadstring(explorerSource)

if not explorerChunk then
    error("Failed to load explorer.luau")
end

explorerChunk(scripts)
