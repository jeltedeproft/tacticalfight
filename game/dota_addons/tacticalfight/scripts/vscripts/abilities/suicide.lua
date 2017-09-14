function Suicide( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- -- Insert modifiers into the table that would otherwise prevent a units death
	-- local exception_table = {}
	-- table.insert(exception_table, "modifier_dazzle_shallow_grave")
	-- table.insert(exception_table, "modifier_shallow_grave_datadriven")

	-- -- Remove the modifiers if they exist
	-- local modifier_count = caster:GetModifierCount()
	-- for i = 0, modifier_count do
	-- 	local modifier_name = caster:GetModifierNameByIndex(i)
	-- 	local modifier_check = false

	-- 	-- Compare if the modifier is in the exception table
	-- 	-- If it is then set the helper variable to true and remove it
	-- 	for j = 0, #exception_table do
	-- 		if exception_table[j] == modifier_name then
	-- 			modifier_check = true
	-- 			break
	-- 		end
	-- 	end

	-- 	-- Remove the modifier depending on the helper variable
	-- 	if modifier_check then
	-- 		caster:RemoveModifierByName(modifier_name)
	-- 	end
	-- end

	caster:Kill(ability, caster)
end