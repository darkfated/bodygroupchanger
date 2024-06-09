--[[
    * BodygroupChanger *
    GitHub: https://github.com/darkfated/bodygroupchanger
    Author's discord: darkfated
]]--

local function run_scripts()
    Mantle.run_cl('client.lua')
    Mantle.run_sv('server.lua')
end

local function init()
    BodygroupChanger = BodygroupChanger or {}

    run_scripts()
end

init()
