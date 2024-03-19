--Now with SPJ
JHUD = {
  Data = {
    Gains = {},
    Gain = 0,
    Sync = 0,
    Strafes = 0,
    JSS = 0,
    LastTickVel = 0,
    AngleFraction = 1,
    LastUpdate = 0,
    Jumps = {},
    HoldingSpace = false,
  },
  Trainer = {
   Enabled = true,
    Width = ScrW()/6,
    RefreshRate = 10,
    HeightOffset = ScrH()/1.8,
    CornerSize = 5,
    DynamicBarWidth = ScrW()/860,
    StaticBarWidth = ScrW()/860,
    DynamicBarColor = Color(220, 0, 0, 220),
    StaticBarColor = Color(220, 220, 220, 220),
    RectangleColor = Color(220, 220, 220, 126),
    DynamicRectangleColor = false,
    Kcwidth = 0,
    Kcheight = 0,
    Kchorizontal = 0,
    Kcvertical = 0,
    TextColor = color_white,
  },
  HUD = {
        Enabled = false,
        Sync = false,
        Gain = true,
        Strafes = false,
    Gains50 = Color(255, 46, 46, 255),
    Gains60 = Color(255, 175, 28, 255),
    Gains70 = Color(204, 252, 13, 255),
    Gains74 = Color(0, 255, 0, 255),
    Gains77 = Color(6, 210, 0, 255),
    Gains80 = Color(0, 255, 255, 255),
    Gains90 = Color(243, 68, 252, 255),
    },
  DisplayData = table.Copy(Data),
}
  local wide, tall = ScrW(), ScrH()
local counter = 0
local lastPercentage = 0
local lastPercentageUpdate = 0
local lastCounterVal = "0"
local fading = 255

local sMessage, sAverage, color, lastUpdate = "", 0, Color(0,0,0,0), 0

surface.CreateFont( "JHUDMain", { size = 30, weight = 4000, font = "Roboto" } )
surface.CreateFont( "JHUDTrainer", { size = 30, weight = 800, font = "DermaDefaultBold" } )
  local font = "JHUDMain"
  local fontHeight = draw.GetFontHeight(font)

local function GetGainColor(gain)
  local color = Color(255, 0, 0, 255)

         if gain  >= 45 and gain < 60 then
            color = JHUD.HUD.Gains50

           elseif gain >= 60 and gain < 70 then
            color =  JHUD.HUD.Gains60
          elseif(gain >= 70 and gain < 74) then
            color = JHUD.HUD.Gains70
        elseif(gain >= 74 and gain < 77) then
            color = JHUD.HUD.Gains74
        elseif(gain >= 77 and gain < 80) then
            color = JHUD.HUD.Gains77
          elseif(gain >= 80 and gain < 90) then
            color = JHUD.HUD.Gains80
        elseif(gain >= 90) then
            color = JHUD.HUD.Gains90
          end
          return color
end


-- Basically only changed how it draws since it took so much more space then needed, wanted to do more but i cba.


local function DrawJHUD(jump, vel, sync, gain, strafes)
if not JHUD.HUD.Enabled then return end
  if !lastUpdate then return end


  -- remove the color after 2 seconds
  if CurTime() > (lastUpdate +2) then
    fiou = ColorAlpha(fiou, fiou.a - 0.1)

end
if JHUD.HUD.Sync then
    syncs = sync
else
    syncs = ""
end
if JHUD.HUD.Gain then
    gains = gain
else
    gains = ""
end
if JHUD.HUD.Strafes then
    strafe = strafes
else
    strafe = ""
