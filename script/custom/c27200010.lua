-- Gem-Knight Zefranite
local s,id=GetID()
local params={ }
function s.initial_effect(c)
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
	-- Allow cards in the Extra Deck and Pendulum Zones as fusion materials
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTargetRange(LOCATION_EXTRA+LOCATION_PZONE,0)
	e3:SetTarget(s.ftg)
	e3:SetCountLimit(1,{id,0})
	e3:SetValue(aux.TRUE)
	c:RegisterEffect(e3)
	--pendulum set
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.pctg)
	e4:SetOperation(s.pcop(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_DECK)
	e5:SetCondition(s.pccon)
	c:RegisterEffect(e5)
end
s.listed_series={SET_GEM_KNIGHT,SET_ZEFRA}
-- {Pendulum Summon Restriction: Zefra & Gem- Monsters}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(SET_GEM_KNIGHT) or c:IsSetCard(SET_ZEFRA) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- {Monster Effect: Place in Pendulum Zone, then Fusion Summon if possible}
function s.ftg(e,c)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() 
		and (c:IsSetCard(SET_GEM_KNIGHT) or c:IsSetCard(SET_ZEFRA)) 
end
function s.pccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) 
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return (Duel.CheckLocation(tp,LOCATION_PZONE,0) 
			or Duel.CheckLocation(tp,LOCATION_PZONE,1)) 
	end	
end
function s.pcop(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not e:GetHandler():IsRelateToEffect(e) then return end
		if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		if fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			fusop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end