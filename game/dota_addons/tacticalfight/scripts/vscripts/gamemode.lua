-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')
-- This library can be used to synchronize client-server data via player/client-specific nettables
require('libraries/playertables')
-- This library can be used to create container inventories or container shops
require('libraries/containers')
-- This library provides a searchable, automatically updating lua API in the tools-mode via "modmaker_api" console command
require('libraries/modmaker')
-- This library provides an automatic graph construction of path_corner entities within the map
require('libraries/pathgraph')
-- This library (by Noya) provides player selection inspection and management from server lua
require('libraries/selection')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')
require("lua_modifiers/modifier_silenced")
require("lua_modifiers/modifier_active")


--require("examples/worldpanelsExample")

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()

end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  local playerID = hero:GetPlayerID()
  local player = PlayerResource:GetPlayer(playerID)
  local team = PlayerResource:GetTeam(playerID)
  if hero:GetName() == "npc_dota_hero_legion_commander" then

    hero:SetModelScale(3.0)

    for id=0,6 do
        local ability = hero:GetAbilityByIndex(id)
        if ability and ability:GetAbilityName() ~= "attribute_bonus" then
            hero:RemoveAbility(ability:GetAbilityName())
        end
    end

    hero:AddAbility("stunned")
    hero:AddAbility("turn_face")
    hero:SetAbilityPoints(0)
    hero:FindAbilityByName("stunned"):SetLevel(1)
    hero:FindAbilityByName("turn_face"):SetLevel(1)

    Timers:CreateTimer({
      endTime = 1, 
      callback = function()
        if team == DOTA_TEAM_GOODGUYS then
          FindClearSpaceForUnit(hero, Vector(128,3520,640), true)
        else
          FindClearSpaceForUnit(hero, Vector(128,-2880,640), true)
        end
        amount_of_players = amount_of_players + 1
      end
    })
  end
end



--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()

end

function GameMode:Silence(team)
  units_from_given_team = FindUnitsInRadius(team, Vector(0,0,128), nil, 10000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,  DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
  for _,unit in pairs(units_from_given_team) do
    unit:AddNewModifier(unit, nil, "modifier_silenced_lua", {})
    unit:RemoveModifierByName("modifier_active_lua")
  end
end

function GameMode:UnSilence(team)
  units_from_given_team = FindUnitsInRadius(team, Vector(0,0,128), nil, 10000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,  DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
  for _,unit in pairs(units_from_given_team) do
    unit:RemoveModifierByName("modifier_silenced_lua")
    unit:AddNewModifier(unit, nil, "modifier_active_lua", {})
    for id=0,8 do
        local ability = unit:GetAbilityByIndex(id)
        if ability and ability:GetAbilityName() ~= "attribute_bonus" then
            ability:EndCooldown()
        end
    end
  end
end

function GameMode:GetTurn()
  return TURN
end

function GameMode:NextTurn(data)
  local time = 45
  local teamid = data.teamID

  if teamid == GameMode:GetTurn() then
    EmitGlobalSound("General.FemaleLevelUp")
    if GameMode:GetTurn() == DOTA_TEAM_GOODGUYS then
      Notifications:TopToAll({text="Radiant's Turn ", duration=2.0})
      GameMode:Silence(DOTA_TEAM_GOODGUYS)
      GameMode:UnSilence(DOTA_TEAM_BADGUYS)
      print(GameMode:GetTurn())
      TURN = DOTA_TEAM_BADGUYS

      Timers:CreateTimer(function()
        if GameMode:GetTurn() == DOTA_TEAM_BADGUYS then
          if time ~= nil then
            Notifications:TopToAll({text=time, duration=0.7, style={color="red"}})
          end
          time = time - 1
          if time < 0 then
            GameMode:NextTurn({teamID = DOTA_TEAM_BADGUYS})
          else
            return 1.0
          end
        else
        end
      end
      )


      else if GameMode:GetTurn() == DOTA_TEAM_BADGUYS then
        Notifications:TopToAll({text="Dire's Turn ", duration=2.0})
        GameMode:Silence(DOTA_TEAM_BADGUYS)
        GameMode:UnSilence(DOTA_TEAM_GOODGUYS)
        TURN = DOTA_TEAM_GOODGUYS

        Timers:CreateTimer(function()
          if GameMode:GetTurn() == DOTA_TEAM_GOODGUYS then
            if time ~= nil then
              Notifications:TopToAll({text=time, duration=0.7, style={color="green"}})
            end
            time = time - 1
            if time < 0 then
              GameMode:NextTurn({teamID = DOTA_TEAM_GOODGUYS})
            else 
              return 1.0
            end
          else
          end
        end
        )
      end
    end
  end
end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  amount_of_players = 0
  TURN = 0

  if RandomInt( 1, 2 ) == 1 then
    TURN = DOTA_TEAM_GOODGUYS
  else
    TURN = DOTA_TEAM_BADGUYS
  end

  startx = -2496
  starty = -2048

  blocksize = 720

  GameMode:initField()

  units_team_0 = {}
  units_team_1 = {}

  radiant_units = 0
  dire_units = 0

  number_of_units_per_team = 5

  spawnpoints_team_0 = {Vector(-2516,2955,128),
                        Vector(-1856,2880,128),
                        Vector(-1024,2950,128),
                        Vector(-256,2964,128),
                        Vector(448,2955,128)}

  spawnpoints_team_1 = {Vector(-2496,-2048,128),
                        Vector(-1780,-2038,128),
                        Vector(-1088,-2015,128),
                        Vector(-499,-2031,128),
                        Vector(128,-1995,128)}

  local mode = GameRules:GetGameModeEntity()
  mode:SetFogOfWarDisabled(true)

  GameRules:SetHeroSelectionTime(0)
  GameRules:SetPreGameTime(10)

  CustomGameEventManager:RegisterListener( "hero_selected", Dynamic_Wrap(GameMode, 'AddTeamMember'))
  CustomGameEventManager:RegisterListener( "skip_turn", Dynamic_Wrap(GameMode, 'NextTurn'))
  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GameMode, 'Ongame_rules_state_change'), self)
