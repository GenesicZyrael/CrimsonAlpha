-- Ritual Beast Barrier
-- When a Spell/Trap Card, or monster effect, is activated: You Banish 1 "Ritual Beast" card in your GY; negate the activation, and if you do, banish it face-down. If this card is banished from your GY: You can return 5 "Ritual Beast" cards into the Deck, from among your cards that are banished cards and/or in the GY, except "Ritual Beast Barrier"; Draw 1 card. You can only use 1 "Ritual Beast Barrier" effect per turn, and only once that turn.
local s,id=GetID()
function s.initial_effect(c)
	--Activate(effect)
	local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_CHAINING)
		e1:SetCountLimit(1,id)
		e1:SetCondition(s.ActCond)
		e1:SetCost(s.ActCost)
		e1:SetTarget(s.ActTarg)
		e1:SetOperation(s.ActOp)
	c:RegisterEffect(e1)
	--Banish(effect)
	local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_REMOVE)
		e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		e2:SetCountLimit(1,id)
		e2:SetCondition(s.BanCon)
		e2:SetCost(s.BanCost)
		e2:SetTarget(s.BanTarg)
		e2:SetOperation(s.BanOp)
	c:RegisterEffect(e2)
end
s.listed_series={0xb5,0x30b5}
-- {Activate Effect: Negate Activation}
function s.CostFilter(c)
	return c:IsSetCard(0xb5) 
		and c:IsAbleToRemoveAsCost()
end
function s.ActCond(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function s.ActCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.CostFilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.CostFilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.ActTarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,re:GetHandler():GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,re:GetHandler():GetPreviousLocation())
	end
end
function s.ActOp(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT)
	end
end
-- {Graveyard Effect: Shuffle 5, Draw 1}
function s.BanCon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
function s.BanCostFilter(c)
	return c:IsSetCard(0xb5) 
		and c:IsAbleToDeckOrExtraAsCost()
		and not c:IsCode(id)
end
function s.BanCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.BanCostFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.BanCostFilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,5,nil)
	Duel.SendtoDeck(g,nil,5,REASON_COST)
end
function s.BanTarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.BanOp(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end