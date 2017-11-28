require 'util'
vec2 = require 'vec2'

Ability = function(cooldown, triggerFn, processFn, drawFn)
	return {
		cooldown = cooldown or 0,
		time = cooldown,
		triggerFn = triggerFn,
		processFn = processFn,
		drawFn = drawFn
	}
end

Enemy = function(pos)
	return {
		pos = pos,
		stunned = false
	}
end

function removeProcess(key, process)
	for k, v in pairs(processes[key]) do
		if v == process then
			table.remove(processes[key], k)
			return
		end
	end
end

function reset()
	time = love.timer.getTime()
	player = { pos = vec2(0, 0), move = nil }
	camera = { pos = copy(player.pos) }
	enemies = {}
	enemiesTime = 0
	processes = {}
	for k, v in pairs(abilities) do
		processes[k] = {}
	end
end

function love.load()
	score = nil

	abilities = {
		q = Ability(
			1,
			function()
				local pos = camera.pos
						+ vec2(love.mouse.getX(), love.mouse.getY())
						- vec2(love.graphics.getWidth(), love.graphics.getHeight()) / 2

				local i = 1
				while i <= #enemies do
					if (pos - enemies[i].pos):length() < 50 then
						table.remove(enemies, i)
					else
						i = i + 1
					end
				end

				table.insert(processes.q, {
					time = 0,
					pos = pos
				})
			end,
			function(process)
				if process.time > 0.5 then
					removeProcess("q", process)
					return
				end
			end,
			function(process)
				love.graphics.setColor(255, 0, 0, math.mix(process.time / 0.5, 255, 0))
				love.graphics.circle("fill", process.pos.x, process.pos.y, 30)
			end
		),
		w = Ability(
			5,
			function()
				local pos = camera.pos
						+ vec2(love.mouse.getX(), love.mouse.getY())
						- vec2(love.graphics.getWidth(), love.graphics.getHeight()) / 2

				table.insert(processes.w, {
					time = 0,
					pos = pos
				})
			end,
			function(process)
				if process.time > 3.5 then
					removeProcess("w", process)
					return
				end

				for k, v in pairs(enemies) do
					if (v.pos - process.pos):length() <= 100 then
						v.stunned = true
					end
				end
			end,
			function(process)
				love.graphics.setColor(50, 255, 100, 255)
				love.graphics.circle("fill", process.pos.x, process.pos.y, 80)
			end
		)
	}

	reset()
end
 
function love.update(dt)
	camera.pos = camera.pos + (player.pos - camera.pos) / 64

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

	for k, v in pairs(abilities) do
		v.time = v.time + dt
		if love.keyboard.isDown(k) and v.cooldown <= v.time then
			v.triggerFn()
			v.time = 0
		end

		if processes[k] then
			for pk, pv in pairs(processes[k]) do
				pv.time = pv.time + dt
				v.processFn(pv)
			end
		end
	end

	for k, enemy in pairs(enemies) do
		if not enemy.stunned then
			local dir = (player.pos - enemy.pos):normalized()
			enemy.pos = enemy.pos + dir * 1.1
		end

		enemy.stunned = false
	end

	if love.keyboard.isDown("s") then
		player.move = nil
	end
	if love.mouse.isDown("r") then
		local pos = camera.pos
				+ vec2(love.mouse.getX(), love.mouse.getY())
				- vec2(love.graphics.getWidth(), love.graphics.getHeight()) / 2

		player.move = pos
	end

	if player.move then
		local step = 1
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
			Enemy(player.pos + vec2(math.cos(rand), math.sin(rand)) * 200)
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

	for ak, av in pairs(processes) do
		for pk, pv in pairs(av) do
			if abilities[ak].drawFn then
				abilities[ak].drawFn(pv)
			end
		end
	end

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
