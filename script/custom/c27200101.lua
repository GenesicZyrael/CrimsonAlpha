--Noellia, Sacred Spirit of the Nekroz
Duel.LoadScript ("crimson_alpha.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2)
	--Ritual From Deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,CUSTOM_RITUAL_LOCATION)~=0 then return end
	Duel.RegisterFlagEffect(tp,CUSTOM_RITUAL_LOCATION,RESET_PHASE+PHASE_END,0,1,LOCATION_DECK)
end
