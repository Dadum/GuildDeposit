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
            descStyle = 'inline',
            type = "toggle",
            width = 'full',
            order = 1,
            set = function(info, val) core.conf.showStatus = val end,
            get = function(info) return core.conf.showStatus end
        },
        autoDeposit = {
            name = L["Auto Deposit"],
            desc = L["Automatically start deposit when guild bank is opened"],
            descStyle = 'inline',
            type = "toggle",
            width = 'full',
            order = 2,
            set = function(info, val) core.conf.autoDeposit = val end,
            get = function(info) return core.conf.autoDeposit end
        },
        depositInterval = {
            name = L["Deposit Interval"],
            desc = L["Time interval between a deposit and the next. Try increasing if some deposits are missed."],
            type = "range",
            width = 'full',
            order = 3,
            min = 0.1,
            max = 5.0,
            step = 0.1,
            set = function(info, val) core.conf.depositInterval = val end,
            get = function(info) return core.conf.depositInterval end
        },
        withdrawInterval = {
            name = L["Withdraw Interval"],
            desc = L["Time interval between a withdraw and the next. Try increasing if some withdraws are missed."],
            type = "range",
            width = 'full',
            order = 4,
            min = 0.1,
            max = 5.0,
            step = 0.1,
            set = function(info, val)
                core.conf.withdrawInterval = val
            end,
            get = function(info) return core.conf.withdrawInterval end
        },
        slashtitle = {name = L["Slash commands"], type = 'header', order = 20},
        gdesc = {
            name = L["/gd | /guilddeposit: open GuildDeposit configuration."],
            type = 'description',
            order = 30
        },
        depdesc = {
            name = L["/gdeposit | /gdep: deposit items."],
            type = 'description',
            order = 40
        },
        withdesc = {
            name = L["/gdwithdraw <tab_number>: withdraw all the items from tab <tab_number>. If no number is specified, the current tab will be used."],
            type = 'description',
            order = 50
        },
        mapbagdesc = {
            name = L["/gdbag <bag_nubmer> <tab_number>: add all the items contained in bag <bag_number> to the map for tab <tab_number>."],
            type = 'description',
            order = 60
        },
        maptabdesc = {
            name = L["/gdtab <tab_number>: add all the items in tab <tab_number>. If no tab is provided, the current tab is used."],
            type = 'description',
            order = 70
        },
        printmapdesc = {
            name = L["/gdprint: prints the mappings in chat"],
            type = 'description',
            order = 80
        },
        clearmapdesc = {
            name = L["/gdclear: clears all mappings"],
            type = 'description',
            order = 90
        }
    }
}

core.defaults = {
    profile = {
        showStatus = true,
        autoDeposit = false,
        depositInterval = 0.5,
        withdrawInterval = 0.5,
        map = {}
    }
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
