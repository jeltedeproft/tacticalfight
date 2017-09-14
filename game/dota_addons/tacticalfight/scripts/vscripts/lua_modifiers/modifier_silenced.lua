modifier_silenced_lua = class({})
LinkLuaModifier( "modifier_silenced_lua", "lua_modifiers/modifier_silenced", LUA_MODIFIER_MOTION_NONE )


function modifier_silenced_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
 
    return funcs
end

-- function modifier_silenced_lua:GetOverrideAnimation(params)
--     return ACT_DOTA_FLAIL
-- end

function modifier_silenced_lua:CheckState()
	local state = {
	[MODIFIER_STATE_SILENCED] = true,
	}
 
	return state
end

function modifier_silenced_lua:IsDebuff()
    return true
end
 
function modifier_silenced_lua:IsStunDebuff()
    return true
end

function modifier_silenced_lua:GetEffectName()
  return "particles/hw_fx/candy_carrying_overhead.vpcf"
end

function modifier_silenced_lua:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_silenced_lua:GetTexture()
	return "silencer_last_word"
end