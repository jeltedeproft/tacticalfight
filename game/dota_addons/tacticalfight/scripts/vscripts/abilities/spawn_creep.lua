function HolyPersuasion( keys )
	local target_point = keys.target_points[1]
	local possible_creeps = {"npc_dota_creep_goodguys_melee_upgraded",
							"npc_dota_neutral_centaur_khan",
							"npc_dota_neutral_alpha_wolf",
							"npc_dota_neutral_dark_troll_warlord",
							"npc_dota_neutral_ghost",
							"npc_dota_neutral_harpy_storm",
							"npc_dota_neutral_polar_furbolg_ursa_warrior",
							"npc_dota_neutral_forest_troll_high_priest",
							"npc_dota_neutral_mud_golem",
							"npc_dota_neutral_ogre_magi",
							"npc_dota_neutral_enraged_wildkin",
							"npc_dota_neutral_satyr_hellcaller"}
	local randomcreepnumber = RandomInt(0,11)

	local caster = keys.caster
	local caster_pos = caster:GetAbsOrigin()

	local units = FindUnitsInRadius( caster:GetTeamNumber(), target_point, nil, 310,
			DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false )

	if table.getn(units) < 1 then
		print("hey")
		local target = CreateUnitByName(possible_creeps[randomcreepnumber],target_point,true,caster,caster,caster:GetTeam())
		FindClearSpaceForUnit(target, target_point, true)
	else
		print("fail")
	end

	local caster_team = caster:GetTeamNumber()
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Initialize the tracking data
	ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count or 0
	ability.holy_persuasion_table = ability.holy_persuasion_table or {}

	-- Ability variables
	local max_units = ability:GetLevelSpecialValueFor("max_units", ability_level)
	local health_bonus = ability:GetLevelSpecialValueFor("health_bonus", ability_level)

	if target ~= nil then
		-- Change the ownership of the unit and restore its mana to full
		target:SetTeam(caster_team)
		target:SetOwner(caster)
		target:SetControllableByPlayer(player, true)
		target:SetMaxHealth(100)
		target:Heal(health_bonus, ability)
		target:GiveMana(target:GetMaxMana())

		ability:ApplyDataDrivenModifier(caster,target,"modifier_holy_persuasion_datadriven",{})

		-- Track the unit
		ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count + 1
		table.insert(ability.holy_persuasion_table, target)
	end

	-- If the maximum amount of units is reached then kill the oldest unit
	if ability.holy_persuasion_unit_count > max_units then
		ability.holy_persuasion_table[1]:ForceKill(true) 
	end
end

--[[Author: Pizzalol
	Date: 06.04.2015.
	Removes the target from the table]]
function HolyPersuasionRemove( keys )
	local target = keys.target
	local ability = keys.ability

	-- Find the unit and remove it from the table
	for i = 1, #ability.holy_persuasion_table do
		if ability.holy_persuasion_table[i] == target then
			table.remove(ability.holy_persuasion_table, i)
			ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count - 1
			break
		end
	end
end
