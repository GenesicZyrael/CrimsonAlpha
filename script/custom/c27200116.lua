--Zefra Divine Mirror
local s,id=GetID()
function s.initial_effect(c)	
	--Activate
	local e1=Ritual.AddProcGreater({handler=c,
									filter=s.ritualfil,
									extrafil=s.extrafil,
									extratg=s.extratg,
									extraop=s.extraop,
									matfilter=aux.FilterBoolFunction(Card.IsType,TYPE_PENDULUM),
									location=LOCATION_HAND|LOCATION_GRAVE,
									requirementfunc=Card.GetScale})
	e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)
	--Shuffle 1 "Zefra" monster to the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ZEFRA}
function s.ritualfil(c)
	return c:IsRitualMonster()
end
function s.mfilter(c)
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) and c:IsSetCard(SET_ZEFRA) 
		and c:IsAbleToRemove() and c:IsPublic() and c:GetScale()>0
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_PZONE|LOCATION_EXTRA,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_PZONE|LOCATION_EXTRA)
end
function s.exfilter(c)
	return c:IsLocation(LOCATION_PZONE|LOCATION_EXTRA) and c:IsPublic() 
		and c:IsSetCard(SET_ZEFRA) and c:IsAbleToRemove() and c:GetScale()>0
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,sc)
	local rg=mat:Filter(s.exfilter,nil)
	if #rg>0 then
		mat:Sub(rg)
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
	end
	Duel.ReleaseRitualMaterial(mat)
end
function s.tdfilter(c)
	return c:IsSetCard(SET_ZEFRA) and c:IsPublic() and c:IsAbleToDeck() and c:IsMonster()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED|LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED|LOCATION_EXTRA)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_REMOVED|LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end