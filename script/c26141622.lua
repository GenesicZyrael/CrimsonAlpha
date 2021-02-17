--Ceremonial Spirt Art - Gishiki
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Ritual.AddProcGreater(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),nil,aux.Stringid(id,0))
	c:RegisterEffect(e1)	
	local e2=Ritual.CreateProc({handler=c,desc=aux.Stringid(id,1),lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),extrafil=s.extragroup,
								extraop=s.extraop,stage2=nil,location=LOCATION_HAND,matfilter=s.charmer_filter})
	e2:SetCondition(s.condition2)
	e2:SetCost(s.cost)
	c:RegisterEffect(e2)
	local e3=Ritual.CreateProc({handler=c,desc=aux.Stringid(id,2),lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsCode,44536226),location=LOCATION_GRAVE})
	c:RegisterEffect(e3)	
	local e4=Ritual.CreateProc({handler=c,desc=aux.Stringid(id,3),lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsCode,44536226),extrafil=s.extragroup,
								extraop=s.extraop,stage2=nil,location=LOCATION_GRAVE,matfilter=s.charmer_filter})
	e4:SetCondition(s.condition2)
	e4:SetCost(s.cost)
	c:RegisterEffect(e4)

end
s.listed_names={44536226}
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.charmer_filter,tp,LOCATION_DECK,0,nil)
end
function s.charmer_filter(c)
	return (c:IsSetCard(0xbf) or c:IsSetCard(0x10c0)) and c:IsAbleToGrave() and c:IsLevelAbove(1)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mat:Sub(mat2)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.ritcheck(e,tp,g,sc)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,55481029),tp,LOCATION_FZONE,0,1,nil)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,55481029)}) do
		fg:AddCard(pe:GetHandler())
	end
	return #fg>0 and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,55481029),tp,LOCATION_FZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,55481029)}) do
		fg:AddCard(pe:GetHandler())
	end
	if chk==0 then 
		if #fg>0 then
			return Duel.IsExistingMatchingCard(s.charmer_filter,tp,LOCATION_DECK,0,1,nil) 		
		end
	end	
	local fc=nil
	if #fg==1 then
		fc=fg:GetFirst()
	else
		fc=fg:Select(tp,1,1,nil)
	end
	Duel.Hint(HINT_CARD,0,fc:GetCode())
	fc:RegisterFlagEffect(55481029,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)	
end
