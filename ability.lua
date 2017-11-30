local function Ability(cooldown, triggerFn, updateFn, drawFn)
	return {
		cooldown = cooldown or 0,
		time = cooldown,
		triggerFn = triggerFn,
		updateFn = updateFn,
		drawFn = drawFn,
	}
end

return Ability
