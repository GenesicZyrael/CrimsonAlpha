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
	
	
	
ID Ruling for non-Archetype cards
	27AAAABBBB
		27  - Custom Card Set Number for CrimsonAlpha = 27
		AAAA - Year
		BBBB - Sequence

ID Ruling for Official Archetypes
	27AAABBBCC - Pattern 1 for 3-Digit Archetypes
	27AAAABBCC - Pattern 2 for 4-Digit Archetypes 
	27AAAAABCC - Pattern 3 for 5-Digit Archetypes 
		27  - Custom Card Set Number for CrimsonAlpha = 27
		A* - Archetype 
		B* - Padding value: 0
		CC - Sequence
		
		* If the card is under more than 2 Archetypes, then only the 1st one will be registered in the ID
			* e.g.: "Possessed Spirit Art - Kaijo" is both under Possessed and Spirtual Art archetypes.
			Due to it's archetype ordering however, with "Possessed" taking precedence over the "Spiritual Art" archetype, 
			the card would get an card ID with the "Possessed" (0xc0) = 192 archetype ID, becoming 2719200001.
			If "Spiritual Art" (0x14d) = 333 was registered first, then it's ID will 2733300001 instead.
			
		* A* = the converted HEX value of the super archetype to DEC
			* e.g.: 
				"Ritual Beast Ulti-" (0x40b5) = 16565
				"Spiritual Beast" (0x20b5) = 8373
				"Ritual Beast Tamer" (0x10b5) = 4277
				
				should all be just under Ritual Beast(0xb5) = 181 for simplicity's sake.
			
				* "Spiritual Beast Falco's" ID would be 2718100001 instead of 2716565001
				* "Ritual Beast Ulti-Cannafalcos'" ID would be 2718100002 instead of 2783730001
				* "Ritual Beast Training's" ID would be 2718100003
