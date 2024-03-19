
local Commands = {
  ["jhud"] =
  {
    "jhud",
    "jhudmenu",
  },
}

util.AddNetworkString("JHUD_Notify")
util.AddNetworkString("JHUD_Toggle")
util.AddNetworkString("JHUD_IResponse")

local function initTables(ply)
    local jhud = JHUD or {}
    ply.JHUD = ply.JHUD or {}
    ply.JHUD.Gains = ply.JHUD.Gains or {}
    ply.JHUD.Settings = {enabled = true, sync = true, gain = true, strafes = true}
    ply.JHUD.LastTickVel = ply.JHUD.LastTickVel or 0
    ply.JHUD.LastUpdate = ply.JHUD.LastUpdate or CurTime()
    ply.JHUD.Jumps = ply.JHUD.Jumps or {}
    ply.jsync = 0
    ply.jsyncalignA = 0
    ply.JHUD.Strafes = 0
  end



 

util.AddNetworkString("JHUD_RetrieveSettings"
)local function JHUD_RetrieveSettings( ply, openMenu )
  net.Start("JHUD_RetrieveSettings")
  net.WriteBool( openMenu )
  net.WriteBool( tobool( ply:GetPData(ply.JHUD.Settings[1]) ) )
  net.Send( ply )
end
local function ResetData(ply)
  table.Empty(ply.JHUD.Gains)
  ply.JHUD.LastTickVel = 0
  ply.JHUD.LastUpdate = CurTime()
  ply.JHUD.HoldingSpace = false
  ply.JHUD.Jumps = {}
  ply.jsync = 0
  ply.jsyncalignA = 0
  ply.JHUD.Strafes = 0
end

local function ResetDataForJump(ply)
  table.Empty(ply.JHUD.Gains)
  ply.JHUD.LastTickVel = 0
  ply.JHUD.LastUpdate = CurTime()
  ply.jsync = 0
  ply.jsyncalignA = 0
  ply.JHUD.Strafes = 0
end

local function OnPlySpwn(ply)
  if ply.JHUD then
    ResetData(ply)
  end
end
hook.Add("PlayerSpawn", "JHUD:PlayerSpawn", OnPlySpwn)


local function GetJump(ply)
  local vel = ply:GetVelocity():Length2D()
  return {vel}
end

local function TableAverage(tab)
  local final = 0
  -- if table is empty return 0
  if #tab == 0 then return 0 end
  for k, v in pairs(tab) do
      final = final + v
  end
  return final / #tab
end

local function norm( i ) 
  if i > 180 then i = i - 360 
  elseif i < -180 then i = i + 360
  end 
  return i 
end
local fb = bit.band
local MonAngle = {}

local function GetStrafes(ply, key)
  if not ply:Alive() then return end
  if not ply.JHUD then return end
  --local buttons = data:GetButtons()
  if (key == IN_MOVELEFT) or (key == IN_MOVERIGHT) then
        --SPJ Debug print("KEYPRESS")
        ply.JHUD.Strafes = ply.JHUD.Strafes + 1

  end 
end

local function MonitorSync(ply, data)
  if not ply:Alive() then return end
  if not ply.JHUD then return end
  local buttons = data:GetButtons()
  local ang = data:GetAngles().y

  if not ply:IsFlagSet( FL_ONGROUND + FL_INWATER ) and ply:GetMoveType() != MOVETYPE_LADDER then
    if MonAngle[ply] == nil then return end

    local difference = norm(ang - MonAngle[ply])


    if difference > 0 then
      if ply.jsync ~= nil then
        ply.jsync = ply.jsync + 1
      end
      if (fb(buttons, IN_MOVELEFT) > 0) and not (fb(buttons, IN_MOVERIGHT) > 0) then
        ply.jsyncalignA = ply.jsyncalignA + 1
      end
    elseif difference < 0 then
      if ply.jsync ~= nil then
        ply.jsync = ply.jsync + 1
      end
      if (fb(buttons, IN_MOVERIGHT) > 0) and not (fb(buttons, IN_MOVELEFT) > 0) then
        ply.jsyncalignA = ply.jsyncalignA + 1
      end
    end
  end
  MonAngle[ply] = ang
