 --Shaddoll Core Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1,id)
		e1:SetTarget(s.target)
		e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsSetCard(0x9d) 
		and c:IsAbleToGrave()
end
function s.filter1(c,e)
	return c:IsOnField() 
		and c:IsAbleToRemove() 
		and not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf,g)
	return c:IsType(TYPE_FUSION) 
		and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) 
		and c:CheckFusionMaterial(m,nil,tp)
		and #g>0 
		and g:IsExists(s.filter4,1,nil,m,c,chkf)
end
function s.filter3(c)
	return c:IsType(TYPE_MONSTER) 
		and c:IsCanBeFusionMaterial() 
		and c:IsAbleToRemove()
end
function s.filter4(c,m,fusc,chkf)
	return fusc:CheckFusionMaterial(m,c,chkf)
end
function s.tgfilter(c,tp)
	return c:IsSetCard(0x9d) 
		and c:IsAbleToGrave() 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
		Duel.BreakEffect()
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
			local mg2=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
			mg1:Merge(mg2)
		end
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf,mg1:Filter(Card.IsSetCard,nil,0x9d))
		-- Debug.Message(sg1:GetCount())
		local mg3=nil
		local sg2=nil
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg3=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf,mg3:Filter(Card.IsSetCard,nil,0x9d))
		end
		if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(27200401,0)) then
			Duel.BreakEffect()
			local sg=sg1:Clone()
			-- Debug.Message(sg1:GetCount())
			if sg2 then sg:Merge(sg2) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				local g=mg1:Filter(Card.IsSetCard,nil,0x9d):FilterSelect(tp,s.filter4,1,1,nil,mg1,tc,chkf)
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,g,tp)
				tc:SetMaterial(mat1)
				Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,tp)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
			local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_ADD_SETCODE)
				e1:SetValue(0x9d)
				e1:SetReset(RESET_EVENT+0x1fe0000)
			tc:RegisterEffect(e1)
		end
	end
end
