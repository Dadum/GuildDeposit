local core = GuildDeposit

optionsTable = {
    name = "Config",
    desc = "General config",
    type = "group",
    -- get = function(info) return core.conf[info.arg] end,
	-- set = function(info, value) core.conf[info.arg] = value end,
    args = {
        general = {
            type = "group",
            name = "General",
            args = {
                interval = {
                    name = "Deposit Interval",
                    desc = "Time interval between a deposit and the next. Try increasing if some deposits are missed.",
                    descStyle = "inline",
                    type = "range",
                    min = 0.1,
                    max = 3.0,
                    step = 0.1,
                    set = function(info, val) core.conf.interval = val end,
                    get = function(info) return core.conf.interval end
                  },
            }
        }
    }
  }

core.options = optionsTable

function core:SetupConfig()
	local acreg = LibStub("AceConfig-3.0")
    acreg:RegisterOptionsTable("GuildDeposit", optionsTable)
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

core.defaults = {
    profile = {
        interval = 0.5
    }
}