local core = GuildDeposit
local _, L = ...

-- get available tabs in a table
local GetTabs = function()
    local ntabs = GetNumGuildBankTabs()
    local tabs = {}
    for i = 1, ntabs, 1 do table.insert(tabs, i) end
    return tabs
end

-- get map as string
local GetMapString = function(info)
    local str = ""
    for k, v in pairs(core.conf.map) do
        local info = core.conf.itemInfo[k]
        if not info then return "error" end
        str = str .. info.link .. "-" .. v .. "\n"
    end
    return str
end

-- parse input string to map
local ParseMapString = function(info, val)
    local linesplit = {strsplit("\n", val)}
    local temp = {}
    for _, i in pairs(linesplit) do
        local key, tab = strsplit("-", i)
        -- skip empty lines
        if key and tab then
            local tabnum = tonumber(tab)
            if not tabnum then
                print(
                    L["ERROR: wrong format, tab must bee a number!. See usage for more info"])
                return
            end
            local id = GetItemInfoInstant(key)
            if not id then
                print(L["ERROR: invalid item!"])
                return
            end
            table.insert(temp, id, tabnum)
        end
    end
    core.conf.map = temp
end

local AddMap = function()
    if core.t1 and core.t2 then
        local id = GetItemInfoInstant(core.t1)
        if not id then print(L["ERROR: invalid item."]) 
        return
        end
        table.insert(core.conf.map, id, core.t2)
    else 
        print("ERROR: invalid input.")
    end
end

local generalOptions = {
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
        set = function(info, val) core.conf.withdrawInterval = val end,
        get = function(info) return core.conf.withdrawInterval end
    }
}

local mapOptions = {
    addSection = {name = L["Add Map"], type = 'header', order = 0},
    addInput = {
        name = L["Map Item"],
        desc = L["Add one item to the mappings. See usage for format."],
        type = 'input',
        order = 10,
        set = function(info, val) core.t1 = val end,
        get = function(info) return core.t1 end
    },
    tabSelect = {
        name = L["Select Tab"],
        type = 'select',
        width = 0.8,
        order = 20,
        values = GetTabs,
        set = function(info, val) core.t2 = val end,
        get = function(info) return core.t2 end
    },
    addButton = {
        name = L["Add"],
        type = 'execute',
        order = 30,
        width = 0.5,
        func = AddMap
    },
    mapSection = {name = L["Map"], type = 'header', order = 40},
    mapInput = {
        name = L["Map"],
        desc = L["Full representation of the saved map. See usage for possible modifications."],
        type = 'input',
        order = 50,
        multiline = 10,
        width = 'full',
        -- get map as string
        get = GetMapString,
        -- parse input string to map
        set = ParseMapString
    }
}

local usageOptions = {
    addTitle = {
        name = L["Add Map"],
        type = 'header',
        order = 10
    },
    addDesc = {
        name = L["Item name: item name (must be in bag) | item link | item id"],
        type = 'description',
        order = 20
    },
    mapAddDesc = {
        name = L["Add mapping format: <item>-<tab>. <item>: item name (must be in bags) | item link | item id. <tab>: tab number between 1 and 6 (tab must be owned)."],
        type  = 'description',
        order = 30
    },
    mapDeleteDesc = {
        name = L["Just delete the desired row and accept."],
        type = 'description',
        order = 40
    },
    slashTitle = {name = L["Slash commands"], type = 'header', order = 50},
    gdesc = {
        name = L["/gd | /guilddeposit: open GuildDeposit configuration."],
        type = 'description',
        order = 60
    },
    depdesc = {
        name = L["/gdeposit | /gdep: deposit items."],
        type = 'description',
        order = 70
    },
    withdesc = {
        name = L["/gdwithdraw <tab_number>: withdraw all the items from tab <tab_number>. If no number is specified, the current tab will be used."],
        type = 'description',
        order = 80
    },
    mapbagdesc = {
        name = L["/gdbag <bag_nubmer> <tab_number>: add all the items contained in bag <bag_number> to the map for tab <tab_number>."],
        type = 'description',
        order = 90
    },
    maptabdesc = {
        name = L["/gdtab <tab_number>: add all the items in tab <tab_number>. If no tab is provided, the current tab is used."],
        type = 'description',
        order = 100
    },
    printmapdesc = {
        name = L["/gdprint: prints the mappings in chat"],
        type = 'description',
        order = 110
    },
    clearmapdesc = {
        name = L["/gdclear: clears all mappings"],
        type = 'description',
        order = 120
    }
}

core.options = {
    type = "group",
    args = {
        generalOpt = {
            name = L["General"],
            type = 'group',
            order = 10,
            args = generalOptions
        },
        mapOpt = {
            name = L["Mappings"],
            type = 'group',
            order = 20,
            args = mapOptions
        },
        usageOpt = {
            name = L["Usage"],
            type = 'group',
            order = 30,
            args = usageOptions
        }
    }
}

core.defaults = {
    profile = {
        showStatus = true,
        autoDeposit = false,
        depositInterval = 0.5,
        withdrawInterval = 0.5,
        map = {},
        itemInfo = {}
    }
}

function core:SetupConfig()
    local acreg = LibStub("AceConfig-3.0")
    acreg:RegisterOptionsTable("GuildDeposit", core.options)
    -- acreg:RegisterOptionsTable("GuildDeposit Profiles", LibStub(
    --                               "AceDBOptions-3.0"):GetOptionsTable(core.db))

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
