local core = GuildDeposit
local _, L = ...

core.options = {
    type = "group",
    -- get = function(info) return core.conf[info.arg] end,
    -- set = function(info, value) core.conf[info.arg] = value end,
    args = {
        showStatus = {
            name = L["Show Progress Bar"],
            desc = L["Toggle visibility of progress bar while storing items"],
            type = "toggle",
            order = 1,
            set = function(info, val) core.conf.showStatus = val end,
            get = function(info) return core.conf.showStatus end
        },
        -- TODO: implement
        autoDeposit = {
            name = L["Auto Deposit"],
            desc = L["Automatically start deposit when guild bank is open"],
            type = "toggle",
            order = 2,
            set = function(info, val) core.conf.autoDeposit = val end,
            get = function(info) return core.conf.autoDeposit end
        },
        interval = {
            name = L["Deposit Interval"],
            desc = L["Time interval between a deposit and the next. Try increasing if some deposits are missed."],
            type = "range",
            min = 0.1,
            max = 5.0,
            step = 0.1,
            order = 3,
            set = function(info, val) core.conf.interval = val end,
            get = function(info) return core.conf.interval end
        }
    }
}

core.defaults = {
    profile = {showStatus = true, autoDeposit = false, interval = 0.5}
}

function core:SetupConfig()
    local acreg = LibStub("AceConfig-3.0")
    acreg:RegisterOptionsTable("GuildDeposit", core.options)
    acreg:RegisterOptionsTable("GuildDeposit Profiles", LibStub(
                                   "AceDBOptions-3.0"):GetOptionsTable(core.db))

    local acdia = LibStub("AceConfigDialog-3.0")
    acdia:AddToBlizOptions("GuildDeposit", "GuildDeposit")
    acdia:AddToBlizOptions("GuildDeposit Profiles", "Profiles", "GuildDeposit")
end

-- function core:Defaults()
--     local defaults = {
--         profile = {
--             interval = 0.5   
--         }
--     }
--     return defaults
-- end
