 --CCG: Daigusto Zeframpilica
-- [ Pendulum Effect ]
-- You cannot Pendulum Summon monsters, except "Gusto" and "Zefra" monsters. This effect
-- cannot be negated. Destroy 1 card from your hand or field, and if you do, Special Summon
-- 1 "Gusto" monster from your Deck or 1 "Zefra" monster from your face-up Extra Deck.
-- You can only use this effect of "Daigusto Zeframpilica" once per turn.
----------------------------------------
-- [ Monster Effect ]
-- When this card is Pendulum Summoned, or if this card is destroyed by battle or card 
-- effect while in your Monster Zone: You can Special Summon 1 "Gusto" or "Zefra" monster 
-- from your hand or from your face-up Extra Deck, except "Daigusto Zeframpilica". You 
-- can only use this effect of "Daigusto Zeframpilica" once per turn.
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
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetTarget(s.DesTarg)
	e3:SetOperation(s.DesOpe)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
		e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e4:SetCode(EVENT_SPSUMMON_SUCCESS)
		e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
		e4:SetCountLimit(1,id)
		e4:SetCondition(s.SpCon1)
		e4:SetTarget(s.SpTarg)
		e4:SetOperation(s.SpOpe)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
		e5:SetCode(EVENT_DESTROYED)
		e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
		e5:SetCondition(s.SpCon2)
	c:RegisterEffect(e5)
end
s.listed_series={0x10,0xc4}
--s.listed_names={id}
-- {Pendulum Summon Restriction: Zefra & Gusto}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x10) or c:IsSetCard(0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- {Pendulum Effect: Special Summon}
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x10) 
		and not c:IsCode(id) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0xc4) 
		and c:IsFaceup()
		-- and not c:IsCode(id) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.DesTarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) then 
		loc=loc+LOCATION_GRAVE 
	end
	-- if Duel.GetLocationCountFromEx(tp)>0 
	-- and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) then 
		-- loc=loc+LOCATION_EXTRA 
	-- end
	if chk==0 then return loc~=0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler())
	end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.DesOpe(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local loc=0
	local b1,b2,op
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) then 
		loc=loc+LOCATION_DECK 
		b1=1
	end
	-- if Duel.GetLocationCountFromEx(tp)>0 
	-- and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) then 
		-- loc=loc+LOCATION_EXTRA 
		-- b2=1
	-- end	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 
	-- and Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 
	then		
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- if b1 and b2 then 
			-- op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		-- elseif b1 then 
			-- op=Duel.SelectOption(tp,aux.Stringid(id,1))
		-- else 
			-- op=Duel.SelectOption(tp,aux.Stringid(id,2))+1 
		-- end
		-- if op==0 then
			local g1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g1:GetCount()>0 then
				Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
			end
		-- else
			-- local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			-- if g2:GetCount()>0 then
				-- Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
			-- end
		-- end
	end
end
-- {Monster Effect: Special Summon}
function s.SpCon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.SpCon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) 
		and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
end
function s.spfilter3(c,e,tp)
	return (c:IsSetCard(0x10) or c:IsSetCard(0xc4))
		and not c:IsCode(id) 
		-- and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.SpTarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then 
		-- loc=loc+LOCATION_GRAVE
		loc=loc+LOCATION_HAND		
	end
	if Duel.GetLocationCountFromEx(tp)>0 then 
		loc=loc+LOCATION_EXTRA 
	end
	if chk==0 then return loc~=0 and Duel.IsExistingMatchingCard(s.spfilter3,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.SpOpe(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then 
		-- loc=loc+LOCATION_GRAVE
		loc=loc+LOCATION_HAND
	end
	if Duel.GetLocationCountFromEx(tp)>0 then 
		loc=loc+LOCATION_EXTRA 
	end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	--local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter3),tp,loc,0,1,1,nil,e,tp)
	local g=Duel.SelectMatchingCard(tp,s.spfilter3,tp,loc,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end		