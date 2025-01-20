# CrimsonAlpha 

Download CrimsonAlpha repo
> Go to "./config"
> Create a new .json and name it user_configs.json
> add the ff text:
{
	"repos": [
		{
			"url": "https://github.com/GenesicZyrael/CrimsonAlpha",
			"repo_name": "Crimson Alpha updates",
			"repo_path": "./repositories/crimson-alpha",
			"has_core": true,
			"core_path": "bin",
			"data_path": "",
			"script_path": "script",
			"should_update": true,
			"should_read": true
		}
	]
}

Alternatively, you can just copy-paste the user_configs.json here to your /config folder

=============================================================================================

Then, in the root folder, 
> Create the file and name it "init.lua"
> add the text below

	-- initialize script extensions
	Duel.LoadScript ("crimson_alpha.lua")

Alternatively, you can just copy-paste the init.lua here to your root folder

