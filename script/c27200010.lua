-- Gem-Knight Zefranite
-- [ Pendulum Effect ]
-- You cannot Pendulum Summon monsters, except "Gem-Knight" and "Zefra" monsters. This effect cannot be negated. You can Fusion Summon 1 Fusion Monster from your Extra Deck using monsters from your hand or field as Fusion Materials. You can only use this effect of "Gem-Knight Zefranite" once per turn.
-- ----------------------------------------
-- [ Monster Effect ]
-- This card can be used as a substitute for any 1 Fusion Material whose name is specifically listed on the Fusion Monster Card, but the other Fusion Material(s) must be correct. You can reveal 1 monster from your Main Deck or Extra Deck; This card's name can be treated as the revealed monster's original name then, Fusion Summon 1 Fusion Monster from your Extra Deck using monsters from your hand or field as Fusion Materials, including this card. You can only use this effect of "Gem-Knight Zefranite" once per turn.
local s,id=GetID()
local fparams = {}
local ftparam = {nil,nil,nil,nil,Fusion.ForcedHandler}
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
	--fusion summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetTarget(Fusion.SummonEffTG(table.unpack(fparams)))
	e3:SetOperation(Fusion.SummonEffOP(table.unpack(fparams)))	
	c:RegisterEffect(e3)
	--fusion substitute
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e4:SetCondition(s.subcon)
	c:RegisterEffect(e4)
	--fusion substitute
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e5:SetCost(s.cost)
	e5:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(ftparam)),Fusion.SummonEffOP(table.unpack(ftparam))))
	c:RegisterEffect(e5)	
end
s.listed_series={0x47,0xc4}
-- {Pendulum Summon Restriction: Zefra & Gem- Monsters}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x47) or c:IsSetCard(0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- {Monster Effect: Fusion Substitute}
function s.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- {Monster Effect: Fusion Tag + Polymerization}
function s.filter(c,ec)
	return c:IsType(TYPE_MONSTER) and not c:IsSummonCode(nil,SUMMON_TYPE_FUSION,PLAYER_NONE,ec:GetCode(nil,SUMMON_TYPE_FUSION))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local cg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,c)
	Duel.ConfirmCards(1-tp,cg)
	e:SetLabel(cg:GetFirst():GetCode())
end
function s.operation(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(e:GetLabel())
		e1:SetOperation(s.chngcon)
		c:RegisterEffect(e1)
		local fus=fustg(e,tp,eg,ep,ev,re,r,rp,0)
		if fus and Duel.SelectYesNo(tp,aux.Stringid(id,1))  then
			Duel.BreakEffect()
			fusop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end 
function s.chngcon(scard,sumtype,tp)
	return (sumtype&MATERIAL_FUSION)~=0
end
