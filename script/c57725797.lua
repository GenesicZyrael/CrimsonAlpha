--Descend! Elemental HERO Terra Firma!
--(This card's name is always treated as "Polymerization".)
--Fusion Summon 1 "Elemental HERO Terra Firma" from your Extra Deck, using monsters from your hand, field or Deck as Fusion Materials, and if you do, it cannot be targeted or be destroyed by your opponent's card effects. Neither player can activate cards or effects in response to this card's activation. You cannot Special Summon monsters from the Extra Deck, except Fusion Monsters, during the turn you activate this card. You can only activate 1 "Descend! Elemental HERO Terra Firma!" once per turn.
local s,id=GetID()
function s.initial_effect(c)
	c:AddSetcodesRule(0x3008)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsCode,74711057),nil,s.fextra,nil,nil,s.stage2)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_names={74711057}
function s.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA or c:IsType(TYPE_FUSION)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		local c=e:GetHandler()
		--Cannot be destroyed by card effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3001)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(s.indval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		--cannot target
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3002)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SINGLE_RANGE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetValue(aux.tgoval)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
end
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
