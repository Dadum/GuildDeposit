
Test = LibStub("AceAddon-3.0"):NewAddon("Test", "AceTimer-3.0")
GBSlots = 98

function Test:ToDeposit()
    local dredged = 168649
    local slots = GetContainerNumSlots(4)
    local dep = {}
    for i=1,slots do
            local id = GetContainerItemID(4,i)
            print(id)
            if id and id == dredged then
                print("ifd")
                table.insert(dep, i)
        end
    end
    return dep
end

function Test:GBFreeSlots()
    local free = {}
    for i=1, GBSlots do 
        if not GetGuildBankItemLink(3,i) then
            table.insert(free, i)
        end
    end
    return free
end

function Test:DoMove(b, g)
    for k, item in pairs(b) do
        local head = table.remove(g)
        print(item)
        print(head)
        PickupContainerItem(4,item)
        PickupGuildBankItem(3,head)
    end
end

function Test:DoMoves()
    to_dep = Test:ToDeposit()
    b_free = Test:GBFreeSlots()
    self:ScheduleRepeatingTimer("MoveHead", 0.5)
end

function Test:MoveHead()
    local item = table.remove(to_dep, 1)
    local slot = table.remove(b_free, 1)
    if item and slot then
        PickupContainerItem(4,item)
        PickupGuildBankItem(3,slot)
    else
        self:CancelAllTimers()
    end
end


SLASH_TEST1="/test"
SlashCmdList["TEST"]=function(msg)
    Test:DoMoves()
end 
    -- for i=1, GetContainerNumSlots(4) do
    --     local id = GetContainerItemID(4,i)
    --     print(id)
    --     if id == 168649 then
    --         C_Timer.after(1,function()
    --             PickupContainerItem(4,i)
    --         end)
    --         print("pickupd")
    --         local j = 1
    --         local _, a = GetGuildBankItemInfo(3,j)
    --         while (a > 0) do
    --             j = j+1
    --             _, a = GetGuildBankItemInfo(3,j)
    --             print(a)
    --             print(j)
    --         end
    --         print("slotd")
    --         C_Timer.after(1,function()
    --             PickupGuildBankItem(3,j) 
    --         end)
    --         print("helo world, mi potent")
    --     end
    -- end
    --     end

