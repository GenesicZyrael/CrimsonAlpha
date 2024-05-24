--Grim Pact with Exodia
local s,id=GetID()
function s.initial_effect(c) 
	local e1=Ritual.AddProcGreater{handler=c,
								   filter=aux.FilterBoolFunction(Card.IsCode,167574890),
								   extrafil=s.extrafil,
								   -- extraop=s.extraop,
								   forcedselection=s.rcheck,
								   location=LOCATION_HAND|LOCATION_GRAVE,
								   extratg=s.extratg}
	--lv change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(id)
	e2:SetRange(LOCATION_ALL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_RITUAL_LEVEL)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_ALL)
	e3:SetTargetRange(LOCATION_ALL,0)
	e3:SetTarget(s.lvtg)
	e3:SetValue(s.lvval)
	c:RegisterEffect(e3)
end
s.listed_names={167574890}
s.listed_series={SET_FORBIDDEN_ONE}
function s.lvtg(e,c)
	return c:IsLevelAbove(1) 
		and c:IsOriginalSetCard(SET_FORBIDDEN_ONE)
end
function s.lvval(e,c,rc)
	local lv=c:GetLevel()
	local tp=e:GetHandler():GetControler()
	if Duel.IsPlayerAffectedByEffect(tp,id) then
		return 2
	else
		return lv
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.fexfilter(c)
	return c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsAbleToGrave() 
end
function s.rcheck(e,tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=2
end
function s.extrafil(e,tp,mg)
	local sg=Duel.GetMatchingGroup(s.fexfilter,tp,LOCATION_DECK,0,nil)
	if #sg>0 then
		return sg
	else
		return nil
	end
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp,sc)
	local matk=mg:Filter(Card.IsOriginalSetCard,nil,SET_FORBIDDEN_ONE)
	local atk=0
	for tc in aux.Next(matk) do
		local catk=tc:GetTextAttack()
		-- local cdef=tc:GetTextDefense()
		atk=atk+(catk>=0 and catk or 0)
			   -- +(cdef>=0 and cdef or 0)
	end
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	sc:RegisterEffect(e1)
end