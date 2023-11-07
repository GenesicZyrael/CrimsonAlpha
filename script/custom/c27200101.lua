--Noellia, Sacred Spirit of the Nekroz
Duel.LoadScript ("crimson_alpha.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2,s.lcheck)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Ritual From Deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NEKROZ}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_NEKROZ,lc,sumtype,tp) or g:IsExists(Card.IsType,1,nil,TYPE_RITUAL,lc,sumtype,tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.thfilter(c)
	return c:IsRitualSpell() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,CUSTOM_RITUAL_LOCATION)~=0 then return end
	Duel.RegisterFlagEffect(tp,CUSTOM_RITUAL_LOCATION,RESET_PHASE+PHASE_END,0,1,LOCATION_DECK)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,CUSTOM_RITUAL_LOCATION)~=0 then return end
	Duel.RegisterFlagEffect(tp,CUSTOM_RITUAL_LOCATION,RESET_PHASE+PHASE_END,0,1,LOCATION_DECK)
	local ge1=Effect.CreateEffect(e:GetHandler())
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ge1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	ge1:SetTargetRange(1,0)
	ge1:SetTarget(s.splimit)
	ge1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ge1,tp)
	aux.RegisterClientHint(e:GetHandler(),EFFECT_FLAG_OATH,tp,1,0,aux.Stringid(id,2),nil)
	--lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp)
end
	--Cannot special summon from extra deck
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(SET_NEKROZ) and c:IsLocation(LOCATION_EXTRA)
end
