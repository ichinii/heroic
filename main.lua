require "util"
Process = require "process"
Ability = require "ability"
vec2 = require "vec2"

Character = require "characters/mage"

Enemy = function(pos)
	return {
		pos = pos,
		stunned = false
	}
end

function reset()
	time = love.timer.getTime()
	Process.processes = {}
	player = { pos = vec2(0, 0), move = nil, character = player.character }
	camera = { pos = copy(player.pos) }
	enemies = {}
	enemiesTime = 0
	abilitiesTriggered = {}
end

function love.load()
	score = nil
	player = { character = Character() }

	reset()
end
 
function love.update(dt)
	camera.pos = camera.pos + (player.pos - camera.pos) / 8

	for k, v in pairs(abilitiesTriggered) do
		if not love.keyboard.isDown(k) then
			abilitiesTriggered[k] = nil
		end
	end

	for k, enemy in pairs(enemies) do
		if (player.pos - enemy.pos):length() < 20+30 then
			local currentScore = love.timer.getTime() - time
			if not score or currentScore > score then
				score = currentScore
			end

			reset()
			return
		end
	end

	for k, v in pairs(player.character.abilities) do
		v.time = v.time + dt
		if not abilitiesTriggered[k] and
				love.keyboard.isDown(k) and
				v.cooldown <= v.time then
			abilitiesTriggered[k] = true
			v.triggerFn(v)
			v.time = 0
		end
	end

	Process:update(dt)

	for k, enemy in pairs(enemies) do
		if not enemy.stunned then
			local dir = (player.pos - enemy.pos):normalized()
			enemy.pos = enemy.pos + dir * 3.3
		end

		enemy.stunned = false
	end

	if love.keyboard.isDown("s") then
		player.move = nil
	end
	if love.mouse.isDown("r") then
		player.move = mouseWorldPos()
	end

	if player.move then
		local step = 3
		local diff = (player.move - player.pos)
		
		if diff:length() <= step then
			player.pos = player.move
			player.move = nil
		else
			player.pos = player.pos + diff:normalized() * step
		end
	end

	enemiesTime = enemiesTime + dt
	if enemiesTime > 0.75 then
		local rand = math.random() * math.pi * 2.0
		table.insert(
			enemies,
			Enemy(player.pos + vec2(math.cos(rand), math.sin(rand)) * 1000)
		)
		enemiesTime = 0
	end
end
 
function love.draw()
	love.graphics.push()
	love.graphics.translate(
		love.graphics.getWidth()  / 2 - camera.pos.x,
		love.graphics.getHeight() / 2 - camera.pos.y)
	--

	local grid = 100
	love.graphics.setColor(100, 100, 100, 255)
	for 
		x = math.floor((camera.pos.x - love.graphics.getWidth() / 2) / grid) * grid,
		camera.pos.x + love.graphics.getWidth() / 2,
		grid
	do
		love.graphics.line(x, camera.pos.y - love.graphics.getHeight() / 2,
				x, camera.pos.y + love.graphics.getHeight() / 2)
	end
	for 
		y = math.floor((camera.pos.y - love.graphics.getHeight() / 2) / grid) * grid,
		camera.pos.y + love.graphics.getHeight() / 2,
		grid
	do
		love.graphics.line(camera.pos.x - love.graphics.getWidth() / 2, y,
				camera.pos.x + love.graphics.getWidth() / 2, y)
	end

	Process:draw()

	for k, enemy in pairs(enemies) do
		love.graphics.setColor(100, 0, 255, 255)
		love.graphics.circle("fill", enemy.pos.x, enemy.pos.y, 20)
	end

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.circle("fill", player.pos.x, player.pos.y, 30)

	if player.move then
		love.graphics.circle("line", player.move.x, player.move.y, 10)
	end

	--
	love.graphics.pop()

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("time: "..
			tostring(math.floor(love.timer.getTime() - time)), 20, 20)
	if score then
		love.graphics.print("score: "..
				tostring(math.floor(score)), 20, 40)
	end

	love.graphics.print("'mouse right' to move", 20, love.graphics.getHeight() - 40)
	love.graphics.print("'s' to stop", 20, love.graphics.getHeight() - 60)
	love.graphics.print("'q' to attack", 20, love.graphics.getHeight() - 80)
	love.graphics.print("'w' to stun", 20, love.graphics.getHeight() - 100)
end
