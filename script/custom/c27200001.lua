-- Gishki Zefravance
local s,id=GetID()
function s.initial_effect(c)
	local rparams={handler=c,lvtype=RITPROC_EQUAL,desc=aux.Stringid(id,3)}
	local rittg,ritop=Ritual.Target(rparams),Ritual.Operation(rparams)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--splimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	--Send Gishki and Zefra monsters from your Deck or Extra Deck to the GY to Ritual Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTargetRange(LOCATION_EXTRA+LOCATION_DECK,0)
	e3:SetCondition(function(e) return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0 end)
	e3:SetCountLimit(1,{id,0})
	e3:SetValue(1)
	e3:SetTarget(s.mttg)
	e3:SetLabelObject({s.forced_replacement})
	c:RegisterEffect(e3)
	--pendulum set
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.pctg)
	e4:SetOperation(s.pcop(rittg,ritop))
	c:RegisterEffect(e4)
end
s.listed_series={SET_GISHKI,SET_ZEFRA}
-- {Pendulum Summon Restriction: Zefra & Gishki}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(SET_GISHKI) or c:IsSetCard(SET_ZEFRA) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- {Pendulum Effect: Use Deck and Extra Deck for Materials}
function s.mtfil(c)
	return c:IsSetCard(SET_ZEFRA) 
		or c:IsSetCard(SET_GISHKI) 
end
function s.mttg(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.mtfil,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
	return g:IsContains(c)
end
function s.forced_replacement(e,tp,sg,rc)
	local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA+LOCATION_DECK)
	return ct<=1,ct>1
end
-- {Monster Effect: Place in Pendulum Zone, then Ritual Summon if possible}
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return (Duel.CheckLocation(tp,LOCATION_PZONE,0) 
			or Duel.CheckLocation(tp,LOCATION_PZONE,1)) 
	end	
end
function s.pcop(rittg,ritop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
		local c=e:GetHandler()
		if not e:GetHandler():IsRelateToEffect(e) then return end
		if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		if rittg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			ritop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end