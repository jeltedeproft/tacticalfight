-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache( context )
  PrecacheUnitByNameSync("npc_dota_hero_faceless_void", context)
  PrecacheUnitByNameSync("npc_dota_hero_techies", context)
  PrecacheUnitByNameSync("npc_dota_hero_pudge", context)
  PrecacheUnitByNameSync("npc_dota_hero_omniknight", context)
  PrecacheUnitByNameSync("npc_dota_hero_earth_spirit", context)
  PrecacheUnitByNameSync("npc_dota_hero_windrunner", context)
  PrecacheUnitByNameSync("npc_dota_hero_axe", context)
  PrecacheUnitByNameSync("npc_dota_hero_spirit_breaker", context)
  PrecacheResource("particle", "particles/world_environmental_fx/bluetorch_flame.vpcf", context)
  PrecacheUnitByNameSync("npc_dota_hero_vengefulspirit", context)
  PrecacheUnitByNameSync("npc_dota_hero_riki", context)
  PrecacheUnitByNameSync("npc_dota_hero_zuus", context)
  PrecacheUnitByNameSync("npc_dota_hero_chen", context)
end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:_InitGameMode()
end