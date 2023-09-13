--Naturia Tamer Zefrawendi
-- [ Pendulum Effect ]
-- You cannot Pendulum Summon monsters, except "Naturia" and "Zefra" monsters. This effect cannot be negated. Your opponent cannot activate cards and effects in response to the activation of a card or effect in your Pendulum Zone, or the activation of your Pendulum Summoned monster's effects.
-- ----------------------------------------
-- [ Monster Effect ]
-- When this card is Normal or Pendulum Summoned: You can target 1 "Naturia" or "Zefra" card in your GY; add it to your hand. If this card on the field is sent to the Extra Deck: You can activate this effect; add this card to your hand during your next Standby Phase, then place 1 card from your hand on top of your Deck. You can only use each effect of "Naturia Tamer Zefrawendi" once per turn.

-- Changelogs --
-- 12/01/2021 - Removed the effect that returns itself to the hand. Reason: Nerf
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--splimit
	local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetRange(LOCATION_PZONE)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
		e2:SetTargetRange(1,0)
		e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	--act limit
	local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAINING)
		e3:SetRange(LOCATION_PZONE)
		e3:SetOperation(s.chainop)
	c:RegisterEffect(e3)	
	--add to hand
	local e4=Effect.CreateEffect(c)
		e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e4:SetCode(EVENT_SUMMON_SUCCESS)
		e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e4:SetCountLimit(1,{id,0})
		e4:SetTarget(s.thtg)
		e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
		e5:SetCode(EVENT_SPSUMMON_SUCCESS)
		e5:SetCondition(s.thcon)
	c:RegisterEffect(e5)	
	--return to hand
	-- local e6=Effect.CreateEffect(c)
		-- e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		-- e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		-- e6:SetCode(EVENT_LEAVE_FIELD)
		-- e6:SetCountLimit(1,{id,1})
		-- e6:SetCondition(s.regcon)
		-- e6:SetOperation(s.regop)
	-- c:RegisterEffect(e6)	
end
s.listed_series={0x2a,0xc4}
-- {Pendulum Summon Restriction: Zefra & Constellar}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x2a) or c:IsSetCard(0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if (re:IsActiveType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_PENDULUM)) or (rc:IsLocation(LOCATION_PZONE)) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.thfilter(c,e,tp)
	return (c:IsSetCard(0x2a) or c:IsSetCard(0xc4)) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_EXTRA) 
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_EXTRA)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetCondition(s.thrcon)
		e1:SetOperation(s.throp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		c:RegisterEffect(e1)
	end
end
function s.thrcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetTurnPlayer()==tp and c:IsAbleToHand()
end
function s.throp(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SendtoHand(c,nil,REASON_EFFECT) then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
