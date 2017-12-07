require "util"
Process = require "process"

local function Character()
	return
	{ 
		abilities = 
		{
			q = Ability(1, function(self) --trigger
					local pos = mouseWorldPos()

					table.insert(Process.processes, Process(
						0.75,
						0,
						{ pos = pos },
						function(process, dt) self.updateFn(process, dt) end,
						function(process) self.drawFn(process) end
					))

					for i=#enemies, 1, -1 do
						local enemy = enemies[i]
						if (pos - enemy.pos):length() <= 50 then
							table.remove(enemies, i)
						end
					end
				end, function(process, dt) --update
				end, function(process) --draw
					love.graphics.setColor(
							255, 0, 0, math.mix(process.time / process.duration, 255, 0))
					love.graphics.circle("fill", process.pos.x, process.pos.y, 30)
				end
			),
			w = Ability(3, function(self) --trigger
					local pos = mouseWorldPos()

					table.insert(Process.processes, Process(
						nil,
						0,
						{ pos = pos, radius = 0, speed = 20 },
						function(process, dt) self.updateFn(process, dt) end,
						function(process) self.drawFn(process) end
					))
				end, function(process, dt) --update
					for k, enemy in pairs(enemies) do
						if (process.pos - enemy.pos):length() <= process.radius then
							enemy.pos = enemy.pos + (enemy.pos - process.pos):normalized() * process.speed
						end
					end
					process.radius = process.radius + process.speed * 0.60
					process.speed = process.speed - 0.7
					if process.radius > 150 then
						Process:remove(process)
					end
				end, function(process) --draw
					--love.graphics.setColor(10, 50, 200, process.radius*2.55)
					love.graphics.setColor(150, 150, 0, 255)
					love.graphics.circle("fill", process.pos.x, process.pos.y, process.radius)
				end
			),
			e = Ability(3, function(self) --trigger
					local pos = mouseWorldPos()

					table.insert(Process.processes, Process(
						nil,
						0,
						{ pos = pos, radius = 150, constDecay = 0.05, linearDecay = 0.85 },
						function(process, dt) self.updateFn(process, dt) end,
						function(process) self.drawFn(process) end
					))
				end, function(process, dt) --update
					for k, enemy in pairs(enemies) do
						if (process.pos - enemy.pos):length() <= process.radius then
							enemy.pos = enemy.pos * process.linearDecay +
									process.pos * (1 - process.linearDecay) +
									(process.pos - enemy.pos):normalized() * process.constDecay
						end
					end
					--process.radius = math.mix(100, 0, 1-process.time/process.duration)
					process.radius = process.radius * process.linearDecay - process.constDecay
					if process.radius <= 0 then
						Process:remove(process)
					end
				end, function(process) --draw
					--love.graphics.setColor(10, 50, 200, process.radius*2.55)
					love.graphics.setColor(10, 50, 200, 255)
					love.graphics.circle("fill", process.pos.x, process.pos.y, process.radius)
				end
			),
			r = Ability(7, function(self) --trigger
					local pos = mouseWorldPos()

					table.insert(Process.processes, Process(
						3,
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
			),
		}
	}
end

return Character