end
color = Color(250, 250, 250, 250)
    if jump and not vel then
        draw.SimpleText(jump, font, ScrW() / 2, (ScrH() / 2) - 40, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else 
    --SPJ Debug print(tostring(JHUD.HUD.Strafes))
    draw.DrawText(jump..vel..gains.."\n"..syncs..strafe, font, ScrW() / 2, (ScrH() / 2) - 40, fiou, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
end

local function JHUD_UpdateSettings()
    net.Start("JHUD_UpdateSettings")
        net.WriteBool(JHUD.HUD.Enabled)
        net.WriteBool(JHUD.HUD.Gain)
        net.WriteBool(JHUD.HUD.Sync)
        net.WriteBool(JHUD.HUD.Strafes)
        net.WriteUInt(JHUD.Trainer.Width, 1)
        net.WriteInt(JHUD.Trainer.HeightOffset, 1)
        net.WriteInt(JHUD.Trainer.Kcwidth, 10)
        net.WriteInt(JHUD.Trainer.Kcheight, 10)
        net.WriteInt(JHUD.Trainer.Kchorizontal, 1)
        net.WriteInt(JHUD.Trainer.Kcvertical, 1)
        net.WriteString( string.FromColor( JHUD.HUD.Gains50 ) )
         net.WriteString( string.FromColor( JHUD.HUD.Gains60 ) )
          net.WriteString( string.FromColor( JHUD.HUD.Gains70 ) )
          net.WriteString( string.FromColor( JHUD.HUD.Gains74 ) )
          net.WriteString( string.FromColor( JHUD.HUD.Gains77 ) )
          net.WriteString( string.FromColor( JHUD.HUD.Gains80 ) )
          net.WriteString( string.FromColor( JHUD.HUD.Gains90 ) )
    net.SendToServer()
end




local function TrainerOptions()
    local wide, tall, animTime, animDelay, animEase = ScrW() * .5, ScrH() * 0.393, 1.0, 0, .1

    local framecolor = Color(32, 46, 61, 255)


    local frame = vgui.Create("DFrame")
    frame:SetSize(0,0)
    frame:Center()
    frame:SetTitle("Strafetrainer Options")
     frame:SetDraggable(true)
    frame:SetSizable(true)
    local animating = true
    frame:SizeTo(wide, tall, animTime, animDelay, animEase, function()
        animating = false
        end)
    frame.Think = function(frame)
    if animating then
        frame:Center()
    end
end

    frame:SetDeleteOnClose(true)
    frame.OnClose = function() JHUD_UpdateSettings() end
    frame.Paint = function(wide,tall)

    local wide, tall = ScrW() * .5, ScrH()
    surface.SetDrawColor(framecolor)
    surface.DrawRect(0,0,wide,tall)
end


     local trainerEnabled = frame:Add("DCheckBoxLabel")
    trainerEnabled:SetText("Enable Strafe Trainer")
    trainerEnabled:SizeToContents()
    trainerEnabled:DockMargin(0, 0, 0, 4)
    trainerEnabled:Dock(TOP)
    trainerEnabled:SetConVar("sm_strafetrainer")

   local kctrainer = frame:Add("DCheckBoxLabel")
    kctrainer:SetText("Enable Kawaii Clan Trainer")
    kctrainer:SizeToContents()
    kctrainer:DockMargin(0, 0, 0, 4)
    kctrainer:Dock(TOP)
    kctrainer:SetConVar("kawaii_trainer")

 local wslider = frame:Add("DNumSlider")
    wslider:SetSize(0, 20)
    wslider:SetMin( 200 )
    wslider:SetMax( 1000 )
    wslider:SetDecimals( 0 )
    wslider:SetText("Trainer Horizontal Position")
    wslider:Dock(TOP)
    wslider:SetValue(JHUD.Trainer.Width)
    wslider.OnValueChanged = function(_, v) JHUD.Trainer.Width = v end



    local hoffset = frame:Add("DNumSlider")
    hoffset:SetSize(0, 20)
    hoffset:SetMin( -100 )
    hoffset:SetMax( 500 )
    hoffset:SetDecimals( 0 )
    hoffset:SetText("Trainer Vertical Position")
    hoffset:DockMargin(0, 0, 0, 4)
    hoffset:Dock(TOP)
    hoffset:SetValue(JHUD.Trainer.HeightOffset)
    hoffset.OnValueChanged = function(_, v)     Offset = v end


     local kcwidth = frame:Add("DNumSlider")
    kcwidth:SetSize(0, 20)
    kcwidth:SetMin( -100 )
    kcwidth:SetMax( 500 )
    kcwidth:SetDecimals( 0 )
    kcwidth:SetText("Kawaii Trainer Width")
    kcwidth:DockMargin(0, 0, 0, 4)
    kcwidth:Dock(TOP)
    kcwidth:SetValue(JHUD.Trainer.Kcwidth)
    kcwidth.OnValueChanged = function(_, v) JHUD.Trainer.Kcwidth = v end

     local kcheight = frame:Add("DNumSlider")
    kcheight:SetSize(0, 20)
    kcheight:SetMin( -100 )
    kcheight:SetMax( 500 )
    kcheight:SetDecimals( 0 )
    kcheight:SetText("Kawaii Trainer Height")
    kcheight:DockMargin(0, 0, 0, 4)
    kcheight:Dock(TOP)
    kcheight:SetValue(JHUD.Trainer.Kcheight)
    kcheight.OnValueChanged = function(_, v) JHUD.Trainer.Kcheight = v end

     local kchorizontal = frame:Add("DNumSlider")
    kchorizontal:SetSize(0, 20)
    kchorizontal:SetMin( -500 )
    kchorizontal:SetMax( 500 )
    kchorizontal:SetDecimals( 0 )
    kchorizontal:SetText("Kawaii Trainer Horizontal Position")
    kchorizontal:DockMargin(0, 0, 0, 4)
    kchorizontal:Dock(TOP)
    kchorizontal:SetValue(JHUD.Trainer.Kchorizontal)
    kchorizontal.OnValueChanged = function(_, v) JHUD.Trainer.Kchorizontal = v end

     local kcvertical = frame:Add("DNumSlider")
    kcvertical:SetSize(0, 20)
    kcvertical:SetMin( -300 )
    kcvertical:SetMax( 250 )
    kcvertical:SetDecimals( 0 )
    kcvertical:SetText("Kawaii Trainer Vertical Position")
    kcvertical:DockMargin(0, 0, 0, 4)
    kcvertical:Dock(TOP)
    kcvertical:SetValue(JHUD.Trainer.Kcvertical)
    kcvertical.OnValueChanged = function(_, v) JHUD.Trainer.Kcvertical = v end

          local TrainerPosReset = frame:Add("DButton")
    TrainerPosReset:SetText("Reset Trainer Position")
    TrainerPosReset:Dock(TOP)
    TrainerPosReset.DoClick = function()
    JHUD.Trainer.Width = 0
    JHUD.Trainer.HeightOffset = 0
end

              local KawaiiPosReset = frame:Add("DButton")
    KawaiiPosReset:SetText("Reset Kawaii Trainer Position")
    KawaiiPosReset:Dock(TOP)
    KawaiiPosReset.DoClick = function()
    JHUD.Trainer.Kchorizontal = 0
    JHUD.Trainer.Kcvertical = 0
end


              local KawaiiDimensionsReset = frame:Add("DButton")
    KawaiiDimensionsReset:SetText("Reset Kawaii Trainer Dimensions")
    KawaiiDimensionsReset:Dock(TOP)
    KawaiiDimensionsReset.DoClick = function()
    JHUD.Trainer.Kcwidth = 0
    JHUD.Trainer.Kcheight = 0
end

local close = frame:Add("DButton")
    close:SetText("Close")
    close:Dock(BOTTOM)
    close.DoClick = function() frame:Close() end

    frame:Center()
    local x, y = frame:GetPos()
    frame:SetPos(4, y)
    frame:MakePopup()
    return frame
end




local function GainSelector()
    local wide, tall, animTime, animDelay, animEase = ScrW() * .5, ScrH() * 0.896, 1.0, 0, .1

    local framecolor = Color(32, 46, 61, 255)


    local frame = vgui.Create("DFrame")
    frame:SetSize(0,0)
    frame:Center()
    frame:SetTitle("JHUD Gain Color Selector")
     frame:SetDraggable(true)
    frame:SetSizable(true)
    local animating = true
    frame:SizeTo(wide, tall, animTime, animDelay, animEase, function()
        animating = false
        end)
    frame.Think = function(frame)
    if animating then
        frame:Center()
    end
end

    frame:SetDeleteOnClose(true)
    frame.OnClose = function() JHUD_UpdateSettings() end
    frame.Paint = function(wide,tall)

    local wide, tall = ScrW() * .5, ScrH()
    surface.SetDrawColor(framecolor)
    surface.DrawRect(0,0,wide,tall)
end



     local gains = frame:Add("DButton")
    gains:SetText("Reset Gains 45-59 color")
    gains:Dock(TOP)
    gains.DoClick = function()
    JHUD.HUD.Gains50 = Color(255, 46, 46, 255)
end

    local gain50 = frame:Add("DColorMixer")
    gain50:SetSize(0, 65)
    gain50:SetPalette(false)
    gain50:SetAlphaBar(true)
    gain50:DockMargin(0, 0, 0, 4)
    gain50:Dock(TOP)
    gain50:SetColor(JHUD.HUD.Gains50)
    gain50.ValueChanged = function(_, v) JHUD.HUD.Gains50 = v end

     local gains2 = frame:Add("DButton")
    gains2:SetText("Reset Gains 60-69 color")
    gains2:Dock(TOP)
    gains2.DoClick = function()
    JHUD.HUD.Gains60 = Color(255, 175, 28, 255)
end

    local gain60 = frame:Add("DColorMixer")
    gain60:SetSize(0, 65)
    gain60:SetPalette(false)
    gain60:SetAlphaBar(true)
    gain60:DockMargin(0, 0, 0, 4)
    gain60:Dock(TOP)
    gain60:SetColor(JHUD.HUD.Gains60)
    gain60.ValueChanged = function(_, v) JHUD.HUD.Gains60 = v end


    local gains3 = frame:Add("DButton")
    gains3:SetText("Reset Gains 70-73 color")
    gains3:Dock(TOP)
    gains3.DoClick = function()

    JHUD.HUD.Gains70 = Color(204, 252, 13, 255)

end



    local gain70 = frame:Add("DColorMixer")
    gain70:SetSize(0, 65)
    gain70:SetPalette(false)
    gain70:SetAlphaBar(true)
    gain70:DockMargin(0, 0, 0, 4)
    gain70:Dock(TOP)
    gain70:SetColor(JHUD.HUD.Gains70)
    gain70.ValueChanged = function(_, v) JHUD.HUD.Gains70 = v end

    local gains4 = frame:Add("DButton")
    gains4:SetText("Reset Gains 74-76 color")
    gains4:Dock(TOP)
    gains4.DoClick = function()

    JHUD.HUD.Gains74 = Color(0, 255, 0, 255)

end

    local gain74 = frame:Add("DColorMixer")
    gain74:SetSize(0, 65)
    gain74:SetPalette(false)
    gain74:SetAlphaBar(true)
    gain74:DockMargin(0, 0, 0, 4)
    gain74:Dock(TOP)
    gain74:SetColor(JHUD.HUD.Gains74)
    gain74.ValueChanged = function(_, v) JHUD.HUD.Gains74 = v end

    local gains5 = frame:Add("DButton")
    gains5:SetText("Reset Gains 77-79 color")
    gains5:Dock(TOP)
    gains5.DoClick = function()

    JHUD.HUD.Gains77 = Color(6, 210, 0, 255)
end

    local gain77 = frame:Add("DColorMixer")
    gain77:SetSize(0, 65)
    gain77:SetPalette(false)
    gain77:SetAlphaBar(true)
    gain77:DockMargin(0, 0, 0, 4)
    gain77:Dock(TOP)
    gain77:SetColor(JHUD.HUD.Gains77)
    gain77.ValueChanged = function(_, v) JHUD.HUD.Gains77 = v end

     local gains6 = frame:Add("DButton")
    gains6:SetText("Reset Gains 80-89 color")
    gains6:Dock(TOP)
    gains6.DoClick = function()

    JHUD.HUD.Gains80 = Color(0, 255, 255, 255)
end

    local gain80 = frame:Add("DColorMixer")
    gain80:SetSize(0, 65)
    gain80:SetPalette(false)
    gain80:SetAlphaBar(true)
    gain80:DockMargin(0, 0, 0, 4)
    gain80:Dock(TOP)
    gain80:SetColor(JHUD.HUD.Gains80)
    gain80.ValueChanged = function(_, v) JHUD.HUD.Gains80 = v end

     local gains7 = frame:Add("DButton")
    gains7:SetText("Reset Gains 90+ color")
    gains7:Dock(TOP)
    gains7.DoClick = function()

     JHUD.HUD.Gains90 = Color(243, 68, 252, 255)
end

    local gain90 = frame:Add("DColorMixer")
    gain90:SetSize(0, 65)
    gain90:SetPalette(false)
    gain90:SetAlphaBar(true)
    gain90:DockMargin(0, 0, 0, 4)
    gain90:Dock(TOP)
    gain90:SetColor(JHUD.HUD.Gains90)
    gain90.ValueChanged = function(_, v) JHUD.HUD.Gains90 = v end


        local close = frame:Add("DButton")
    close:SetText("#close")
    close:Dock(BOTTOM)
    close.DoClick = function() frame:Close() end

    frame:Center()
    local x, y = frame:GetPos()
    frame:SetPos(4, y)
    frame:MakePopup()
    return frame
end



local function OpenMenu()
    local wide, tall, animTime, animDelay, animEase = ScrW() * .5, ScrH() * 0.336, 1.3, 0, .1

    local framecolor = Color(32, 46, 61, 255)


    local frame = vgui.Create("DFrame")
    frame:SetSize(0,0)
    frame:Center()
    frame:SetTitle("JHUD Menu")
     frame:SetDraggable(true)
    frame:SetSizable(true)
    local animating = true
    frame:SizeTo(wide, tall, animTime, animDelay, animEase, function()
        animating = false
        end)
    frame.Think = function(frame)
    if animating then
        frame:Center()
    end
end

    frame:SetDeleteOnClose(true)
    frame.OnClose = function() JHUD_UpdateSettings() end
    frame.Paint = function(wide,tall)

    local wide, tall = ScrW() * .5, ScrH()
    surface.SetDrawColor(framecolor)
    surface.DrawRect(0,0,wide,tall)
end


   local jhudEnabled = frame:Add("DCheckBoxLabel")
    jhudEnabled:SetText("Enable JHUD")
    jhudEnabled:SizeToContents()
    jhudEnabled:DockMargin(0, 0, 0, 4)
    jhudEnabled:Dock(TOP)
    jhudEnabled:SetChecked(JHUD.HUD.Enabled)
    jhudEnabled.OnChange = function(enabled) JHUD.HUD.Enabled = enabled:GetChecked() end


    local jhudGain = frame:Add("DCheckBoxLabel")
    jhudGain:SetText("Enable Gain On JHUD")
    jhudGain:SizeToContents()
    jhudGain:DockMargin(0, 0, 0, 4)
    jhudGain:Dock(TOP)
    jhudGain:SetChecked(JHUD.HUD.Gain)
    jhudGain.OnChange = function(enabled) JHUD.HUD.Gain = enabled:GetChecked() end

      local jhudsync = frame:Add("DCheckBoxLabel")
    jhudsync:SetText("Enable Sync On JHUD")
    jhudsync:SizeToContents()
    jhudsync:DockMargin(0, 0, 0, 4)
    jhudsync:Dock(TOP)
    jhudsync:SetChecked(JHUD.HUD.Sync)
    jhudsync.OnChange = function(enabled) JHUD.HUD.Sync = enabled:GetChecked() end

        local jhudstrafes = frame:Add("DCheckBoxLabel")
    jhudstrafes:SetText("Enable Strafes On JHUD")
    jhudstrafes:SizeToContents()
    jhudstrafes:DockMargin(0, 0, 0, 4)
    jhudstrafes:Dock(TOP)
    jhudstrafes:SetChecked(JHUD.HUD.Strafes)
    jhudstrafes.OnChange = function(enabled) JHUD.HUD.Strafes = enabled:GetChecked() end


     local gains = frame:Add("DButton")
    gains:SetText("Open Gain Color Selector")
    gains:Dock(TOP)
    gains:DockMargin(0, 3, 0, 4)
    gains.DoClick = function()
GainSelector()
frame:SetVisible( false )
end

local gains = frame:Add("DButton")
    gains:SetText("Open Strafe Trainer Options")
    gains:Dock(TOP)
    gains:DockMargin(0, 3, 0, 4)
    gains.DoClick = function()
TrainerOptions()
frame:SetVisible( false )
end



        local close = frame:Add("DButton")
    close:SetText("Close")
    close:Dock(BOTTOM)
    close.DoClick = function() frame:Close() end

    frame:Center()
    local x, y = frame:GetPos()
    frame:SetPos(4, y)
    frame:MakePopup()
    return frame
end

local function JHUD_RetrieveSettings()
    local openMenu = net.ReadBool()
    JHUD.HUD.Enabled = net.ReadBool()
    JHUD.HUD.Gain = net.ReadBool()
    JHUD.HUD.Sync = net.ReadBool()
    JHUD.HUD.Strafes = net.ReadBool()
    JHUD.Trainer.Width = net.ReadUInt(1)
    JHUD.Trainer.HeightOffset = net.ReadInt(1)
    JHUD.Trainer.Kcwidth = net.ReadInt(10)
    JHUD.Trainer.Kcheight = net.ReadInt(10)
    JHUD.Trainer.Kchorizontal = net.ReadInt(1)
    JHUD.Trainer.Kcvertical = net.ReadInt(1)
    JHUD.HUD.Gains50 = net.ReadColor()
    JHUD.HUD.Gains60 = net.ReadColor()
    JHUD.HUD.Gains70 = net.ReadColor()
    JHUD.HUD.Gains74 = net.ReadColor()
    JHUD.HUD.Gains77 = net.ReadColor()
    JHUD.HUD.Gains80 = net.ReadColor()
    JHUD.HUD.Gains90 = net.ReadColor()

    if openMenu then
        OpenMenu()
    end
end
net.Receive( "JHUD_RetrieveSettings", JHUD_RetrieveSettings )







net.Receive("JHUD_Notify", function()
  local table = net.ReadTable()
  local gain = net.ReadFloat()
  local prestrafe = net.ReadBool()
  fiou = GetGainColor(gain)
  -- hook.Add("HUDPaint", "JHUD_Notify", function()
    -- DrawJHUD(table)
  -- end)
  local str = ""
  for k,v in pairs(table) do
    str = str..v
  end
  if prestrafe then
    str = str
    hook.Add("HUDPaint", "JHUD_Notify", function()
      DrawJHUD(str)
    end)
    return
  end
  -- separate each category with |`
  local str = string.Explode("|", str)
  local jump = str[1]
  -- LocalPlayer():ChatPrint(jump)
  local vel = "| "..str[2]
  if #str > 2 then
    local sync = "  "..str[3]
    local gain = str[4]
    local strafes = "#"..str[5]

    -- LocalPlayer():ChatPrint((sync or " xd  "))
    hook.Add("HUDPaint", "JHUD_Notify", function()
      DrawJHUD(jump, vel, sync, gain, strafes)
    end)
    -- DrawJHUD(jump, vel, sync, gain)
    return
  end
  hook.Add("HUDPaint", "JHUD_Notify", function()
    DrawJHUD(jump, vel)
  end)
end)

-- net.Receive("JHUD_Toggle", function()
--   jhud_data = net.ReadTable()
--   jhud_update = net.ReadBool()
--   PrintTable(jhud_data)
-- end)

hook.Add("Think", "JHUD_Notify", function()
  if CurTime() > (lastUpdate + 1.5) then
    -- hook.Remove("HUDPaint", "JHUD_Notify")
  end
end)


surface.CreateFont( "m_hMediumBigFont", { size = 28, weight = 800, font = "Arial" } )

surface.CreateFont( "m_hLargeBigFont", { size = 33, weight = 800, font = "Arial" } )



local old_Interface = {}

old_Interface.Started = false

old_Interface.Scale = 0

old_Interface.BigFont = { [0] = "m_hMediumBigFont", [1] = "m_hLargeBigFont" }






old_Interface.Wide = 0




function old_Interface:GetBigFont()

    return old_Interface.BigFont[ old_Interface.Scale ]

end




local ow

local function CheckResolution()

    local nw = ScrW()

    if ow and nw == ow then return end

    ow = nw



    old_Interface.Scale = ( nw < 1920 and 0 ) or 1

    old_Interface.Started = true




    local centerUltrawide = UltrawideCenter:GetBool()

    if centerUltrawide then

        local ratio = (1920 / 1080) -- Gets 16:9 ratio precision

        local currentHeight, currentWide = ScrH(), ScrW()

        local currentRatio = (currentWide / currentHeight)

        if (currentRatio < ratio) then return end



        -- Get the new widescreenspace from our aspect ratio --

        local newWide = (currentHeight * ratio)

        old_Interface.Wide = (currentWide - newWide) / 2

    end

end

Strafetrainer = {}

Strafetrainer.Enabled = CreateClientConVar("sm_strafetrainer", "0", true, false, "Enables the strafetrainer display")





local lastAngle, clientTickCount, clientPercentages = Angle():Zero(), 1, {}

local TRAINER_TICK_INTERVAL = 20



function Strafetrainer.Toggle()

    local current = 1 - Strafetrainer.Enabled:GetInt()
end



local function NormalizeAngle(ang)

    if (ang > 180) then

        ang = ang - 360

    elseif (ang < -180) then

        ang = ang + 360

    end



    return ang

end



local function PerfStrafeAngle(speed)

    return math.deg(math.atan(32.8 / speed))

end



local function VisualisationString(percentage)

    local str = ""



    if (0.5 <= percentage) and (percentage <= 1.5) then

        local Spaces = math.Round((percentage - 0.5) / 0.05)

        for i = 0, Spaces + 1 do

            str = str .. "  "

        end



        str = str .. "|"



        for i = 0, (21 - Spaces) do

            str = str .. "  "

        end

    else

        str = str .. (percentage < 1.0 and "|                                      " or "                                       |")

    end



    return str

end



local function GetPercentageColor(percentage)

    local offset = math.abs(1 - percentage)

    local color = Color(0, 0, 0, 0)



    if (offset < 0.05) then

        color = Color(0, 255, 0, 180)

    elseif (0.05 <= offset) and (offset < 0.1) then

        color = Color(128, 255, 0, 180)

    elseif (0.1 <= offset) and (offset < 0.25) then

        color = Color(255, 255, 0, 180)

    elseif (0.25 <= offset) and (offset < 0.5) then

        color = Color(255, 128, 0, 180)

    else

        color = Color(255, 0, 0, 180)

    end



    return color

end



local sMessage, sAverage, color, lastUpdate = "", Color(0, 0, 0, 0), nil

local function StrafeTrainer(ply, mv)

    if (LocalPlayer() != ply) or (LocalPlayer():Team() == TEAM_SPECTATOR) then return end

    if !Strafetrainer.Enabled:GetBool() then return end

    if !IsFirstTimePredicted() then return end

    if (ply:OnGround() or ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetMoveType() == MOVETYPE_LADDER) then return end



    local currentAngle = mv:GetMoveAngles().y

    local currentVelocity = mv:GetVelocity():Length2D()

    if !lastAngle then lastAngle = currentAngle end



    local AngDiff = NormalizeAngle(lastAngle - currentAngle)



    local PerfAngle = PerfStrafeAngle(currentVelocity)



    local Percentage = math.abs(AngDiff / PerfAngle) or 0



    if clientTickCount > TRAINER_TICK_INTERVAL then

        local AveragePercentage = 0.0



        for i = 1, TRAINER_TICK_INTERVAL do

            AveragePercentage = AveragePercentage + clientPercentages[i]

            clientPercentages[i] = 0.0

        end



        AveragePercentage = AveragePercentage / TRAINER_TICK_INTERVAL

        sAverage = math.Round(AveragePercentage * 100, 2)



        sMessage = VisualisationString(AveragePercentage)

        color = GetPercentageColor(AveragePercentage)

        lastUpdate = CurTime()

        clientTickCount = 1

    else

        clientPercentages[clientTickCount] = Percentage

        clientTickCount = clientTickCount + 1

    end



    lastAngle = currentAngle

end

hook.Add("FinishMove", "sm_strafetrainer", StrafeTrainer)



local function DrawStrafeTrainer()

    if !Strafetrainer.Enabled:GetBool() then return end

    if !lastUpdate then return end



    if CurTime() > (lastUpdate + 1) then

        color = ColorAlpha(color, color.a - 1)

    end



    local font = old_Interface:GetBigFont()

    local fontHeight = draw.GetFontHeight(font)



    local wide, tall = ScrW(), ScrH()

    draw.SimpleText(sAverage .. "%", font, ScrW() / 2 + JHUD.Trainer.Width, (ScrH() / 2) - 200  + JHUD.Trainer.HeightOffset  , color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.SimpleText("════════^════════", font, ScrW() / 2 + JHUD.Trainer.Width, (ScrH() / 2) - 200  + JHUD.Trainer.HeightOffset  + (fontHeight * 1), color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.SimpleText(sMessage, font, ScrW() / 2 + JHUD.Trainer.Width, (ScrH() / 2) - 200  + JHUD.Trainer.HeightOffset   + (fontHeight * 2), color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.SimpleText("════════^════════", font, ScrW() / 2 + JHUD.Trainer.Width, (ScrH() / 2) - 200  + JHUD.Trainer.HeightOffset  + (fontHeight * 3), color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

end

hook.Add("HUDPaint", "sm_drawstrafetrainer", DrawStrafeTrainer)

-- strafetrainer made by justa

Kctrainerenabled = CreateClientConVar("kawaii_trainer", "0", true, false, "Enables the strafetrainer display")

-- 30 (MV)
-- Normal Garry's mod this is 32.8
local movementSpeed = 32.8

-- Tick interval
local interval = (1 / engine.TickInterval()) / 10

-- Faster performance
local deg, atan = math.deg, math.atan

-- active
local active = {}


local function NormalizeAngle(x)
  if (x > 180) then
    x = x - 360
  elseif (x <= -180) then
    x = x + 360
  end

  return x
end

local function GetPerfectAngle(vel)
  return deg(atan(movementSpeed / vel))
end

local function NetworkList(ply)
  local watchers = {}

  for _, p in pairs(player.GetHumans()) do
    if not p.Spectating then continue end

    local ob = p:GetObserverTarget()

    if IsValid(ob) and ob == ply then
      watchers[#watchers + 1] = p
    end
  end

  watchers[#watchers + 1] = ply

  return watchers
end

local last = {}
local tick = {}
local percentages = {}
local value = {}
local function SetupMove(client, data, cmd)
  if !Kctrainerenabled:GetBool() then return end
  if not client:Alive() then return end


  if client:GetMoveType() == MOVETYPE_NOCLIP then return end

  if not percentages[client] then
    percentages[client] = {}
    last[client] = 0
    tick[client] = 0
    value[client] = 0
  end

  local diff = NormalizeAngle(last[client] - data:GetAngles().y)
  local perfect = GetPerfectAngle(client:GetVelocity():Length2D())
  local perc = math.abs(diff) / perfect
  local t = tick[client]

  if (t > interval) then
    local avg = 0

    for x = 0, interval do
      avg = avg + percentages[client][x]
      percentages[client][x] = 0
    end

    avg = avg / interval
    value[client] = avg
    tick[client] = 0

    percentages[client][t] = perc
    tick[client] = t + 1
  end

  last[client] = data:GetAngles().y
end


hook.Add("SetupMove", "kc_strafetrainer", SetupMove)


surface.CreateFont( "HUDcsstop", { size = 32, weight = 800, antialias = true, bold = true, font = "DermaDefaultBold" } )
surface.CreateFont( "HUDcss", { size = 21, weight = 800, bold = false, font = "DermaDefaultBold" } )

local function GetColour(percent)
    local offset = math.abs(1 - percent)

    if offset < 0.05 then
        return Color(0, 255, 0, 130)
    elseif (0.05 <= offset) and (offset < 0.1) then
        return Color(128, 255, 0, 130)
    elseif (0.1 <= offset) and (offset < 0.25) then
        return Color(255, 255, 0, 130)
    elseif (0.25 <= offset) and (offset < 0.5) then
        return Color(255, 128, 0, 130)
    else
        return Color(255, 0, 0, 130)
    end
end


local value = 0
net.Receive("train_update", function(_, _)
    value = net.ReadFloat()
end)

local lp = LocalPlayer
local function Display()
    if !Kctrainerenabled:GetBool() then return end
    if IsValid(lp():GetObserverTarget()) and lp():GetObserverTarget():IsBot() then return end

    local c = GetColour(value)
    local x = ScrW() / 2 + JHUD.Trainer.Kchorizontal
    local y = (ScrH() / 2) + 20 + JHUD.Trainer.Kcvertical
    local w = 240 + JHUD.Trainer.Kcwidth
    local size = 4
    local msize = size / 2
    local h = 14 + JHUD.Trainer.Kcheight
    local movething = 22
    local spacing = 6
    local endingval = math.floor(value * 100)

    surface.SetDrawColor(c)

    if endingval >= 0 and endingval <= 200 then
        local move = w * (value/2)
        surface.DrawRect(x - (w / 2) + move, y - (movething/2) + (size / 2), size, movething)
    else
        draw.SimpleText("Invalid", "HUDcsstop", x, y + (size / 2), c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    y = y + 32
    surface.DrawRect(x - (w / 2) + (size / 2), y, w - size, size)
    surface.DrawRect(x - (w / 2), y - h, size, h + size)
    surface.DrawRect(x + (w / 2) - size, y - h, size, h + size)
    surface.DrawRect(x - (msize / 2), y + size, msize, h)
    draw.SimpleText("100", "HUDcss", x, y + size + spacing + h, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

    y = y - (32 * 2)
    surface.DrawRect(x - (w / 2) + (size / 2), y, w - size, size)
    surface.DrawRect(x - (w / 2), y, size, h + size)
    surface.DrawRect(x + (w / 2) - size, y, size, h + size)
    surface.DrawRect(x - (msize / 2), y - h, msize, h)


    draw.SimpleText(endingval, "HUDcss", x, y - h - spacing, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end
hook.Add("HUDPaint", "StrafeTrainer", Display)--]]
