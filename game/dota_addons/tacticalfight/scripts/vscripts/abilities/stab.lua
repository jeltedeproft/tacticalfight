function stab(keys)
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	local extra_damage = ability:GetLevelSpecialValueFor("extra_damage", ability:GetLevel() - 1)

	-- The y value of the angles vector contains the angle we actually want: where units are directionally facing in the world.
	local victim_angle = target:GetAnglesAsVector().y
	local origin_difference = target:GetAbsOrigin() - caster:GetAbsOrigin()

	-- Get the radian of the origin difference between the attacker and Riki. We use this to figure out at what angle the victim is at relative to Riki.
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	
	-- Convert the radian to degrees.
	origin_difference_radian = origin_difference_radian * 180
	local attacker_angle = origin_difference_radian / math.pi
	-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
	attacker_angle = attacker_angle + 180.0
	
	-- Finally, get the angle at which the victim is facing Riki.
	local result_angle = attacker_angle - victim_angle
	result_angle = math.abs(result_angle)
	
	-- Check for the backstab angle.
	if result_angle >= (180 - (ability:GetSpecialValueFor("backstab_angle") / 2)) and result_angle <= (180 + (ability:GetSpecialValueFor("backstab_angle") / 2)) then 
		-- Play the sound on the victim.
		EmitSoundOn("Hero_Riki.Backstab", target)
		EmitSoundOn(keys.sound, target)
		-- Create the back particle effect.
		local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, target) 
		-- Set Control Point 1 for the backstab particle; this controls where it's positioned in the world. In this case, it should be positioned on the victim.
		ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		-- Apply extra backstab damage based on Riki's agility
		ApplyDamage({victim = target, attacker = caster, damage = extra_damage, damage_type = ability:GetAbilityDamageType()})
	else
		--EmitSoundOn(keys.sound2, target)
		-- uncomment this if regular (non-backstab) attack has no sound
	end
end