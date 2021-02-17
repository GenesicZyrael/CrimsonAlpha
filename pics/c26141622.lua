--Ceremonial Spirt Art - Gishiki
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Ritual.AddProcGreater(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),nil,aux.Stringid(id,0))
	local e2=Ritual.AddProcGreaterCode(c,6,aux.Stringid(id,1),44536226)
	--Activate
	-- local e1=Effect.CreateEffect(c)
	-- e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	-- e1:SetType(EFFECT_TYPE_ACTIVATE)
	-- e1:SetCode(EVENT_FREE_CHAIN)
	-- -- e1:SetCountLimit(1,id)
	-- e1:SetTarget(s.target)
	-- e1:SetOperation(s.activate)
	-- c:RegisterEffect(e1)
end
s.listed_names={44536226}

function s.charmer_filter(c)
	return (c:IsSetCard(0xbf) or c:IsSetCard(0x10c0)) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- function s.spfilter(c,e,tp,mc)
	-- return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRitualMonster() and (not c.ritual_custom_check or c.ritual_custom_check(e,tp,Group.FromCards(mc),c))
		-- and (not c.mat_filter or c.mat_filter(mc,tp)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
		-- and mc:IsCanBeRitualMaterial(c)
-- end
-- function s.rfilter(c,mc)
	-- local mlv=mc:GetRitualLevel(c)
	-- if mlv==mc:GetLevel() then return false end
	-- local lv=c:GetLevel()
	-- return lv==(mlv&0xffff) or lv==(mlv>>16)
-- end
-- function s.filter(c,e,tp)
	-- local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,c,e,tp,c)
	-- local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- if c:IsLocation(LOCATION_MZONE) then ft=ft+1 end
	-- if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	-- return sg:IsExists(s.rfilter,1,nil,c) or sg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,ft)
-- end
-- function s.mfilter(c)
	-- return c:HasLevel() and c:IsAbleToGrave()
-- end
-- function s.mzfilter(c,tp)
	-- return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:GetSequence()<5
-- end
-- function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- if chk==0 then
		-- local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- if ft<0 then return false end
		-- local mg=Duel.GetRitualMaterial(tp)
		-- if ft>0 then
			-- local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_EXTRA,0,nil)
			-- mg:Merge(mg2)
		-- else
			-- mg=mg:Filter(s.mzfilter,nil,tp)
		-- end
		-- return mg:IsExists(s.filter,1,nil,e,tp)
	-- end
	-- Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
-- end
-- function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- if ft<0 then return end
	-- local mg=Duel.GetRitualMaterial(tp)
	-- if ft>0 then
		-- local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_EXTRA,0,nil)
		-- mg:Merge(mg2)
	-- else
		-- mg=mg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- end
	-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	-- local mat=mg:FilterSelect(tp,s.filter,1,1,nil,e,tp)
	-- local mc=mat:GetFirst()
	-- if not mc then return end
	-- local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,mc,e,tp,mc)
	-- if mc:IsLocation(LOCATION_MZONE) then ft=ft+1 end
	-- if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	-- local b1=sg:IsExists(s.rfilter,1,nil,mc)
	-- local b2=sg:CheckWithSumEqual(Card.GetLevel,mc:GetLevel(),1,ft)
	-- if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
		-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- local tg=sg:FilterSelect(tp,s.rfilter,1,1,nil,mc)
		-- local tc=tg:GetFirst()
		-- tc:SetMaterial(mat)
		-- if not mc:IsLocation(LOCATION_EXTRA) then
			-- Duel.ReleaseRitualMaterial(mat)
		-- else
			-- Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- end
		-- Duel.BreakEffect()
		-- Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		-- tc:CompleteProcedure()
	-- else
		-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- local tg=sg:SelectWithSumEqual(tp,Card.GetLevel,mc:GetLevel(),1,ft)
		-- local tc=tg:GetFirst()
		-- for tc in aux.Next(tg) do
			-- tc:SetMaterial(mat)
		-- end
		-- if not mc:IsLocation(LOCATION_EXTRA) then
			-- Duel.ReleaseRitualMaterial(mat)
		-- else
			-- Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- end
		-- Duel.BreakEffect()
		-- tc=tg:GetFirst()
		-- for tc in aux.Next(tg) do
			-- Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			-- tc:CompleteProcedure()
		-- end
		-- Duel.SpecialSummonComplete()
	-- end
-- end
function s.filter(c,e,tp,m1,m2,ft)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,c,e,tp,c)
	if not c:IsSetCard(0x2093) or bit.band(c:GetType(),0x81)~=0x81
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	mg:Merge(m2)
	if ft>0 then
		return mg:CheckWithSumEqual(Card.GetRitualLevel,c:GetLevel(),1,99,c)
	else
		return ft>-1 and mg:IsExists(s.mfilterf,1,nil,tp,mg,c)
	end
end
function s.mfilterf(c,tp,mg,rc)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
		Duel.SetSelectedCard(c)
		return mg:CheckWithSumEqual(Card.GetRitualLevel,rc:GetLevel(),0,99,rc)
	else return false end
end
function s.mfilter(c)
	return c:GetLevel()>0 and c:IsRace(RACE_WARRIOR+RACE_FAIRY) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg1=Duel.GetRitualMaterial(tp)
		local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp,mg1,mg2,ft)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg1=Duel.GetRitualMaterial(tp)
	local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg1,mg2,ft)
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(mg2)
		local mat=nil
		if ft>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetLevel(),1,99,tc)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=mg:FilterSelect(tp,s.mfilterf,1,1,nil,tp,mg,tc)
			Duel.SetSelectedCard(mat)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local mat2=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,tc:GetLevel(),0,99,tc)
			mat:Merge(mat2)
		end
		tc:SetMaterial(mat)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE):Filter(Card.IsRace,nil,RACE_WARRIOR+RACE_FAIRY)
		mat:Sub(mat2)
		Duel.ReleaseRitualMaterial(mat)
		Duel.SendtoDeck(mat2,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
