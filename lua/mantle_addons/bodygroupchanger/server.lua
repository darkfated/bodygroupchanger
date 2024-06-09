util.AddNetworkString('BodygroupChanger-Update')
util.AddNetworkString('BodygroupChanger-UpdateSkin')

net.Receive('BodygroupChanger-Update', function(_, pl)
    local bodygroupID = net.ReadInt(8)
    local bodygroupValue = net.ReadInt(8)

    pl:SetBodygroup(bodygroupID, bodygroupValue)
end)

net.Receive('BodygroupChanger-UpdateSkin', function(_, pl)
    local skinID = net.ReadInt(8)
    pl:SetSkin(skinID)
end)
