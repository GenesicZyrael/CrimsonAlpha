--Naturia Bee
local s,id=GetID()
function s.initial_effect(c)
	--pseudo-pendulum
	local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
		-- e1:SetCountLimit(1)
		e1:SetTarget(s.pentg)
		e1:SetOperation(s.penop)
	c:RegisterEffect(e1)
	--return to hand
	local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_TO_GRAVE)
		e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
		e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
		e2:SetCondition(s.thcon)
		e2:SetTarget(s.thtg)
		e2:SetOperation(s.thop)
	c:RegisterEffect(e2)	
	--add tuner
	local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_BE_MATERIAL)
		e3:SetCondition(s.tncon)
		e3:SetOperation(s.tnop)
	c:RegisterEffect(e3)
end

function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.CheckLocation(tp,LOCATION_PZONE,0) 
			or Duel.CheckLocation(tp,LOCATION_PZONE,1) 
	end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	local c=e:GetHandler()
	local fid=e:GetHandler():GetFieldID()
	local nseq=(0xff^2)+16
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		--treat as Pendulum Card
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true,nseq)
		local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_SPSUMMON_PROC_G)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(LOCATION_PZONE)
			e1:SetCondition(Pendulum.Condition())
			e1:SetOperation(Pendulum.Operation())
			e1:SetValue(SUMMON_TYPE_PENDULUM)
		c:RegisterEffect(e1)
		local r1=Effect.CreateEffect(c)
			r1:SetType(EFFECT_TYPE_SINGLE)
			-- r1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			r1:SetCode(EFFECT_CHANGE_TYPE)
			r1:SetRange(LOCATION_PZONE)
			r1:SetValue(TYPE_PENDULUM)
			r1:SetReset(RESET_EVENT+0x1fe0000)
		c:RegisterEffect(r1)
		--set scale to 7
		local r2=Effect.CreateEffect(c)
			r2:SetType(EFFECT_TYPE_SINGLE)
			r2:SetCode(EFFECT_CHANGE_LSCALE)
			r2:SetValue(7)
			r2:SetReset(RESET_EVENT+0x1fe0000)
		c:RegisterEffect(r2)
		local r3=Effect.CreateEffect(c)
			r3:SetType(EFFECT_TYPE_SINGLE)
			r3:SetCode(EFFECT_CHANGE_RSCALE)
			r3:SetValue(7)
			r3:SetReset(RESET_EVENT+0x1fe0000)
		c:RegisterEffect(r3)
		--splimit
		local r4=Effect.CreateEffect(c)
			r4:SetType(EFFECT_TYPE_FIELD)
			r4:SetRange(LOCATION_ONFIELD)
			r4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			r4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
			r4:SetTargetRange(1,0)
			r4:SetTarget(s.splimit)
		c:RegisterEffect(r4)
		--destroy during the end phase
		local tc=e:GetHandler()
		local fid=e:GetHandler():GetFieldID()
		c:RegisterFlagEffect(id,RESET_EVENT+0x1fe0000,0,1,fid)
		local r5=Effect.CreateEffect(c)
			r5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			r5:SetCode(EVENT_PHASE+PHASE_END)
			r5:SetCountLimit(1)
			r5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			r5:SetLabel(fid)
			r5:SetLabelObject(c)
			r5:SetCondition(s.descon)
			r5:SetOperation(s.desop)
		Duel.RegisterEffect(r5,tp)
	end
end

-- {Pendulum Summon Restriction: Gusto}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x2a) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
function s.tgfilter(c)
	return c:IsSetCard(0x2a) 
		and not c:IsCode(id) 
		and c:IsAbleToGrave()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		if c.IsLocation(c,LOCATION_GRAVE) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			Duel.SendtoHand(c,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,c)
		end
    end
end
function s.tncon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local r1=Effect.CreateEffect(c)
		r1:SetType(EFFECT_TYPE_SINGLE)
		r1:SetCode(EFFECT_ADD_TYPE)
		r1:SetValue(TYPE_TUNER)
		r1:SetReset(RESET_EVENT+0x1fe0000)
	rc:RegisterEffect(r1)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else 
		return true 
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end