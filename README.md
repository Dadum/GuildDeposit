# GuildDeposit

- [GuildDeposit](#guilddeposit)
  - [Usage](#usage)
    - [Slash commands](#slash-commands)

WoW addon to automate guild deposit operations.

## Usage

### Slash commands

- `/gd`, `/guilddeposit`: open configuration.
- `/gdep`, `/gdeposit`: start depositing items.
- `/gdwithdraw <tab_number>`: withdraw the specified tab.
  - `<tan_number>`, **optional** - the number (1 through 6) of the tab to withdraw.
- `/gdbag <bag_number> <tab_number>`: map all the items contained in bag `<bag_number>` to tab `<tab_number>`.
  - `<bag_number>`, **required** - the number of the bag (0 for backpag, through 4) to map.
  - `<tab_nubmer>`, **required** - the number of the tab (1 through 6) where to map the items.
- `/gdtab <tab_number>`: map all items of tab `<tab_number>`. 
  - `<tab_number>`, **optional** - the number (1 through 6) of the tab to map. If no number is specified, the current tab will be used.
- `/gdprint`: print the mappings.
- `/gdclear`: clear the mappings.

**p.s.** pupu
