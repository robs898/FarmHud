local FarmHud = {
    storedButtons = {},
    isCentered = false,
    storedZoom = nil,
    alphaSetting = 0,
    alphaResetTime = nil,
    zoneChange = false,
    mouseEnabled = true,
    minimapPosition = {}
}

local circle = CreateFrame("Frame", "CircleFrame", UIParent)
circle:SetToplevel(true)
circle:SetFrameStrata("DIALOG")
circle:SetWidth(420)
circle:SetHeight(420)
circle:SetPoint("CENTER", UIParent, "CENTER")
circle:Hide()

local texture = circle:CreateTexture(nil, "BACKGROUND")
texture:SetAllPoints(circle)
texture:SetTexture("Interface\\Addons\\FarmHud\\circle.tga")

local function SetArrow(size)
    for _, child in ipairs({Minimap:GetChildren()}) do
        if child:GetObjectType() == "Model" and child:GetModel() == "Interface\\Minimap\\MinimapArrow" then
            child:SetAlpha(1)
            child:SetScale(size)
        end
    end
end

function FarmHud:MoveMinimap()
    FarmHudFrame:RegisterEvent("MINIMAP_UPDATE_ZOOM")
    local point, relativeTo, relativePoint, xOfs, yOfs = Minimap:GetPoint()
    self.minimapPosition = {
        point = point,
        relativeTo = relativeTo,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs
    }
    Minimap:ClearAllPoints()
    MinimapBorder:Hide()
    Minimap:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    Minimap:SetScale(4)
    Minimap:EnableMouse(false)
    self:HideMinimapButtons()
    self.storedZoom = Minimap:GetZoom()
    Minimap:SetZoom(0)
    Minimap:SetAlpha(self.alphaSetting)
    circle:Show()
    SetArrow(0.3)
    self.isCentered = true
end

function FarmHud:RestoreMinimap()
    FarmHudFrame:UnregisterEvent("MINIMAP_UPDATE_ZOOM")
    Minimap:ClearAllPoints()
    MinimapBorder:Show()
    Minimap:SetPoint(self.minimapPosition.point, self.minimapPosition.relativeTo, self.minimapPosition.relativePoint, self.minimapPosition.xOfs, self.minimapPosition.yOfs)
    Minimap:SetScale(1)
    Minimap:EnableMouse(true)
    self:ShowMinimapButtons()
    Minimap:SetZoom(self.storedZoom)
    Minimap:SetAlpha(1)
    circle:Hide()
    SetArrow(1)
    self.isCentered = false
end

function FarmHud:HideMinimapButtons()
    self.storedButtons = {}
    for _, child in ipairs({Minimap:GetChildren()}) do
        if child:GetName() and child:IsVisible() and not string.find(child:GetName(), "pfMiniMapPin") then
            child:Hide()
            table.insert(self.storedButtons, child)
        end
    end
end

function FarmHud:ShowMinimapButtons()
    for _, button in ipairs(self.storedButtons) do
        if button then
            button:Show()
        end
    end
    self.storedButtons = {}
end

FarmHudFrame = CreateFrame("Frame", "FarmHudFrame")

FarmHudFrame:SetScript("OnEvent", function()
    FarmHud:RestoreMinimap()
end)

SLASH_FARMHUD1 = "/farmhud"
SlashCmdList["FARMHUD"] = function()
    if FarmHud.isCentered then
        FarmHud:RestoreMinimap()
    else
        FarmHud:MoveMinimap()
    end
end
