--Custom Archtypes
if not CustomArchetype then
	CustomArchetype = {}
	
	local MakeCheck=function(setcodes,archtable,extrafuncs)
		return function(c,sc,sumtype,playerid)
			sumtype=sumtype or 0
			playerid=playerid or PLAYER_NONE
			if extrafuncs then
				for _,func in pairs(extrafuncs) do
					if Card[func](c,sc,sumtype,playerid) then return true end
				end
			end
			if setcodes then
				for _,setcode in pairs(setcodes) do
					if c:IsSetCard(setcode,sc,sumtype,playerid) then return true end
				end
			end
			if archtable then
				if c:IsSummonCode(sc,sumtype,playerid,table.unpack(archtable)) then return true end
			end
			return false
		end
	end


	CustomArchetype.Shinobird={66815913,92200612,39817919,73055622,9553721,276357,8066523
	}
	Card.IsShinobird=MakeCheck({SET_SHINOBIRD},CustomArchetype.Shinobird)

	CustomArchetype.Metalmorph={68540059,504700111,12503902,504700017,511006005}
	Card.IsMetalmorph=MakeCheck({SET_METALMORPH},CustomArchetype.Metalmorph)

	CustomArchetype.Guardragon={11012154,35183584,6990577,43411769,79905468,84899094,95793022,
	59537380,13143275,86148577,40003819,87571563,50186558,47393199,11908584}
	Card.IsGuardragon=MakeCheck({SET_GUARDRAGON},CustomArchetype.Guardragon)
	
	CustomArchetype.WNebula={90075978}
	Card.IsWNebula=MakeCheck({SET_W_NEBULA},CustomArchetype.WNebula)
end

