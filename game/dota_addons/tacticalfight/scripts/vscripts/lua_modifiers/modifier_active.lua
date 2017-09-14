modifier_active_lua = class({})
LinkLuaModifier( "modifier_active_lua", "lua_modifiers/modifier_active", LUA_MODIFIER_MOTION_NONE )





function modifier_active_lua:GetEffectName()
  return "particles/world_environmental_fx/bluetorch_flame.vpcf"
end

function modifier_active_lua:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
