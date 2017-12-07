require "util"
Process = require "process"

local function Character()
	return
	{ 
		abilities = 
		{
			q = {
				cooldown = 0,
				time = 4,
				triggerFn = function(self)
						local mouse = mouseWorldPos()
						local to = false
						for i = #enemies, 1, -1 do
							local enemy = enemies[i]
							if (mouse - enemy.pos):length() <= 20 then
								to = enemy.pos
								table.remove(enemies, i)
								break
							end
						end

						if to then
							local process = Process(
								0.15,
								0,
								{ counter = 100,
										from = copy(player.pos) , to = to,
										drawUpdateInterval = 0.025, drawTime = 0.025 },
								self.updateFn,
								self.drawFn,
								self.endFn
							)

							table.insert(Process.processes, process)
							self.updateFn(process, 0)
						end
				end,
				updateFn = function(process, dt)
					process.drawTime = process.drawTime + dt

					if process.drawUpdateInterval <= process.drawTime then
						process.points = {}
						local dir = (process.to - process.from):normalized()
						local right = dir:rotated(math.pi / 2)
						local distance = (process.to - process.from):length()
						local points = math.ceil(distance / 50)
						local from = process.from
						table.insert(process.points, from)
						for i = 1, points - 1, 1 do
							local to = process.from + dir * i * 50 +
									right * (20 - math.random(40))
							table.insert(process.points, to)
							from = to
						end
						table.insert(process.points, process.to)

						process.drawTime = 0
					end
				end,
				drawFn = function(process)
					love.graphics.setColor(190, 210, 255, 255)
					local points = process.points
					for i = 1, #process.points - 1, 1 do
						love.graphics.line(
								points[i].x, points[i].y,
								points[i + 1].x, points[i + 1].y)
					end
				end,
				endFn = function(process)
					if process.counter >= 0 then
						local mouse = mouseWorldPos()
						local to = false
						local index = 1

						for i = 1, #enemies, 1 do
							local enemy = enemies[i]
							if not to then
								if (process.to - enemy.pos):length() <= 500 then
									to = enemy.pos
									index = i
								end
							elseif (process.to - enemy.pos):length()
									< (process.to - to):length() then
								to = enemy.pos
								index = i
							end

							i = i + 1
						end

						if to then
							local process = Process(
								process.duration,
								0,
								{ counter = process.counter - 1,
										from = process.to , to = to,
										drawUpdateInterval = 0.025, drawTime = 0.025 },
								process.updateFn,
								process.drawFn,
								process.endFn
							)


							table.remove(enemies, index)
							table.insert(Process.processes, process)
							process.updateFn(process, 0)
						end
					end
				end
			},
			r = Ability(0, function(self) --trigger
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
			)
		}
	}
end

return Character
