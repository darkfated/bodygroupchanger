local function CreateModelMenu()
    if IsValid(_mantleBodygroupMenu) then _mantleBodygroupMenu:Remove() end
    local frame = vgui.Create('MantleFrame')
    frame:SetSize(900, 650)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle('')
    frame:SetCenterTitle('Кастомизация модели')
    frame:ShowAnimation()
    _mantleBodygroupMenu = frame

    local lp = LocalPlayer()

    -- Левая часть: модель и описание
    local leftPanel = vgui.Create('DPanel', frame)
    leftPanel:Dock(FILL)
    leftPanel:DockMargin(0, 0, 0, 0)
    leftPanel.Paint = nil

    local modelPanel = vgui.Create('DModelPanel', frame)
    modelPanel:Dock(FILL)
    modelPanel:SetParent(leftPanel)
    modelPanel:SetModel(lp:GetModel())
    modelPanel:SetFOV(60)
    modelPanel:SetCamPos(Vector(60, 0, 40))
    modelPanel:SetLookAt(Vector(0, 0, 40))
    modelPanel.LayoutEntity = function(self, ent)
        if self.bDragging then
            local mx, my = gui.MousePos()
            self.Angles = self.Angles or Angle(0, 0, 0)
            self.Angles = Angle(0, self.Angles.y - (mx - self.lastX) * 0.5, 0)
            self.lastX = mx
        end
        ent:SetAngles(self.Angles or Angle(0, 0, 0))
    end
    modelPanel.OnMousePressed = function(self, code)
        if code == MOUSE_LEFT then
            self.bDragging = true
            self.lastX = gui.MousePos()
        end
    end
    modelPanel.OnMouseReleased = function(self, code)
        if code == MOUSE_LEFT then
            self.bDragging = false
        end
    end
    modelPanel.OnMouseWheeled = function(self, delta)
        local fov = self:GetFOV() - delta * 2
        self:SetFOV(math.Clamp(fov, 20, 80))
    end

    -- Описание под моделью
    local desc = vgui.Create('DLabel', leftPanel)
    desc:Dock(BOTTOM)
    desc:DockMargin(0, 4, 0, 4)
    desc:SetTall(24)
    desc:SetText('Используйте мышь для вращения и колесо для приближения модели.')
    desc:SetFont('Fated.16')
    desc:SetTextColor(Mantle.color.text)
    desc:SetContentAlignment(5)

    -- Правая панель с настройками
    local rightPanel = vgui.Create('MantleScrollPanel', frame)
    rightPanel:Dock(RIGHT)
    rightPanel:SetWide(260)

    local function UpdateModel()
        modelPanel:SetModel(lp:GetModel())
        local ent = modelPanel.Entity
        for _, v in pairs(lp:GetBodyGroups()) do
            ent:SetBodygroup(v.id, lp:GetBodygroup(v.id))
        end
        ent:SetSkin(lp:GetSkin())
    end

    local bodys = lp:GetBodyGroups()
    local isFirst = true

    if #bodys > 0 then
        for _, v in pairs(bodys) do
            if v.num > 1 then
                local comboBox = vgui.Create('MantleComboBox', rightPanel)
                comboBox:Dock(TOP)
                comboBox:DockMargin(8, isFirst and 8 or 0, 8, 8)
                comboBox:SetValue(v.name)
                for i = 0, v.num - 1 do
                    comboBox:AddChoice(v.name .. ' ' .. i, i)
                end
                comboBox.OnSelect = function(_, _, data)
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
        local skinComboBox = vgui.Create('MantleComboBox', rightPanel)
        skinComboBox:Dock(TOP)
        skinComboBox:DockMargin(8, isFirst and 8 or 0, 8, 8)
        skinComboBox:SetValue('Скин')
        for i = 0, skinCount - 1 do
            skinComboBox:AddChoice('Скин ' .. i, i)
        end
        skinComboBox.OnSelect = function(_, _, data)
            net.Start('BodygroupChanger-UpdateSkin')
                net.WriteInt(data, 8)
            net.SendToServer()
            timer.Simple(0.1, function() UpdateModel() end)
        end
    end

    UpdateModel()
end

concommand.Add('bodygroupchanger_menu', CreateModelMenu)
