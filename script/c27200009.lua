-- Constellar Zefraseyfert
-- [ Pendulum Effect ]
-- You cannot Pendulum Summon monsters, except "Constellar" and "Zefra" monsters. This effect cannot be negated. During the Main Phase: For the rest of the turn, you can make the Levels of "Constellar" and "Zefra" monsters you control will be treated as the original Levels of each other monster currently on the field, when used for an Xyz Summon.
-- ----------------------------------------
-- [ Monster Effect ]
-- When you Normal Summon a "Constellar" or "Zefra" monster: You can Special Summon this card from your hand, and if you do, this card's Level is also  treated as that monster's Level when used for an Xyz Summon. You can only use this effect of "Constellar Zefraseyfert" once per turn.
local s,id=GetID()
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
	--xyz level
	local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_IGNITION)
		e3:SetRange(LOCATION_PZONE)
		e3:SetCountLimit(1)
		e3:SetOperation(s.xyzope)
	c:RegisterEffect(e3)
	--spsummon
    local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,0))
		e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e4:SetCode(EVENT_SUMMON_SUCCESS)
		e4:SetRange(LOCATION_HAND)
		e4:SetCountLimit(1,id)
		e4:SetCondition(s.spcon)
		e4:SetTarget(s.sptg)
		e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end
s.listed_series={0x53,0xc4}
--s.listed_names={id}
-- {Pendulum Summon Restriction: Zefra & Constellar}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x53) or c:IsSetCard(0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- {Pendulum Effect: Xyz Levels}
function s.xyztg(e,c)
    return c:HasLevel() 
		and ( c:IsSetCard(0x53) or c:IsSetCard(0xc4) )
end
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)	  
	return e:GetHandler():IsHasEffect(id)
end
function s.xyzope(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(Card.HasXyzLevel,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		lvl=tc:GetOriginalLevel()
		local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_XYZ_LEVEL)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetTarget(s.xyztg)
			e1:SetValue(tc:GetOriginalLevel())
			e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
-- {Monster Effect: Special Summon}
function s.filter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==tp and eg:GetFirst():IsSetCard(0x53) or eg:GetFirst():IsSetCard(0xc4)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=eg:GetFirst()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_XYZ_LEVEL)
			e1:SetValue(tc:GetOriginalLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
    end
    Duel.SpecialSummonComplete()
end