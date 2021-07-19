--Dragunity Knight Zefraxa
-- [ Pendulum Effect ]
-- You cannot Pendulum Summon monsters, except "Dragunity" and "Zefra" monsters. This effect cannot be negated. Once per turn if a monster you control battles an opponent's monster (Quick Effect): You can equip 1 "Dragunity" Tuner from your Deck to that monster, but it cannot be Special Summoned this turn.
-- ----------------------------------------
-- [ Monster Effect ]
-- If this card is sent to the GY or to the Extra Deck face-up: You can target 1 monster you control; equip this card to it, and if you do, it gains 500 ATK. While this card is equipped to a monster: You can send 1 Level 4 or lower "Dragunity" or "Zefra" monster from your hand to the GY; Special Summon this card, then reduce it's Level by the sent monster's Level in the GY. You can only use each effect of "Dragunity Knight Zefraxa" once per turn.
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
	--equip
	local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetType(EFFECT_TYPE_QUICK_O)
		e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
		e3:SetRange(LOCATION_PZONE)
		e3:SetCountLimit(1)
		e3:SetTarget(s.eqtg1)
		e3:SetOperation(s.eqop1)
	c:RegisterEffect(e3)
	--special summon while equipped
	local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,3))
		e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e4:SetType(EFFECT_TYPE_IGNITION)
		e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
		e4:SetRange(LOCATION_SZONE)
		e4:SetCost(s.spcost)
		e4:SetTarget(s.sptg)
		e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--equip itself
	local e5=Effect.CreateEffect(c)
		e5:SetDescription(aux.Stringid(id,2))
		e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		e5:SetCode(EVENT_TO_DECK)
		e5:SetCountLimit(1,id,EFFECT_COUNT_CODE_SINGLE)
		e5:SetCondition(s.eqcon2)
		e5:SetTarget(s.eqtg2)
		e5:SetOperation(s.eqop2)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
		e6:SetCode(EVENT_TO_GRAVE)
		e6:SetCondition(aux.TRUE)
	c:RegisterEffect(e6)
end
s.listed_series={0x29,0xc4}
-- {Pendulum Summon Restriction: Zefra & Dragunity}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x29) or c:IsSetCard(0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- {Pendulum Effect: Equip}
function s.eqfilter1(c,tp)
	return c:IsFaceup() 
		and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_DECK,0,1,nil,c,tp)
end
function s.eqfilter2(c,tc,tp)
	return c:IsSetCard(0x29) 
		and c:IsType(TYPE_MONSTER) 
		and not c:IsForbidden()
end
function s.eqtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) 
			and s.eqfilter1(chkc,tp)
	end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
			and Duel.IsExistingTarget(s.eqfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
	end
end
function s.eqop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local ec=Duel.GetAttacker()
	if ec and ec:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,s.eqfilter2,tp,LOCATION_DECK,0,1,1,nil,ec,tp)
		local tc=g:GetFirst()
		if not tc or not Duel.Equip(tp,tc,ec,true) then return end
		local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit1)
			e1:SetLabelObject(ec)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetRange(LOCATION_SZONE)
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
function s.eqlimit1(e,c)
	return c==e:GetLabelObject()
end
-- {Monster Effect: Special Summon}
function s.costfilter(c,lv)
	local clv=c:GetLevel()
	return clv>0 and clv<lv 
		and c:IsAbleToGraveAsCost() 
		and (c:IsSetCard(0x29) or c:IsSetCard(0xc4))
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=e:GetHandler():GetLevel()
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,lv) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetEquipTarget()
	if chk==0 then return tc and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	local clv=c:GetLevel()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		lv=clv-lv
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- {Monster Effect: Equip self}
function s.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) 
end
function s.eqlimit2(e,c)
	return e:GetOwner()==c
end
function s.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
function s.eqop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.Equip(tp,c,tc,true)
		--Add Equip limit
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit2)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