end

-- gain data
function GetGainData(ply, data, cmd)
  if (not ply.JHUD) then return end
  -- Credits go to Claz for this
  if not ply:OnGround() and ply:WaterLevel() < 2 then    
      local mv, vel, absVel, ang = 32.8, Vector(cmd:GetForwardMove(), cmd:GetSideMove(), 0), ply:GetAbsVelocity(), cmd:GetViewAngles()
  
      local fore, side = ang:Forward(), ang:Right()
      fore.z = 0
      side.z = 0
      fore:Normalize()
      side:Normalize()
  
      local wishvel = Vector()
      wishvel.x = fore.x * vel.x + side.x * vel.y
      wishvel.y = fore.y * vel.x + side.y * vel.y
  
      local wishspeed = wishvel:Length()
      local maxSpeed = ply:GetMaxSpeed()
      wishvel:Normalize()
  
      if wishspeed > maxSpeed and maxSpeed ~= 0 then
          wishspeed = maxSpeed
      end
  
      -- if some speed is gained 
      if wishspeed ~= 0 then
          local wishspd = (wishspeed > mv) and mv or wishspeed
          local currentgain = absVel:Dot(wishvel)
          local gaincoeff = 0.0
  
          -- if speed isnt clamped
          if (current ~=0) and currentgain < mv then
              gaincoeff = (wishspd - math.abs(currentgain)) / wishspd
              ply.syncedTicks = (ply.syncedTicks or 0) + 1
          end
        table.insert(ply.JHUD.Gains, gaincoeff * 100)
      end
  end
end


local function NotifyJHUD(ply, msg, isprestrafe)
  net.Start("JHUD_Notify")
  net.WriteTable(msg)
  net.WriteFloat(math.Round(math.Clamp(TableAverage(ply.JHUD.Gains), 0, 100), 2))
  net.WriteBool(isprestrafe and isprestrafe or false)
  net.Send(ply)
end