end

function GameMode:initField()
    self.field = {}
    for y=0, 7 do
        posy = starty+y*blocksize
        for x=0,7 do
            posx = startx+x*blocksize
            self.field[8*y+x] = Vector(posx, posy, 128)
        end
    end
end

function MoveTo(keys)
  local amount_of_steps = keys.jumps
  local caster = keys.caster
  local ability = keys.ability
  local caster_pos = caster:GetAbsOrigin()
  local destination = keys.target_points[1]
  local boarddestination = toboardPos(destination.x,destination.y,128)

  if ValidMove(amount_of_steps,caster,caster_pos,boarddestination) then
    local time_walk = caster:FindAbilityByName("faceless_void_time_walk_datadriven")
    caster:CastAbilityOnPosition(toCoordinates(boarddestination),time_walk, caster:GetPlayerOwnerID())
    align(caster_pos,toCoordinates(boarddestination),caster)
  else
    ability:EndCooldown()
  end
end

function align (caster_pos,destination,hero)
  local difference_vector = destination - caster_pos 
  local unit_direction = difference_vector:Normalized()

  local mid_circle = math.sqrt(2) / 2
  local negative_mid_circle = math.sqrt(2) / -2

  if unit_direction.x >= mid_circle and (unit_direction.y <= mid_circle and unit_direction.y >= negative_mid_circle)  then
    unit_direction.x = 1
    unit_direction.y = 0
    unit_direction.z = 0
    hero:SetForwardVector(unit_direction)
  elseif  
    (unit_direction.x <= mid_circle and unit_direction.x >= negative_mid_circle) and unit_direction.y <= negative_mid_circle  then
    unit_direction.x = 0
    unit_direction.y = -1
    unit_direction.z = 0
    hero:SetForwardVector(unit_direction)
  elseif  
    unit_direction.x <= negative_mid_circle and (unit_direction.y <= mid_circle and unit_direction.y >= negative_mid_circle)  then
    unit_direction.x = -1
    unit_direction.y = 0
    unit_direction.z = 0
    hero:SetForwardVector(unit_direction)
  elseif  
    (unit_direction.x <= mid_circle and unit_direction.x >= negative_mid_circle) and unit_direction.y >= mid_circle  then
    unit_direction.x = 0
    unit_direction.y = 1
    unit_direction.z = 0
    hero:SetForwardVector(unit_direction)
  end  
end

function ValidMove(steps,caster,caster_pos,destination)
  if destination == false then
    return false
  else
    if IsUnitOnSquare(caster, destination) then
      return false
    else
      if IsWithinReach(caster_pos, steps, destination) then
        return true
      else
        return false
      end
    end
  end
end

