local core = GuildDeposit

optionsTable = {
    name = "Config",
    desc = "General config",
    type = "group",
    get = function(info) return core.db[info[#info]] end,
	set = function(info, value) core.db[info[#info]] = value end,
    args = {
        general = {
            type = "group",
            name = "General",
            args = {
                interval = {
                    name = "Deposit Interval",
                    desc = "Time interval between a deposit and the next. Try increasing if some deposits are missed.",
                    type = "range",
                    min = 0.1,
                    max = 5.0,
                    step = 0.1
                  },
            }
        }
    }
  }

core.options = optionsTable

function core:SetupConfig()
	local acreg = LibStub("AceConfig-3.0")
    acreg:RegisterOptionsTable("GuildDeposit", optionsTable, "/testconf")
    -- acreg:RegisterOptionsTable("GuildDeposit Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(core.db))

	local acdia = LibStub("AceConfigDialog-3.0")
    acdia:AddToBlizOptions("GuildDeposit", "GuildDeposit")
    -- acdia:AddToBlizOptions("GuildDeposit Profiles", "Profiles", "GuildDeposit")
end

function core:Defaults()
    local defaults = {
        profile = {
            interval = 1.0
        }
    }
    return defaults
end