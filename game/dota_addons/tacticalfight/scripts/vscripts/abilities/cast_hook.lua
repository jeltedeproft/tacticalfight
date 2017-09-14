function Cast (keys)
	local caster = keys.caster
	local ability = keys.ability
	local caster_position = caster:GetAbsOrigin() 
	local caster_direction = caster:GetForwardVector() 

	local distance = ability:GetLevelSpecialValueFor("hook_distance", (ability:GetLevel()-1))
	
	local hook = caster:FindAbilityByName("pudge_meat_hook_lua")
	caster:CastAbilityOnPosition(caster_position + caster_direction, hook, -1)
end