function IsWithinReach(current_pos, steps,goal)
  local distance = math.abs((toCoordinates(goal) - current_pos):Length2D())

  if steps == 3 then
    if distance > (steps * blocksize) - (blocksize / 2) then
      return false
    else
      return true
    end
  elseif steps == 2 then
    if distance > (steps * blocksize) + (blocksize / 5) then
      return false
    else
      return true
    end
  elseif steps == 1 then
    if distance > (steps * blocksize) + (blocksize / 2) then
      return false
    else
      return true
    end
  end
end

function IsUnitOnSquare(caster,square)
  local units = FindUnitsInRadius(caster:GetTeamNumber(), toCoordinates(square), nil, blocksize / 2, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

  if units[1] == nil then
    return false
  else
    return true
  end
end

function toCoordinates(boardpos)
  local x = startx + (boardpos%8 * blocksize)
  local y = starty + (math.floor(boardpos/8) * blocksize)
  return Vector(x, y,128)
end


function toboardPos(x, y)
  if x < startx-blocksize/2 or x > startx+7*blocksize+blocksize/2 or y < starty-blocksize/2 or y > starty+7*blocksize + blocksize/2 then
    return false
  else
    local xpart = 0
    local ypart = 0
    for i=0, 7 do
        if math.abs(x-(startx+blocksize*i))<=blocksize/2 then
            xpart = i
        end
    end
    for i=0, 7 do
        if math.abs(y-(starty+blocksize*i))<=blocksize/2 then
            ypart = i
        end
    end
    return ypart*8+xpart
  end 
end


function GameMode:Ongame_rules_state_change()
  if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then

    --Send a pick event to all clients
    CustomGameEventManager:Send_ServerToAllClients( "start_picking_phase", {} )
  end

  if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

    for i = 1, number_of_units_per_team do
      if (units_team_0[i] ~= nil or units_team_1[i] ~= nil) and (spawnpoints_team_0[i] ~= nil or spawnpoints_team_1[i] ~= nil) then
        FindClearSpaceForUnit(units_team_0[i], spawnpoints_team_0[i], true)
        FindClearSpaceForUnit(units_team_1[i], spawnpoints_team_1[i], true)
      end
    end

    --Send a pick event to all clients
    CustomGameEventManager:Send_ServerToAllClients( "start_game_phase", {} )

    local data = {teamID = TURN}
    GameMode:NextTurn(data)
  end
end

function GameMode:AddTeamMember(data)
  local heroname = data.HeroName
  local trueheroname = data.TrueHeroName
  local playerid = data.PlayerID
  local player = PlayerResource:GetPlayer(playerid)
  local team = PlayerResource:GetTeam(playerid)
  local hero_number = data.AmountHeroes


  if (#units_team_0 < 5) then
    if (#units_team_1 < 5) then
      if team == 2 then
        radiant_units = radiant_units + 1
        CustomGameEventManager:Send_ServerToAllClients( "enemy_picked", {enemy_team = team,heroname = trueheroname, number = hero_number} )
        local unit = CreateUnitByName(heroname, Vector(0,0,320), true, player, player, team)
        unit:SetControllableByPlayer(playerid, true)
        table.insert(units_team_0,unit)
      else
        dire_units = dire_units + 1
        CustomGameEventManager:Send_ServerToAllClients( "enemy_picked", {enemy_team = team,heroname = trueheroname, number = hero_number} )
        local unit2 = CreateUnitByName(heroname, Vector(0,0,320), true, player, player, team)
        unit2:SetControllableByPlayer(playerid, true)
        table.insert(units_team_1,unit2)
      end
    else
      if team == 2 then
        radiant_units = radiant_units + 1
        CustomGameEventManager:Send_ServerToAllClients( "enemy_picked", {enemy_team = team,heroname = trueheroname, number = hero_number} )
        local unit3 = CreateUnitByName(heroname, Vector(0,0,320), true, player, player, team)
        unit3:SetControllableByPlayer(playerid, true)
        table.insert(units_team_0,unit3)
      end
    end
  else
    if (#units_team_1 < 5) then
      if team ~= 2 then
        dire_units = dire_units + 1
        CustomGameEventManager:Send_ServerToAllClients( "enemy_picked", {enemy_team = team,heroname = trueheroname, number = hero_number} )
        local unit4 = CreateUnitByName(heroname, Vector(0,0,320), true, player, player, team)
        unit4:SetControllableByPlayer(playerid, true)
        table.insert(units_team_1,unit4)
      end
    end
  end
end



