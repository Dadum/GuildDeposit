local core = GuildDeposit
local _, L = ...

core.options = {
    type = "group",
    -- get = function(info) return core.conf[info.arg] end,
	-- set = function(info, value) core.conf[info.arg] = value end,
    args = {
        general = {
            type = "group",
            name = L["General"],
            args = {
                interval = {
                    name = L["Deposit Interval"],
                    desc = L["Time interval between a deposit and the next. Try increasing if some deposits are missed."],
                    type = "range",
                    min = 0.1,
                    max = 5.0,
                    step = 0.1,
                    set = function(info, val) core.conf.interval = val end,
                    get = function(info) return core.conf.interval end
                },
                -- maps = {
                --     -- name = "Mappings",
                --     type = "multiselect",
                --     values = core.db.mappings
                -- }
            }
        }
    }
}

core.defaults = {
    profile = {
        interval = 0.5
    }
}

function core:SetupConfig()
	local acreg = LibStub("AceConfig-3.0")
    acreg:RegisterOptionsTable("GuildDeposit", core.options)
    -- acreg:RegisterOptionsTable("GuildDeposit Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(core.db))

	local acdia = LibStub("AceConfigDialog-3.0")
    acdia:AddToBlizOptions("GuildDeposit", "GuildDeposit")
    -- acdia:AddToBlizOptions("GuildDeposit Profiles", "Profiles", "GuildDeposit")
end

-- function core:Defaults()
--     local defaults = {
--         profile = {
--             interval = 0.5   
--         }
--     }
--     return defaults
-- end
