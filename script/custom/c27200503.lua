--Spiritual Beast Falco
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--Normal Summon itself from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	-- e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.sumcost)
	e1:SetTarget(s.sumtarg)
	e1:SetOperation(s.sumope)
	c:RegisterEffect(e1)
	-- --Special Summon
	-- -- local e1=Effect.CreateEffect(c)
	-- -- e1:SetType(EFFECT_TYPE_FIELD)
	-- -- e1:SetCode(EFFECT_SPSUMMON_PROC)
	-- -- e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	-- -- e1:SetRange(LOCATION_HAND)
	-- -- e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	-- -- e1:SetCondition(s.spcon)
	-- -- c:RegisterEffect(e1)
	--token
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.tkncon)
	e2:SetTarget(s.tkntg)
	e2:SetOperation(s.tknop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_series={SET_RITUAL_BEAST,SET_RITUAL_BEAST_TAMER}
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.sumtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsSummonable(true,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,e:GetHandler(),1,0,0)
end
function s.sumope(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Summon(tp,c,true,nil)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0,nil)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.tkncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
function s.tkntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,27200530,0,0x4011,200,1000,2,RACE_PSYCHIC,ATTRIBUTE_WIND) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.tknop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,27200530,SET_RITUAL_BEAST_TAMER,0x4011,200,1000,2,RACE_PSYCHIC,ATTRIBUTE_WIND) then
			local token=Duel.CreateToken(tp,27200530)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			token:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			token:RegisterEffect(e2,true)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			e3:SetValue(s.matlimit)
			token:RegisterEffect(e3,true)
			local e4=e3:Clone()
			e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			token:RegisterEffect(e4,true)
			local e5=e3:Clone()
			e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			token:RegisterEffect(e5,true)
			local e6=e3:Clone()
			e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			token:RegisterEffect(e6,true)			
			Duel.SpecialSummonComplete()
	end
end
function s.matlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(SET_RITUAL_BEAST)
end
