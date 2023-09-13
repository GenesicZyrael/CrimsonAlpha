--Ascension of the Destruction Swordsmaster
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(aux.IsMaterialListCode,78193831),nil,s.fextra,nil,nil,s.stage2)
	e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
end
s.listed_names={78193831}
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
function s.fextra(e,tp,mg)
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsCode),tp,LOCATION_DECK,0,nil,78193831)
	end
	return nil
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(78193831)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetTargetRange(1,1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local c=e:GetHandler()
		c:SetCardTarget(tc)
		--Cannot Special Summon from the Extra Deck, except monsters that specifically list "Buster Blader" in its text
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e3:SetTargetRange(1,0)
		e3:SetTarget(s.splimit)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
		--Clock Lizard check
		aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsCode(78193831) and not c.listed_names==78193831 and not aux.IsMaterialListCode(c,78193831) end)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsCode(78193831) 
		   and not c.listed_names==78193831
		   and not aux.IsMaterialListCode(c,78193831)
end