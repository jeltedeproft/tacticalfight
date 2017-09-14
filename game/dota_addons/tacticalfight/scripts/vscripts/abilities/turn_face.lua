function turn (keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target_points[1]
	local caster_pos = caster:GetAbsOrigin()
	local difference_vector = target - caster_pos
	local unit_direction = difference_vector:Normalized()

	local mid_circle = math.sqrt(2) / 2
	local negative_mid_circle = math.sqrt(2) / -2

	if unit_direction.x >= mid_circle and (unit_direction.y <= mid_circle and unit_direction.y >= negative_mid_circle)  then
		unit_direction.x = 1
		unit_direction.y = 0
		unit_direction.z = 0
		caster:SetForwardVector(unit_direction)
	elseif	
		(unit_direction.x <= mid_circle and unit_direction.x >= negative_mid_circle) and unit_direction.y <= negative_mid_circle  then
		unit_direction.x = 0
		unit_direction.y = -1
		unit_direction.z = 0
		caster:SetForwardVector(unit_direction)
	elseif	
		unit_direction.x <= negative_mid_circle and (unit_direction.y <= mid_circle and unit_direction.y >= negative_mid_circle)  then
		unit_direction.x = -1
		unit_direction.y = 0
		unit_direction.z = 0
		caster:SetForwardVector(unit_direction)
	elseif	
		(unit_direction.x <= mid_circle and unit_direction.x >= negative_mid_circle) and unit_direction.y >= mid_circle  then
		unit_direction.x = 0
		unit_direction.y = 1
		unit_direction.z = 0
		caster:SetForwardVector(unit_direction)
	end  
end