local __file = file
local __io = io
local __os = os

local function __CheckRestorationActive()
	for _, mod in ipairs(BLT.Mods:Mods()) do
		if tostring(mod):find(" RestorationMod ") then
			return true
		end
	end

	return false
end

local function __CheckFolder()
	local using_restoration = __CheckRestorationActive()

	local __disable_this_when_using_restorationmod_file = "disable.this.when.using.restorationmod"
	local __enable_this_when_using_restorationmod_file = "enable.this.when.using.restorationmod"
	local __r_ext1 = Idstring(__disable_this_when_using_restorationmod_file):key()
	local __r_ext2 = Idstring(__enable_this_when_using_restorationmod_file):key()
	local __check_this_directory = {
		[[assets/mod_overrides/]],
		[[mods/]]
	}
	local BLT = rawget(_G, "BLT")
	local BLTPathToIndex = {}
	if BLT and BLT.Mods and BLT.Mods then
		for mod_index, mod in ipairs(BLT.Mods:Mods()) do
			BLTPathToIndex[Idstring(mod:GetPath()):key()] = mod_index
		end
	end

	for _, __dir in pairs(__check_this_directory) do
		if not __file.DirectoryExists(__dir) then
			goto LoopEnd
		end

		local __sub_dirs = __file.GetDirectories(__dir)

		if not type(__sub_dirs) == "table" then
			goto LoopEnd
		end

		for _, __dir_s in pairs(__sub_dirs) do
			if not type(__dir_s) == "string" and __file.DirectoryExists(__dir .. __dir_s .. "/") then
				goto SubLoopEnd
			end

			local this_dir = __dir .. __dir_s .. "/"

			-- disable_this_when_using_restorationmod
			if __io.file_is_readable(__dir .. __dir_s .. "/" .. __disable_this_when_using_restorationmod_file) or __io.file_is_readable(__dir .. __dir_s .. "/" .. __disable_this_when_using_restorationmod_file .. ".txt") then
				--Disable
				if (using_restoration) then
					__os.rename(this_dir .. "mod.txt", this_dir .. "mod." .. __r_ext1)
					__os.rename(this_dir .. "main.xml", this_dir .. "main." .. __r_ext1)
					__os.rename(this_dir .. "supermod.xml", this_dir .. "supermod." .. __r_ext1)
					__os.rename(this_dir .. "hooks.xml", this_dir .. "hooks." .. __r_ext1)
					-- Remove from Mod List
					if type(BLTPathToIndex[Idstring(this_dir):key()]) == "number" then
						table.remove(BLT.Mods.mods, BLTPathToIndex[Idstring(this_dir):key()])
					end
				--Enable
				else
					__os.rename(this_dir .. "mod." .. __r_ext1, this_dir .. "mod.txt")
					__os.rename(this_dir .. "main." .. __r_ext1, this_dir .. "main.xml")
					__os.rename(this_dir .. "supermod." .. __r_ext1, this_dir .. "supermod.xml")
					__os.rename(this_dir .. "hooks." .. __r_ext1, this_dir .. "hooks.xml")
				end
			end

			-- enable_this_when_using_restorationmod
			if __io.file_is_readable(__dir .. __dir_s .. "/" .. __enable_this_when_using_restorationmod_file) or __io.file_is_readable(__dir .. __dir_s .. "/" .. __enable_this_when_using_restorationmod_file .. ".txt") then
				--Enable
				if (using_restoration) then
					__os.rename(this_dir .. "mod." .. __r_ext2, this_dir .. "mod.txt")
					__os.rename(this_dir .. "main." .. __r_ext2, this_dir .. "main.xml")
					__os.rename(this_dir .. "supermod." .. __r_ext2, this_dir .. "supermod.xml")
					__os.rename(this_dir .. "hooks." .. __r_ext2, this_dir .. "hooks.xml")
				--Disable
				else
					__os.rename(this_dir .. "mod.txt", this_dir .. "mod." .. __r_ext2)
					__os.rename(this_dir .. "main.xml", this_dir .. "main." .. __r_ext2)
					__os.rename(this_dir .. "supermod.xml", this_dir .. "supermod." .. __r_ext2)
					__os.rename(this_dir .. "hooks.xml", this_dir .. "hooks." .. __r_ext2)
					--Remove from Mod List
					if type(BLTPathToIndex[Idstring(this_dir):key()]) == "number" then
						table.remove(BLT.Mods.mods, BLTPathToIndex[Idstring(this_dir):key()])
					end
				end
			end
			:: SubLoopEnd ::
		end
		:: LoopEnd ::
	end
end

if MenuManager then
	Hooks:Add("MenuManagerOnOpenMenu", "DisableEnableModsRestoration0", function(self, menu, ...)
		if menu == "menu_main" then
			local success, err = blt.pcall(__CheckFolder)
			if not success then
				log("Disable mods error " .. err)
				-- Print("Error! " .. tostring(err)) -- DEBUG
			end
		end
	end)
end
