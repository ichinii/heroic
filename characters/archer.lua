require "util"
Process = require "process"
CharacterState = require "characterstate"

local function Character()
	return
	{
		pos = vec2(),
		move = nil,
		state = CharacterState(),
		abilities = 
		{
			q = Ability(0, function(self, character) --trigger
					table.insert(Process.processes, Process(
						1,
						0,
						{
							pos = copy(player.pos),
							dir = (mouseWorldPos() - character.pos):normalized(),
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
			e = Ability(1, function(self, character)
				character.state.immobilized = character.state.immobilized + 1
				local dir = (mouseWorldPos() - character.pos):normalized()

				table.insert(Process.processes, Process(
					0.2,
					0,
						{ dir = dir, character = character },
						self.updateFn,
						self.drawFn,
						function(process)
							process.character.state.immobilized = process.character.state.immobilized - 1
						end
					))
				end, function(process, dt)
					process.character.pos = process.character.pos +
							process.dir * dt *
							(200 / process.duration)
				end, function(process)
				end),
			w = {
				cooldown = 1,
				time = 0,
				triggerFn = function(self, character) 
					character.state.immobilized = character.state.immobilized + 1
					local dir = (mouseWorldPos() - character.pos):normalized()

					table.insert(Process.processes, {
						ability = self,
						character = character,
						dir = dir,
						duration = 0.2,
						time = 0,
						updateFn = function(process, dt)
							process.character.pos = process.character.pos +
									process.dir * dt *
									(200 / process.duration)
						end, endFn = function(process)
							process.character.state.immobilized = process.character.state.immobilized - 1
						end, drawFn = function(process) end
					})
				end
			}
		}
	}
end

return Character
