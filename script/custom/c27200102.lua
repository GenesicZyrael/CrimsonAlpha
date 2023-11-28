--Nekroz of Mind Augus
Duel.LoadScript ("crimson_alpha.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,99,s.lcheck)
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.econ)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--Linked immunity
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--Ritual Summon
	local e3=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUAL,desc=aux.Stringid(id,1)})
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.ritcost)
	c:RegisterEffect(e3)
	--to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)	
	-- --Ritual From Deck
	-- local e2=Effect.CreateEffect(c)
	-- e2:SetDescription(aux.Stringid(id,1))
	-- e2:SetType(EFFECT_TYPE_FIELD)
	-- e2:SetCode(id)
	-- e2:SetRange(LOCATION_MZONE)
	-- e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	-- e2:SetTargetRange(1,0)
	-- e2:SetCondition(s.ritcon)
	-- c:RegisterEffect(e2)
	-- local e3=e2:Clone()
	-- e3:SetType(EFFECT_TYPE_SINGLE)
	-- e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	-- c:RegisterEffect(e3)
	-- --to hand
	-- local e4=Effect.CreateEffect(c)
	-- e4:SetDescription(aux.Stringid(id,0))
	-- e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	-- e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- e4:SetProperty(EFFECT_FLAG_DELAY)
	-- e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- e4:SetRange(LOCATION_MZONE)
	-- e4:SetCountLimit(1)
	-- e4:SetCondition(s.thcon)
	-- e4:SetTarget(s.thtg)
	-- e4:SetOperation(s.thop)
	-- c:RegisterEffect(e4)	
	-- --Destroy 1 card on the field
	-- local e5=Effect.CreateEffect(c)
	-- e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	-- e5:SetType(EFFECT_TYPE_QUICK_O)
	-- e5:SetCode(EVENT_FREE_CHAIN)
	-- e5:SetRange(LOCATION_MZONE)
	-- e5:SetCountLimit(1,id)
	-- e5:SetCondition(s.condition)	
	-- e5:SetCost(s.cost)
	-- e5:SetTarget(s.target)
	-- e5:SetOperation(s.operation)
	-- e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- c:RegisterEffect(e5)	
end
s.listed_series={SET_NEKROZ}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_NEKROZ,lc,sumtype,tp)
end
function s.econ(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_RITUAL) and te:IsActiveType(TYPE_MONSTER)
end
function s.indtg(e,c)
	return c:IsFaceup() and e:GetHandler():GetLinkedGroup():IsContains(c)
end


function s.ritcon(e)
	return e:GetHandler():GetFlagEffect(id)==0
end
function s.cfilter(c)
	return c:IsAbleToRemoveAsCost()
end
function s.ritcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end


function s.seqcfilter(c,tp,lg)
	return c:IsType(TYPE_RITUAL) and lg:IsContains(c)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(s.seqcfilter,1,nil,tp,lg)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

-- function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- return Duel.GetTurnPlayer()~=tp
-- end
-- function s.filter(c)
	-- return c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(false,true,true)~=nil
-- end
-- function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- e:SetLabel(1)
	-- return true
-- end
-- function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- if chkc then
		-- local te=e:GetLabelObject()
		-- local tg=te:GetTarget()
		-- return tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	-- end
	-- if chk==0 then
		-- if e:GetLabel()==0 then return false end
		-- e:SetLabel(0)
		-- return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
	-- end
	-- e:SetLabel(0)
	-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- local te=g:GetFirst():CheckActivateEffect(false,true,true)
	-- e:SetLabelObject(te)
	-- Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- e:SetProperty(te:GetProperty())
	-- local tg=te:GetTarget()
	-- if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- Duel.ClearOperationInfo(0)
-- end
-- function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- local te=e:GetLabelObject()
	-- if not te then return end
	-- local op=te:GetOperation()
	-- if op then op(e,tp,eg,ep,ev,re,r,rp) end
-- end
