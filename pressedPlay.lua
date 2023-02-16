local modulelol = {}

-- This will run in the second project we launch from this one.
modulelol.secondary_main_dot_lua = [[
function love.draw()
	love.graphics.rectangle('fill',10,10,100,100)
end
]]

modulelol.secondary_conf_dot_lua = [[
function love.conf(t)
    t.window.width = 500
    t.window.height = 500
end
]]

function modulelol.load(arg, morearg)
	-- No conf.lua, so we set the identity here.
	love.filesystem.setIdentity('AAAAA')

	-- Get the save directory path.
	local savpath = love.filesystem.getSaveDirectory()

	if love.filesystem.isFused() then
		-- FUSED

		-- Get the path to the fused executable.
		local exepath = love.filesystem.getSourceBaseDirectory()

		-- Copy non-fused love.exe to save directory from the fused executable. - Assume that you have a copy of love.exe inside your .love file... most inefficient
		love.filesystem.write('lovec.exe', love.filesystem.newFileData('lovec.exe'))

		-- Create secondary project's main.lua file in the save directory.
		love.filesystem.write('main.lua', modulelol.secondary_main_dot_lua)
        love.filesystem.write('conf.lua', modulelol.secondary_conf_dot_lua)

		-- Since we can mount the fused executable's path, we don't need to duplicate the dll-s, just copy from there. - the executable can't be copied itself, because it's fused with the project; it CAN NOT open another project due to that taking priority.
		local success = love.filesystem.mount(exepath, "temp")
		if not success then error("Could not mount source base dir.") end
		local files = love.filesystem.getDirectoryItems("temp")
		for i,file in ipairs(files) do
			if love.filesystem.isFile("temp/"..file) and file:match("^.+(%..+)$") == '.dll' then
				love.filesystem.write(file, love.filesystem.newFileData("temp/"..file))
			end
		end
		love.filesystem.unmount("temp")

		-- Needs an extra set of ""-s outside of the ones that go around the two paths!
		io.popen('""' .. savpath .. '/lovec.exe" "' .. savpath .. '/.""')
	else
		-- NOT FUSED

		-- Create secondary project's main.lua file in the save directory.
		love.filesystem.write('main.lua', modulelol.secondary_main_dot_lua)
        love.filesystem.write('conf.lua', modulelol.secondary_conf_dot_lua)

		-- We can use the internal path to the used executable to execute another project; no file copying needed.
		io.popen('""' .. morearg[-2] .. '" "' .. savpath .. '/.""')
	end
end

function love.draw()
	love.graphics.circle('fill',10,10,100)
end

return modulelol