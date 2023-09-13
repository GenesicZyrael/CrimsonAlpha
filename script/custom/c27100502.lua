 --Wynn, Charmer of Gusto
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetCode(EVENT_TO_GRAVE)
		e1:SetCountLimit(1,{id,0})
		-- e1:SetCondition(s.cond)
		e1:SetTarget(s.target)
		e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={27980138}
s.listed_series={0x10}
function s.cond(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end
function s.filter(c,e,tp)
	return (c:IsCode(27980138) or c:IsSetCard(0x10)) 
		and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and (c:IsSSetable() and c:IsAbleToHand())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then sft=sft-1 end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local b1,b2,op
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) then return end
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.SSet(tp,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		if tc:GetFirst():IsType(TYPE_QUICKPLAY) then
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		elseif  tc:GetFirst():IsType(TYPE_TRAP) then
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		end
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:GetFirst():RegisterEffect(e1)
	else
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end