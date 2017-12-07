what = "server"

require 'enet'
json = require 'json'

host = enet.host_create('localhost:8303')
local connections = {}
local running = true

do
	local gamefile = assert(io.open("games/circledodge.lua", "r"))
	gamestr = gamefile:read("*all")
	game = loadstring(gamestr)()
	gamefile:close()
end

while running do
	local event = host:service()

	if event then
		if event.type == 'connect' then
			connections[event.peer:index()] = 'connect'

			print("server:", event.peer:index(), "connects")

			event.peer:send(json.encode({msg = "connect"}))
			event.peer:send(json.encode({gamestr = gamestr}))


			--[[connections[event.peer:index()] = 'connect'
			print(event.peer:index(), connections[event.peer:index()])
			local str = json.encode({msg = "welcome little client dude"})
			print(str)
			event.peer:send(str)
			host:flush()
			print(0)
			
			content, size = love.filesystem.read("games/circledodge.lua")
			print(1)

			str = json.encode({game = content})
			print(str)
			event.peer:send(str)
		elseif event.type == 'receive' then
			if event.data.status then
				if event.data.status == 'game' then
					connections[event.peer:index()] = 'game'
					print(event.peer:index(), connections[event.peer:index()])
				end
			end]]
		end
	end
end
