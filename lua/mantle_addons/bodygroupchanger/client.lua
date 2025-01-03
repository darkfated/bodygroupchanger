local function CreateModelMenu()
    local frame = vgui.Create('MantleFrame')
    frame:SetSize(600, 400)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle('')
    frame:SetCenterTitle('Кастомизация модели')
    frame:SetAlphaBackground(true)

    local lp = LocalPlayer()

    local modelPanel = vgui.Create('DModelPanel', frame)
    modelPanel:Dock(FILL)
    modelPanel:SetModel(lp:GetModel())

    local function UpdateModel()
        modelPanel:SetModel(lp:GetModel())

        local ent = modelPanel.Entity

        for _, v in pairs(lp:GetBodyGroups()) do
            ent:SetBodygroup(v.id, lp:GetBodygroup(v.id))
        end

        ent:SetSkin(lp:GetSkin())
    end

    local settingsPanel = vgui.Create('DPanel', frame)
    settingsPanel:Dock(RIGHT)
    settingsPanel:SetWide(200)
    settingsPanel.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Mantle.color.panel_alpha[1])
    end

    local bodys = lp:GetBodyGroups()
    local isFirst = true

    if #bodys > 0 then
        for _, v in pairs(bodys) do
            if v.num > 1 then
                local comboBox = vgui.Create('DComboBox', settingsPanel)
                comboBox:Dock(TOP)
                comboBox:DockMargin(8, isFirst and 8 or 0, 8, 8)
                comboBox:SetValue(v.name)
                comboBox:SetFont('Fated.16')

                for i = 0, v.num - 1 do
                    comboBox:AddChoice(v.name .. ' ' .. i, i)
                end

                comboBox.OnSelect = function(_, _, _, data)
                    net.Start('BodygroupChanger-Update')
                        net.WriteInt(v.id, 8)
                        net.WriteInt(data, 8)
                    net.SendToServer()

                    timer.Simple(0.1, function() UpdateModel() end)
                end

                isFirst = false
            end
        end
    end

    local skinCount = modelPanel.Entity:SkinCount()

    if skinCount > 1 then
        local skinComboBox = vgui.Create('DComboBox', settingsPanel)
        skinComboBox:Dock(TOP)
        skinComboBox:DockMargin(8, isFirst and 8 or 0, 8, 8)
        skinComboBox:SetValue('Скин')
        skinComboBox:SetFont('Fated.16')

        for i = 0, skinCount - 1 do
            skinComboBox:AddChoice('Скин ' .. i, i)
        end

        skinComboBox.OnSelect = function(_, _, _, data)
            net.Start('BodygroupChanger-UpdateSkin')
                net.WriteInt(data, 8)
            net.SendToServer()

            timer.Simple(0.1, function() UpdateModel() end)
        end
    end

    if #settingsPanel:GetChildren() == 0 then
        settingsPanel:Remove()
    end

    UpdateModel()
end

concommand.Add('bodygroupchanger_menu', CreateModelMenu)
