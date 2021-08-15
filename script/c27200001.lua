 --CCG: Gishki Zefravance
-- [ Pendulum Effect ]
-- You cannot Pendulum Summon monsters, except "Gishki" and "Zefra" monsters. This effect
-- cannot be negated. Once per turn: Ritual Summon 1 Ritual Monster from your hand, by Tributing monsters 
-- from your hand or field whose total Levels equal the Level of the monster your Ritual 
-- Summon.
-- ----------------------------------------
-- [ Monster Effect ]
-- When this card is Normal or Pendulum Summoned: You can add 1 Ritual Monster from your Deck, and add 1 
-- Ritual Spell Card from your Deck or GY to your hand. If you control no Ritual Monsters, while you 
-- have 2 "Zefra" cards in your Pendulum Zones: You can banish this card from your GY 
-- or face-up from the Extra Deck; Add 1 Ritual Monster from your Deck, and add 1 Ritual Spell Card from your Deck  
-- or GY to your hand. You cannot Special Summon monsters from the Extra Deck during the turn 
-- you activate this effect, except "Zefra" monsters. You can only use 1 "Gishki Zefravance" 
-- effect per turn and only once that turn.
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
	--ritual summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(27200001,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.RitTarg)
	e3:SetOperation(s.RitOp)
	c:RegisterEffect(e3)
	--summon search
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.AddTarg)
	e4:SetOperation(s.AddOp)	
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(s.SumCond)
	c:RegisterEffect(e5)
	--banish search
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE+LOCATION_EXTRA)
	e6:SetCountLimit(1,id)
	e6:SetCost(s.BanCost)
	--e6:SetCondition(s.BanCond)
	e6:SetTarget(s.AddTarg)
	e6:SetOperation(s.AddOp)	
	c:RegisterEffect(e6)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- [Global Check: If Player Summoned from the Extra Deck]
function s.counterfilter(c)
	if c:GetSummonLocation()==LOCATION_EXTRA then
		if not c:IsSetCard(0xc4) then
			return false
		else
			return true
		end
	else
		return true
	end
end
-- {Pendulum Summon Restriction: Zefra & Gishki}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x3a) or c:IsSetCard(0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- {Pendulum Effect: Ritual Summon}
function s.ritual_filter(c)
	return c:IsType(TYPE_RITUAL)
end
function s.RitMatFilter(c,tp,mg,rc)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
		Duel.SetSelectedCard(c)
		return mg:CheckWithSumEqual(Card.GetRitualLevel,rc:GetLevel(),0,99,rc)
	else return false end
end
function s.RitFilter(c,e,tp,m,ft)
	if not s.ritual_filter(c) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	if c:IsCode(21105106) then return c:ritual_custom_condition(mg,ft) end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,nil)
	end
	if ft>0 then
		return mg:CheckWithSumEqual(Card.GetRitualLevel,c:GetLevel(),1,99,c)
	else
		return mg:IsExists(s.RitMatFilter,1,nil,tp,mg,c)
	end
end
function s.RitTarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg1=Duel.GetRitualMaterial(tp)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(s.RitFilter,tp,LOCATION_HAND,0,1,nil,e,tp,mg1,ft)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.RitOp(e,tp,eg,ep,ev,re,r,rp)
	local mg1=Duel.GetRitualMaterial(tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.RitFilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg1,ft)
	local tc=tg:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc:IsCode(21105106) then
			tc:ritual_custom_operation(mg)
			local mat=tc:GetMaterial()
			Duel.ReleaseRitualMaterial(mat)
		else
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,nil)
			end
			local mat=nil
			if ft>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				mat=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetLevel(),1,99,tc)
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				mat=mg:FilterSelect(tp,s.RitMatFilter,1,1,nil,tp,mg,tc)
				Duel.SetSelectedCard(mat)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				local mat2=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetLevel(),0,99,tc)
				mat:Merge(mat2)
			end
			tc:SetMaterial(mat)
			Duel.ReleaseRitualMaterial(mat)
		end
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- {Monster Effect: Summon Search}
function s.SumCond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- {Monster Effect: Banish Search}
function s.BanCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetCustomActivityCount(27200001,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.BanLimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if chk==0 then 
		return (not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741) or not c:IsType(TYPE_MONSTER)) 
			and c:IsAbleToRemoveAsCost() 
	end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.BanLimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xc4) and c:IsLocation(LOCATION_EXTRA)
end

-- {Monster Effect: Add to hand}
function s.AddFilter2(c)
	return c:IsType(TYPE_RITUAL) 
		and c:IsType(TYPE_SPELL) 
		and c:IsAbleToHand()
end
function s.AddFilter1(c)
	return c:IsType(TYPE_RITUAL)
		and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.AddFilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,c)
end
function s.AddTarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.AddFilter1,tp,LOCATION_DECK,0,1,nil) 
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.AddOp(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.AddFilter1,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.AddFilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		if mg:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=mg:Select(tp,1,1,nil)
			g:Merge(sg)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
