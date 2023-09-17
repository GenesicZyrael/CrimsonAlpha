--ラーの使徒
--Ra's Disciple
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--tribute limit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UNRELEASABLE_SUM)
	e5:SetValue(s.sumval)
	c:RegisterEffect(e5)
	--summon limit
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(1,0)
	e6:SetTarget(s.splimit)
	c:RegisterEffect(e6)
end
s.listed_names={id,CARD_RA,10000020,10000000}

--- Custom ---
function s.chkfieldlimit(e,tp,max)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_MZONE,0,nil)
	local ct=#g
	if Duel.IsExistingMatchingCard(aux.CheckEffectUniqueCheck,tp,LOCATION_MZONE,0,1,nil,tp,id) then
		return true,ct
	end
	return false,ct
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(2)(sg,e,tp,mg) --and sg:IsExists(s.chk,1,nil,sg,tp)
end
-- function s.chk(c,sg,tp)
	-- local chkfld=s.chkfieldlimit(e,tp,3)
	-- if chkfld~=true then return aux.TRUE end
	-- local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_MZONE,0,nil)
	-- if #g>1 then
		-- return sg:IsExists(Card.IsHasEffect,1,c,EFFECT_UNIQUE_CHECK) 
			-- --and not sg:IsExists(Card.GetFlagEffect,1,c,CUSTOM_REGISTER_LIMIT)
	-- end
	-- return sg:IsExists(Card.IsCode,1,c,id) 
-- end
--------------
function s.filter(c,e,tp)
	--- Custom ---
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_MZONE,0,nil)
	local cond=c:IsCode(id)
	if #g>2 then cond=c:IsOriginalCode(id) end
	--------------
	return cond and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	--- Custom ---
	local chkfld,ct=s.chkfieldlimit(e,tp,3)
	if chkfld==true and ct<2 then return end
	--------------
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	--- Custom ---
	local chkfld,ct=s.chkfieldlimit(e,tp,3)
	if chkfld==true and ct>=2 then 
		ft=3-ct
	elseif chkfld==false and ct>=2 then 
		ft=1	-- workaround 
	end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,ft,nil,e,tp)
	-- if ft<2 then
		-- sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,ft,nil,e,tp)
	-- else
		-- local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
		-- sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon,1,tp,HINTMSG_SPSUMMON,nil,nil,false)
	-- end
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
	end
	--------------
end
function s.sumval(e,c)
	return not c:IsCode(10000000,CARD_RA,10000020)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not se:GetHandler():IsCode(id)
end
