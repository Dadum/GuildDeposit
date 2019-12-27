local GuildDeposit = LibStub("AceAddon-3.0"):GetAddon("GuildDeposit")
local Config = LibStub("AceConfig-3.0")

optionsTable = {
    type = "group",
    args = {
      enable = {
        name = "Enable",
        desc = "Enables / disables the addon",
        type = "toggle",
        set = function(info,val) GuildDeposit.enabled = val end,
        get = function(info) return GuildDeposit.enabled end
      }
    }
  }
  
Config:RegisterOptionsTable("GuildDeposit", optionsTable, {"/testconf"})