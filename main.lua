what = 'client'

require 'enet'
json = require 'json'

function love.load(args)
	host = enet.host_create()
	server = host:connect('localhost:8303')
end
 
function love.update(dt)
	local event = host:service()
	while event do
		if event.type == "receive" then
			local data = json.decode(event.data)
			
			if data.msg then
				print(data.msg)
			end

			if data.gamestr then
				game = loadstring(data.gamestr)()
				game:load()
			end
		end

		event = host:service()
	end

	if game then
		game:update(dt)
	end
end
 
function love.draw()
	if game then
		game:draw()
	end
end
