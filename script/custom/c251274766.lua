--Amalgamate
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter2(c,e,tp,m,f)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,tp)
end
function s.fcheck(tp,sg,fc,mg)
	return sg:IsExists(Card.IsHasEffect,1,nil,id)
end
function s.subfilter(c)
    return c:IsPublic()
end
function s.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local mg1=Duel.GetFusionMaterial(tp)
		local e1,e2
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			local g=Duel.GetMatchingGroup(s.subfilter,tp,LOCATION_MZONE,0,nil)
			for tc in g:Iter() do
				mg1:AddCard(tc)
				e1=Effect.CreateEffect(tc)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
				e1:SetCondition(s.subcon)
				e1:SetReset(RESET_CHAIN)
				tc:RegisterEffect(e1)
				e2=Effect.CreateEffect(c)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(id)
				e2:SetReset(RESET_CHAIN)
				tc:RegisterEffect(e2)
				Fusion.CheckAdditional=s.fcheck
			end
		end
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil)
		Fusion.CheckAdditional=nil
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf)
			end
		end
		if e1 then e1:Reset() e2:Reset() end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	local exmat=false
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local g=Duel.GetMatchingGroup(s.subfilter,tp,LOCATION_MZONE,0,nil)
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(tc)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(s.subcon)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(tc)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(id)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			mg1:AddCard(tc)
		end
		exmat=true
	end
	if exmat then Fusion.CheckAdditional=s.fcheck end
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil)
	Fusion.CheckAdditional=nil
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then Fusion.CheckAdditional=s.fcheck end
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,tp)
			Fusion.CheckAdditional=nil
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,tp)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
