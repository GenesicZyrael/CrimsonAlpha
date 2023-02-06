# CrimsonAlpha 

Download CrimsonAlpha repo
> Go to "./config"
> Open the configs.json
> add the text below under the "repos":[] segment

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
		},

Then, in the root folder, 
> Create the file and name it "init.lua"
> add the text below

	-- initialize script extensions
	Duel.LoadScript ("crimson_alpha.lua")
