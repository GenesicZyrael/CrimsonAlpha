--影霊衣の万華鏡
--Nekroz Kaliedoscope
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	if not s.ritual_matching_function then
		s.ritual_matching_function={}
	end
	s.ritual_matching_function[c]=aux.FilterEqualFunction(Card.IsSetCard,0xb4)
end
s.listed_series={0xb4}
function s.spfilter(c,e,tp,mc)
	return c:IsSetCard(0xb4) and c:IsRitualMonster() and (not c.ritual_custom_check or c.ritual_custom_check(e,tp,Group.FromCards(mc),c))
		and (not c.mat_filter or c.mat_filter(mc,tp)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
		and mc:IsCanBeRitualMaterial(c)
end
function s.rfilter(c,mc)
	local mlv=mc:GetRitualLevel(c)
	if mlv==mc:GetLevel() then return false end
	local lv=c:GetLevel()
	return lv==(mlv&0xffff) or lv==(mlv>>16)
end
function s.rfilter2(c,mc)
	local mlv=mc:GetRitualLevel(c)
	if mlv==mc:GetLevel() then return false end
	local lv=c:GetLevel()
	local mlv2=mlv&0xffff
	if lv~=mlv2 then mlv2=lv else return false end
	return lv==mlv2
end
function s.filter(c,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c:IsLocation(LOCATION_MZONE) then ft=ft+1 end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	--- START of INSERT: CrimsonAlpha
	local location=LOCATION_HAND
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,27200101)}) do
		fg:AddCard(pe:GetHandler())
	end
	if #fg>0 then
		location=LOCATION_HAND+LOCATION_DECK
	else
		location=LOCATION_HAND
	end
	--- END of INSERT: CrimsonAlpha
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,location,0,c,e,tp,c)
	return sg:IsExists(s.rfilter,1,nil,c) or sg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,ft)
end
function s.mfilter(c)
	return c:HasLevel() and c:IsAbleToGrave()
end
function s.mzfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:GetSequence()<5
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<0 then return false end
		local mg=Duel.GetRitualMaterial(tp)
		if ft>0 then
			local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_EXTRA,0,nil)
			mg:Merge(mg2)
		else
			mg=mg:Filter(s.mzfilter,nil,tp)
		end
		return mg:IsExists(s.filter,1,nil,e,tp)
	end
	--- START of INSERT: CrimsonAlpha
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,27200101)}) do
		fg:AddCard(pe:GetHandler())
	end
	if #fg>0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	else
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
	--- END of INSERT: CrimsonAlpha
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<0 then return end
	local mg=Duel.GetRitualMaterial(tp)
	if ft>0 then
		local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_EXTRA,0,nil)
		mg:Merge(mg2)
	else
		mg=mg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local mat=mg:FilterSelect(tp,s.filter,1,1,nil,e,tp)
	local mc=mat:GetFirst()
	if not mc then return end
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,mc,e,tp,mc)
	if mc:IsLocation(LOCATION_MZONE) then ft=ft+1 end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end	
	--- START of INSERT: CrimsonAlpha
	local sg1=Group.CreateGroup()	
	local location=LOCATION_HAND
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,27200101)}) do
		fg:AddCard(pe:GetHandler())
	end
	if #fg>0 then
		if #sg>0 then
			if sg:IsExists(s.rfilter,1,nil,mc) or sg:CheckWithSumEqual(Card.GetLevel,mc:GetLevel(),1,ft) then
				if Duel.SelectYesNo(tp,aux.Stringid(27200101,0)) then
					location=LOCATION_DECK
				end
			else
				location=LOCATION_DECK
			end
		else
			location=LOCATION_DECK
		end
	else
		location=LOCATION_HAND
	end
	if location==LOCATION_DECK then
		sg1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,mc,e,tp,mc)
		sg:Merge(sg1)
		local fc=nil
		if #fg==1 then
			fc=fg:GetFirst()
		else
			fc=fg:Select(tp,1,1,nil)
		end
		Duel.Hint(HINT_CARD,0,fc:GetCode())
		fc:RegisterFlagEffect(27200101,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)							
	end
	--- END of INSERT: CrimsonAlpha		
	local b1=sg:IsExists(s.rfilter,1,nil,mc)
	local b2=sg:CheckWithSumEqual(Card.GetLevel,mc:GetLevel(),1,ft)
	Debug.Message(b1)
	Debug.Message(b2)
	if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=nil
		--- START of INSERT: CrimsonAlpha
		if #fg==1 then
			tg=sg:FilterSelect(tp,s.rfilter2,1,1,nil,mc)
		else
			tg=sg:FilterSelect(tp,s.rfilter,1,1,nil,mc)
		end
		--- END of INSERT: CrimsonAlpha
		local tc=tg:GetFirst()
		tc:SetMaterial(mat)
		if not mc:IsLocation(LOCATION_EXTRA) then
			Duel.ReleaseRitualMaterial(mat)
		else
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		--- START of INSERT: CrimsonAlpha
		local lv=mc:GetLevel()
		local tg,tg1
		local tc,tc1
		if #sg1>0 then
			tg1=sg1:FilterSelect(tp,s.lvfilter,1,1,nil,lv,sg,sg1)
			tc1=tg1:GetFirst()
			tc1:SetMaterial(mat)
			lv=lv-tc1:GetLevel()
			sg:Sub(sg1)
		end
		--- END of INSERT: CrimsonAlpha
		tg=sg:SelectWithSumEqual(tp,Card.GetLevel,lv,1,ft)
		tc=tg:GetFirst()
		for tc in aux.Next(tg) do
			tc:SetMaterial(mat)
		end
		if not mc:IsLocation(LOCATION_EXTRA) then
			Duel.ReleaseRitualMaterial(mat)
		else
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		Duel.BreakEffect()
		--- START of INSERT: CrimsonAlpha
		if tg1 then
			tg:Merge(tg1)
		end
		--- END of INSERT: CrimsonAlpha
		tc=tg:GetFirst()
		for tc in aux.Next(tg) do
			Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
		Duel.SpecialSummonComplete()
	end
end
function s.lvfilter(c,lv,lsg,lsg1)
	lsg:Sub(lsg1)
	local lv1=lv-c:GetLevel()
	return c:IsLevelBelow(lv) and lsg:IsExists(Card.IsLevel,1,nil,lv1)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
