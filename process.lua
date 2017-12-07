local Process = {}

Process.processes = {}

function Process:indexOf(process)
	for i=1, #Process.processes, 1 do
		if Process.processes[i] == process then
			return i
		end
	end

	return nil
end

function Process:isRunning(process)
	if Process:indexOf(process) then
		return true
	end
	return false
end

function Process:remove(process)
	local index = Process:indexOf(process)
	if Process.processes[index].endFn then
		Process.processes[index].endFn(Process.processes[index])
	end
	if index then
		table.remove(Process.processes, index)
	end
end

function Process:update(dt)
	for i=#self.processes, 1, -1 do
		local process = Process.processes[i]

		process.time = process.time + dt
		if process.updateFn then
			process.updateFn(process, dt)
		end

		if process.duration and process.duration < process.time then
			if process.endFn then
				process.endFn(process)
			end
			table.remove(Process.processes, i)
		end
	end
end

function Process:draw()
	for k, process in pairs(self.processes) do
		if process.drawFn then
			process.drawFn(process)
		end
	end
end

do
	local meta = {}

	function meta:__call(duration, time, data, updateFn, drawFn, endFn)
		local process = data or {}
		process.duration = duration
		process.time = time or 0
		process.updateFn = updateFn
		process.drawFn = drawFn
		process.endFn = endFn
		return process
	end

	setmetatable(Process, meta)
end

return Process
