 --CCG: Ritual Beast Ulti-Cannafalco
-- 1 Tuner + 1+ non-Tuner "Gusto" monsters, including at least 1 Synchro Monster
-- (This card is also treated as a "Gusto" card). Must either be Synchro Summoned, or Special 
-- Summoned (from your Extra Deck) by banishing 3 cards you control (1 "Ritual Beast Tamer", 1 "Spiritual Beast", 
-- and 1 "Ritual Beast Ulti-") If this card was Special Summoned from the Extra Deck, except with a card effect, this
-- card gains this effect.
-- ● When a monster(s) would be Special Summoned (Quick Effect): You can discard 1 "Gusto" or "Ritual Beast"
-- card from your hand to the GY; negate the Special Summon, and if you do, destroy that monster(s).
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Synchro Summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(Card.IsSetCard,0x10),1,99,nil,nil,nil,s.matfilter)
	-- Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(1)
	e2:SetCondition(s.SpCon)
	e2:SetTarget(s.SpTg)
	e2:SetOperation(s.SpOpe)
	c:RegisterEffect(e2)
	-- Negate Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.EffCon)
	e3:SetOperation(s.EffOpe)
	c:RegisterEffect(e3)
	--spsummon condition
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e4)
	-- local r1=Effect.CreateEffect(c)
		-- r1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
		-- r1:SetDescription(aux.Stringid(id,0))
		-- r1:SetType(EFFECT_TYPE_QUICK_O)
		-- r1:SetRange(LOCATION_MZONE)
		-- r1:SetCode(EVENT_SPSUMMON)
		-- --r1:SetCountLimit(1)
		-- --r1:SetCountLimit(1,id)
		-- r1:SetCondition(s.NegCon)
		-- r1:SetCost(s.NegCost)
		-- r1:SetTarget(s.NegTarg)
		-- r1:SetOperation(s.NegOpe)
	-- c:RegisterEffect(r1)
end
-- {Synchro Material Check: ... including at least 1 Synchro Monster}
function s.matfilter(g,sc,tp)
	return g:IsExists(s.cfilter,1,nil)
end
function s.cfilter(c)
	return c:IsType(TYPE_SYNCHRO)
end
-- {Special Summon Proc: Pseudo-Contact Fusion}
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) 
		and sg:IsExists(s.chk,1,nil,sg)
end
function s.chk(c,sg)
	return c:IsSetCard(0x40b5) 
		and sg:IsExists(Card.IsSetCard,1,c,0x10b5)
		and sg:IsExists(Card.IsSetCard,1,c,0x20b5)
end
function s.spfilter1(c)
	return c:IsSetCard(0xb5) 
		and c:IsAbleToRemoveAsCost()
end
function s.SpCon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_ONFIELD,0,nil)
	local g1=rg:Filter(Card.IsSetCard,nil,0x40b5)
	local g2=rg:Filter(Card.IsSetCard,nil,0x10b5)
	local g3=rg:Filter(Card.IsSetCard,nil,0x20b5)
	local g=g1:Clone()
	g:Merge(g2)
	g:Merge(g3)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #g1>0 and #g2>0 and #g3>0 and #g>2 
		and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
end
function s.SpTg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_ONFIELD,0,nil)
	local g1=rg:Filter(Card.IsSetCard,nil,0x40b5)
	local g2=rg:Filter(Card.IsSetCard,nil,0x10b5)
	local g3=rg:Filter(Card.IsSetCard,nil,0x20b5)
	g1:Merge(g2)
	g1:Merge(g3)
	local sg=aux.SelectUnselectGroup(g1,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #sg>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.SpOpe(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end
-- {Effect Gain: Negate Summon}
function s.EffCon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
		or e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function s.EffOpe(e,tp,eg,ep,ev,re,r,rp)
	local r1=Effect.CreateEffect(e:GetHandler())
		r1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
		r1:SetDescription(aux.Stringid(id,0))
		r1:SetType(EFFECT_TYPE_QUICK_O)
		r1:SetRange(LOCATION_MZONE)
		r1:SetCode(EVENT_SPSUMMON)
		--r1:SetCountLimit(1)
		--r1:SetCountLimit(1,id)
		r1:SetCondition(s.NegCon)
		r1:SetCost(s.NegCost)
		r1:SetTarget(s.NegTarg)
		r1:SetOperation(s.NegOpe)
	e:GetHandler():RegisterEffect(r1)
	local r2=r1:Clone()
		r2:SetDescription(aux.Stringid(97836203,1))
		r2:SetCode(EVENT_FLIP_SUMMON)
	e:GetHandler():RegisterEffect(r2)
	local r3=r1:Clone()
		r3:SetDescription(aux.Stringid(id,2))
		r3:SetCode(EVENT_SUMMON)
	e:GetHandler():RegisterEffect(r3)
	-- -- Activate(effect)
	--local r4=Effect.CreateEffect(e:GetHandler())
	--	r4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	--	r4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	--	r4:SetType(EFFECT_TYPE_ACTIVATE)
	--	r4:SetCode(EVENT_CHAINING)
	--	r4:SetCondition(s.NegCon2)
	--	r4:SetCost(s.NegCost)
	--	r4:SetTarget(s.NegTarg2)
	--	r4:SetOperation(s.NegOpe2)
	--e:GetHandler():RegisterEffect(r4)
end
-- {Monster Effect: Negate Summon}
function s.NegCon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
end
function s.filter(c)
	return c:IsSetCard(0xb5) or c:IsSetCard(0x10)
		and c:IsAbleToGraveAsCost()
end
function s.NegCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.NegTarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
function s.NegOpe(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end
-- {Monster Effect: Negate Effect to Summon}
function s.NegCon2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON)
end
function s.NegTarg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.NegOpe2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end