local function DisplayJHUD(ply)
  if (not ply.JHUD) then return end
  if (not ply.JHUD.HoldingSpace) then return end
  if ply:IsBot() then return end

  -- current data
  local currentJump = ply.JHUD.Jumps[#ply.JHUD.Jumps]
  local currentGain = math.Round(math.Clamp(TableAverage(ply.JHUD.Gains), 0, 100), 2)
  local currentVel = currentJump[1]
  local strafes = ply.JHUD.Strafes
  --SPJ Debug print("Please work SPJ:")print(tostring(strafes))
  local difference

  local sync = math.Round((ply.jsyncalignA / ply.jsync) * 100, 2)
  if ply.jsync == 0 then
    sync = 0

  end
  

  
  local tStr = {tostring(#ply.JHUD.Jumps), " | ",tostring(math.Round(currentVel))}

  local str = table.Copy(tStr)
  
  if (#ply.JHUD.Jumps > 1) then
    local oldData = ply.JHUD.Jumps[#ply.JHUD.Jumps - 1]
    if (not oldData) then return end
    
    local oldVelocity = oldData[1]
    
    difference = math.Round(currentVel - oldVelocity)
  end
  -- settings

   if (not ply.JHUD.Settings["enabled"]) then return end
  
  if (#ply.JHUD.Jumps > 1) then
    table.insert(str, " (")
    if difference < 0 then
      table.insert(str, tostring(difference))
    elseif difference > 0 then
      table.insert(str, "+"..tostring(difference))
    elseif difference == 0 then
      table.insert(str, "0")
    end
    table.insert(str, ")")
  end

  -- sync
  if (#ply.JHUD.Jumps > 1) and (ply.JHUD.Settings["sync"]) then
    table.insert(str, " | ")
    table.insert(str, "")
    table.insert(str, "("..tostring(sync).."%)")
  end

  -- gain
  if (#ply.JHUD.Jumps >= 1) and (ply.JHUD.Settings["gain"]) then
    table.insert(str, " | ")
    table.insert(str, "")
    table.insert(str, tostring(currentGain).."%")
  end
    if (#ply.JHUD.Jumps > 1) then
    table.insert(str, " | ")
    table.insert(str, "")
    table.insert(str, tostring(strafes))
  end
  NotifyJHUD(ply, str)
end
local function OnPlyHitGround(ply, bWater)
  if LocalPlayer and ply != LocalPlayer() then return end
  if not ply.JHUD then initTables(ply) end
  if ply.JHUD.LastUpdate + 0.2 < CurTime() and ply.JHUD.HoldingSpace then
    table.insert(ply.JHUD.Jumps, GetJump(ply))
    DisplayJHUD(ply)
    -- net.Start("JHUD_Notify")
    -- net.WriteFloat(ply.JHUD.Gain)
    -- net.Send(ply)
    
    ResetDataForJump(ply)
  end
  if not ply.JHUD.HoldingSpace then
    DisplayJHUD(ply)
    ResetData(ply)
  end
end




local function PlayerKeyPress(ply, key)
  if ply:IsBot() or ply:GetObserverMode() > 0 then return end
  if not ply.JHUD then initTables(ply) end

  if (key == IN_JUMP and ply:Alive()) then
    -- debug for i forgot print("JUMPING")
    ply.JHUD.HoldingSpace = true


      ply.JHUD.Jumps[1] = GetJump(ply)
    if #ply.JHUD.Jumps == 1 then
      local str = {"Prestrafe: ", tostring(math.Round(ply.JHUD.Jumps[1][1]))}
      NotifyJHUD(ply, str, true)
    end



  end
end

local function KeyRelease(ply, key)
  if key == IN_JUMP then
    ply.JHUD.HoldingSpace = false
    end
  end

local function ToggleJHUD(ply, update)
  if not update then
    net.Start("JHUD_Toggle")
    net.WriteTable(ply.JHUD.Settings)
    net.Send(ply)
    return
  end

  net.Start("JHUD_Toggle")
  net.WriteTable(ply.JHUD.Settings)
  net.WriteBool(update and update or false)
  net.Send(ply)
end

local function JHUD_IResponse(len, ply)
  local k = net.ReadTable()
  PrintTable(k)
  print("JHUD_IResponse")
  -- ToggleJHUD(ply)

  -- ply.JHUD.Settings[k] = not ply.JHUD.Settings[k]
  -- ply.SetPData("JHUD_Settings", util.TableToJSON(ply.JHUD.Settings))

  -- callback
  -- ToggleJHUD(ply, true)
end
util.AddNetworkString("JHUD_UpdateSettings")
local function JHUD_UpdateSettings( len, ply )
  ply:SetPData( "jhudh_enabled", net.ReadBool() )
  ply:SetPData( "jhudh_gain", net.ReadBool() )
  ply:SetPData( "jhudh_sync", net.ReadBool() )
  ply:SetPData( "jhudh_strafes", net.ReadBool() )
  ply:SetPData( "jhudt_width", net.ReadUInt(1) )
  ply:SetPData( "jhudt_heightoffset", net.ReadInt(1) )
  ply:SetPData( "jhudt_kcwidth", net.ReadInt(10) )
  ply:SetPData( "jhudt_kcheight", net.ReadInt(10) )
  ply:SetPData( "jhudt_kchorizontal", net.ReadInt(1) )
  ply:SetPData( "jhudt_kcvertical", net.ReadInt(1) )
  ply:SetPData( "jhudh_50gain", string.ToColor( net.ReadString() ) )
  ply:SetPData( "jhudh_60gain", string.ToColor( net.ReadString() ) )
  ply:SetPData( "jhudh_70gain", string.ToColor( net.ReadString() ) )
  ply:SetPData( "jhudh_74gain", string.ToColor( net.ReadString() ) )
  ply:SetPData( "jhudh_77gain", string.ToColor( net.ReadString() ) )
  ply:SetPData( "jhudh_80gain", string.ToColor( net.ReadString() ) )
  ply:SetPData( "jhudh_90gain", string.ToColor( net.ReadString() ) )
end
net.Receive("JHUD_UpdateSettings", JHUD_UpdateSettings)

util.AddNetworkString("JHUD_RetrieveSettings")
local function JHUD_RetrieveSettings( ply, openMenu )
  net.Start("JHUD_RetrieveSettings")
  net.WriteBool( openMenu )
  net.WriteBool( tobool( ply:GetPData( "jhudh_enabled" ) ) )
  net.WriteBool( tobool( ply:GetPData( "jhudh_gain" ) ) )
  net.WriteBool( tobool( ply:GetPData( "jhudh_sync" ) ) )
  net.WriteBool( tobool( ply:GetPData( "jhudh_strafes" ) ) )
  net.WriteUInt( ply:GetPData( "jhudt_width" ) or 600, 1 ) -- Or = default values
  net.WriteInt( ply:GetPData( "jhudt_heightoffset" ) or 150, 1 )
  net.WriteInt( ply:GetPData( "jhudt_kcwidth" ) or 150, 10 )
  net.WriteInt( ply:GetPData( "jhudt_kcheight" ) or 150, 10 )
  net.WriteInt( ply:GetPData( "jhudt_kchorizontal" ) or 150, 1 )
  net.WriteInt( ply:GetPData( "jhudt_kcvertical" ) or 150, 1 )
  net.WriteColor( string.ToColor( ply:GetPData( "jhudh_50gain" ) or "255 46 46 255" ) )
  net.WriteColor( string.ToColor( ply:GetPData( "jhudh_60gain" ) or "255 175 28 255" ) )
  net.WriteColor( string.ToColor( ply:GetPData( "jhudh_70gain" ) or "204 252 13 255" ) )
  net.WriteColor( string.ToColor( ply:GetPData( "jhudh_74gain" ) or "0 255 0 255" ) )
  net.WriteColor( string.ToColor( ply:GetPData( "jhudh_77gain" ) or "6 210 0 255" ) )
  net.WriteColor( string.ToColor( ply:GetPData( "jhudh_80gain" ) or "0 255 255 255" ) )
  net.WriteColor( string.ToColor( ply:GetPData( "jhudh_90gain" ) or "243 68 252 255" ) )
  net.Send( ply )
end

concommand.Add("jhud_menu", function(ply, cmd, args, argStr)
  JHUD_RetrieveSettings( ply, true )
end, nil, "Open JHUD menu")

concommand.Add("strafetrainerplease", function( ply )
 StrafeTrainer_CMD(ply)
 end )

hook.Add("PlayerSay","JHUD:ToggleCommand",function(ply,txt)
  local Prefix = string.sub(txt,0,1)
  if Prefix == "!" or Prefix == "/" then
    local PlayerCmd = string.lower(string.sub(txt,2))
    for k,_v in pairs(Commands) do
      for _k, v in pairs(_v) do
        if PlayerCmd == v then
          if k == "jhud" then
            ply:ConCommand("jhud_menu")
            return ""
                    end
        end
      end
    end
  end
end)

local function JHUD_PlayerInit( ply )
  JHUD_RetrieveSettings( ply, false )
end


util.AddNetworkString("train_update")

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

    net.Start("train_update")
      net.WriteFloat(avg)
    net.Send(NetworkList(client))
  else
    percentages[client][t] = perc 
    tick[client] = t + 1
  end

  last[client] = data:GetAngles().y
end


hook.Add("SetupMove", "sm_strafetrainer", SetupMove)
net.Receive("JHUD_IResponse", JHUD_IResponse)

hook.Add("KeyPress", "JHUD:KeyPress", PlayerKeyPress)
hook.Add("KeyRelease", "JHUD:KeyRelease", KeyRelease)

hook.Add("SetupMove", "JHUD:Sync", MonitorSync)
hook.Add("KeyRelease", "JHUD:Strafes", GetStrafes)

hook.Add("SetupMove", "JHUD:Gain", GetGainData)
hook.Add("OnPlayerHitGround", "JHUD:HitGround", OnPlyHitGround)
hook.Add("PlayerInitialSpawn", "JHUD:Init", initTables)
hook.Add("SetupMove", "JHUD:Gain", GetGainData)
hook.Add("OnPlayerHitGround", "JHUD:HitGround", OnPlyHitGround)
hook.Add("PlayerInitialSpawn", "JHUD:PlayerInit", JHUD_PlayerInit)
