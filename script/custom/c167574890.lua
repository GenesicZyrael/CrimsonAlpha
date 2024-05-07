--The Grim Exodia Necross Incarnate
local s,id=GetID()
function s.initial_effect(c) 
	c:EnableReviveLimit()
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	--disable search
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	--reflect
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--Double damage
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e6:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e6)
	--special summon (grave)
	-- local e7=Effect.CreateEffect(c)
	-- e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	-- e7:SetType(EFFECT_TYPE_IGNITION)
	-- e7:SetRange(LOCATION_GRAVE)
	-- e7:SetCountLimit(1,{id,1})
	-- e7:SetCost(s.spcost)
	-- e7:SetTarget(s.sptg)
	-- e7:SetOperation(s.spop)
	-- c:RegisterEffect(e7)
	--to grave
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_TOGRAVE)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e8:SetOperation(s.tgop)
	c:RegisterEffect(e8)
end
s.listed_names={83240708}
s.listed_series={SET_FORBIDDEN_ONE}
function s.spcfilter(c,tp)
	return c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsAbleToDeckAsCost() and c:IsMonster() 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,e:GetHandler(),tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	end
end
function s.tgfilter(c,tp)
	return c:IsOriginalSetCard(SET_FORBIDDEN_ONE) and c:IsMonster()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE|LOCATION_HAND)>0 
			and Duel.GetFieldGroupCount(1-tp,0,LOCATION_MZONE|LOCATION_HAND)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,0,LOCATION_MZONE|LOCATION_HAND)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD|LOCATION_HAND)>0 
	local b2=Duel.GetFieldGroupCount(1-tp,0,LOCATION_ONFIELD|LOCATION_HAND)>0
	local b3=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil)
	if b1 and b2 then
		local g1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD|LOCATION_HAND,0,e:GetHandler())
		local g2=Duel.GetMatchingGroup(aux.TRUE,1-tp,LOCATION_ONFIELD|LOCATION_HAND,0,nil)
		local g3=g1
		g3:Merge(g2)
		if #g3>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=g1:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.SendtoGrave(sg,REASON_RULE,PLAYER_NONE,tp)
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
			sg=g2:Select(1-tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.SendtoGrave(sg,REASON_RULE,PLAYER_NONE,1-tp)
		end
	elseif not b3 then
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST,tp)
	end
end