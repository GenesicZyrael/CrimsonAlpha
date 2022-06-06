--リチュアの写魂鏡
--Gishki Photomirror
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not s.ritual_matching_function then
		s.ritual_matching_function={}
	end
	s.ritual_matching_function[c]=aux.FilterEqualFunction(Card.IsSetCard,0x3a)
end
s.listed_series={0x3a}
function s.filter(c,e,tp,lp)
	if not c:IsRitualMonster() or not c:IsSetCard(0x3a) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) then
		return false
	end
	return lp>c:GetLevel()*500
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_HAND
	if chk==0 then
		local lp=Duel.GetLP(tp)
		local fg=Group.CreateGroup()
		for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,27200101)}) do
			fg:AddCard(pe:GetHandler())
		end
		if #fg>0 then
			loc=loc+LOCATION_DECK
		end
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.filter,tp,loc,0,1,nil,e,tp,lp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_HAND
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lp=Duel.GetLP(tp)
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,27200101)}) do
			fg:AddCard(pe:GetHandler())
	end	
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,e,tp,lp)
	if #fg>0 then
		local g2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp,lp)
		if #g1>0 then
			if #g2>0 then
				if Duel.SelectYesNo(tp,aux.Stringid(27200101,0)) then
					loc=loc+LOCATION_DECK		
					local fc=nil
					if #fg==1 then
						fc=fg:GetFirst()
					else
						fc=fg:Select(tp,1,1,nil)
					end
					Duel.Hint(HINT_CARD,0,fc:GetCode())
					fc:RegisterFlagEffect(27200101,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
				end
			end
		else
			loc=loc+LOCATION_DECK		
			local fc=nil
			if #fg==1 then
				fc=fg:GetFirst()
			else
				fc=fg:Select(tp,1,1,nil)
			end
			Duel.Hint(HINT_CARD,0,fc:GetCode())
			fc:RegisterFlagEffect(27200101,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		end 
	end	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,loc,0,1,1,nil,e,tp,lp)
	local tc=tg:GetFirst()
	if tc then
		mustpay=true
		Duel.PayLPCost(tp,tc:GetLevel()*500)
		mustpay=false
		tc:SetMaterial(nil)
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end

