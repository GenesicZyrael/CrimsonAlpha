--Gem-Knights' Lapis & Lazuli
local s,id=GetID()
function s.initial_effect(c)
	--cos
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)	
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP)
	c:RegisterEffect(e2)	
	--Add 1 "Gem-Knight Fusion" to the hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_names={71422989}
function s.thfilter(c)
	return c:IsCode(71422989) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end

function s.filter2(c,fc)
	if not c:IsAbleToGraveAsCost() then return false end
	return c:IsCode(table.unpack(fc.material))
end
function s.filter1(c,tp)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_FUSION)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	tc=g:GetFirst()
	if Duel.IsPlayerCanSpecialSummonMonster(tp,27101030,0,0x4011,0,0,tc:GetLevel(),tc:GetRace(),tc:GetAttribute()) then 
		Duel.ConfirmCards(1-tp,g)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
		local token=Duel.CreateToken(tp,27101030)
		local r1=Effect.CreateEffect(e:GetHandler())
		r1:SetType(EFFECT_TYPE_SINGLE)
		r1:SetCode(EFFECT_CHANGE_RACE)
		r1:SetValue(tc:GetRace())
		r1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(r1,true)
		-- local r2=r1:Clone()
		-- r2:SetCode(EFFECT_CHANGE_LEVEL)
		-- r2:SetValue(tc:GetLevel())
		-- token:RegisterEffect(r2,true)
		local r3=r1:Clone()
		r3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		r3:SetValue(tc:GetAttribute())
		token:RegisterEffect(r3,true)
		local r4=r1:Clone()
		r4:SetCode(EFFECT_CHANGE_CODE)
		r4:SetValue(tc:GetOriginalCode())
		token:RegisterEffect(r4,true)		
		local r5=r1:Clone()
		r5:SetCode(EFFECT_UNRELEASABLE_SUM)
		r5:SetValue(1)
		token:RegisterEffect(r5,true)
		local r6=r1:Clone()
		r6:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		token:RegisterEffect(r6,true)
		local r7=r1:Clone()
		r7:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		r7:SetValue(s.matlimit)
		token:RegisterEffect(r7,true)
		local r8=r7:Clone()
		r8:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		token:RegisterEffect(r8,true)
		local r9=r7:Clone()
		r9:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		token:RegisterEffect(r9,true)
		local r10=r7:Clone()
		r10:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		token:RegisterEffect(r10,true)	

		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)	
	end 
end
function s.matlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x47)
end