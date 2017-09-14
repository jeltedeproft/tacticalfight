function charge( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin() 
	local forward_vector = caster:GetForwardVector()
	local target_point = caster_location + forward_vector * 5500
	local ability = keys.ability
	local speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1)) * 0.03
	local width = ability:GetLevelSpecialValueFor("width", (ability:GetLevel() - 1))

	local distance = (target_point - caster_location):Length2D()
	local direction = (target_point - caster_location):Normalized()
	local traveled_distance = 0

	-- Moving the caster
	Timers:CreateTimer(0, function()
		caster_location = caster_location + direction * speed

			--reached end of the field
		if caster_location.x < startx-50
		or caster_location.x > startx+7*blocksize + 50 
		or caster_location.y < starty -50 
		or caster_location.y > starty+7*blocksize + 50 then
			caster:RemoveModifierByName("modifier_bull_rush")
			local boarddestination = toboardPos(caster_location.x,caster_location.y,128)
			local time_walk = caster:FindAbilityByName("faceless_void_time_walk_datadriven")
			caster:CastAbilityOnPosition(toCoordinates(boarddestination),time_walk, caster:GetPlayerOwnerID())

			Timers:CreateTimer(0.5, function()
			    time_walk:EndCooldown()
			  end
			)		
		else
			--check if we are hitting someone
			local vEndPos = caster_location + forward_vector * 310
			local units = FindUnitsInLine(caster:GetTeam(), caster_location, vEndPos, caster, width, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE)
			if #units > 1 then
				for _,unit in pairs(units) do
					if unit ~= caster then
						if unit:GetTeam() == caster:GetTeam() then
							local boarddestination = toboardPos(caster_location.x,caster_location.y,128)
							local time_walk = caster:FindAbilityByName("faceless_void_time_walk_datadriven")
							caster:CastAbilityOnPosition(toCoordinates(boarddestination),time_walk, caster:GetPlayerOwnerID())
							caster:RemoveModifierByName("modifier_bull_rush")
							time_walk:EndCooldown()
						else
							local unit_behind = FindUnitsInRadius(caster:GetTeam(), caster_location + forward_vector * 1030, nil, 310, DOTA_UNIT_TARGET_TEAM_BOTH,  DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
							caster:RemoveModifierByName("modifier_bull_rush")
							time_walk:EndCooldown()
							if #unit_behind == 0 and toboardPos((caster_location + forward_vector * 1440).x,((caster_location + forward_vector * 1440)).y,128) then
								local knockbackProperties =
								{
								center_x = caster:GetAbsOrigin().x,
								center_y = caster:GetAbsOrigin().y,
								center_z = caster:GetAbsOrigin().z,
								duration = 1,
								knockback_duration = 1,
								knockback_distance = 720,
								knockback_height = 250
								}
								unit:AddNewModifier( unit, nil, "modifier_knockback", knockbackProperties )
								caster:RemoveModifierByName("modifier_bull_rush")
								local boarddestination = toboardPos(caster_location.x,caster_location.y,128)
								local time_walk = caster:FindAbilityByName("faceless_void_time_walk_datadriven")
								caster:CastAbilityOnPosition(toCoordinates(boarddestination),time_walk, caster:GetPlayerOwnerID())
								time_walk:EndCooldown()
							end
						end
					end
				end
			else
				caster:SetAbsOrigin(caster_location)
				traveled_distance = traveled_distance + speed
				return 0.03
			end
		end
	end)
end