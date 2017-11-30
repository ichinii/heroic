require "util"
Process = require "process"

local function Archer()
	return
	{ 
		abilities = 
		{
			q = Ability(0.125, function(self) --trigger
					table.insert(Process.processes, Process(
						1,
						0,
						{
							pos = copy(player.pos),
							dir = (mouseWorldPos() - player.pos):normalized()
						},
						function(process, dt) self.updateFn(process, dt) end,
						function(process) self.drawFn(process) end
					))
				end, function(process, dt) --update
					process.pos = process.pos + process.dir * dt * 800

					for i=#enemies, 1, -1 do
						local enemy = enemies[i]
						if (process.pos - enemy.pos):length() <= 50 then
							table.remove(enemies, i)
							process.time = process.duration
							break
						end
					end
				end, function(process) --draw
					love.graphics.setColor(
							255, 0, 0, 255)
					love.graphics.circle("fill", process.pos.x, process.pos.y, 10)
				end
			),
			w = Ability(5, function(self) --trigger
					local pos = mouseWorldPos()

					table.insert(Process.processes, Process(
						3.5,
						0,
						{ pos = pos },
						function(process, dt) self.updateFn(process, dt) end,
						function(process) self.drawFn(process) end
					))
				end, function(process, dt) --update
					for k, enemy in pairs(enemies) do
						if (process.pos - enemy.pos):length() <= 100 then
							enemy.stunned = true
						end
					end
				end, function(process) --draw
					love.graphics.setColor(50, 255, 100, 255)
					love.graphics.circle("fill", process.pos.x, process.pos.y, 80)
				end
			)
		}
	}
end

return Archer
