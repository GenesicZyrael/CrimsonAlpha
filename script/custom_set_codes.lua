--Custom Archtype
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

end

