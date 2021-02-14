 --Renshaddoll Winda
local s,id=GetID()
local beast=3717252    local dragon=77723643    local squamata=30328508
local hound=52551211   local hedgehog=4939890   local falco=37445295
local keios=24635329   local wendi=51023024     local ariel=97518132
local genius=66675911  local void=92079625
local medium=27200402  local priestess=27200403 local spiderfang=27200404
local params={aux.FilterBoolFunction(Card.IsSetCard,0x9d)}
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
		e1:SetCountLimit(1,id)
		e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
		e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1,false,REGISTER_FLAG_SHADDOLL)	
	--effect gain
	local e2=Effect.CreateEffect(c)
	    e2:SetDescription(aux.Stringid(id,1))
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e2:SetProperty(EFFECT_FLAG_DELAY)
		e2:SetCode(EVENT_TO_GRAVE)
		e2:SetCountLimit(1,id)
		e2:SetTarget(s.efftg)
		e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
function s.efffilter(c)
	return c:IsSetCard(0x9d)
		and c:IsType(TYPE_FUSION)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(s.efffilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.efffilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(tc)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_QUICK_O)
			e1:SetCode(EVENT_FREE_CHAIN)
			e1:SetRange(LOCATION_MZONE)
			e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
			e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
			e1:SetCost(s.copycost)
			e1:SetTarget(s.copytarget)
			e1:SetOperation(s.copyoperation)
			e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end
function s.copfilter(c)
	return c:IsAbleToGraveAsCost() 
		and c:IsSetCard(0x9d) 
		and c:IsType(TYPE_FLIP)
end
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK,0,1,nil) 
	end
end
function s.tohandany(c)
	return c:IsSetCard(0x9d) and c:IsAbleToHand()
end
function s.tohandmon(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.tohandst(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.ssfilter_any(c,e,tp)
	return c:IsSetCard(0x9d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
function s.ssfilter_others(c,e,tp,self)
	return c:IsSetCard(0x9d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE) and not c:IsCode(self)
end
function s.immfilter(c)
	return c:IsSetCard(0x9d) and c:IsFaceup()
end
function s.filter(c,att)
	return c:IsSetCard(0x9d) and c:IsAbleToGrave() and c:IsAttribute(att)
end
function s.rmfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,c:GetAttribute())
end
function s.copytarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	local g=Duel.SelectMatchingCard(tp,s.copfilter,tp,LOCATION_DECK,0,1,1,nil)
	local c=g:GetFirst()
	if Duel.SendtoGrave(g,REASON_COST) and g:GetCount()>0 then
		e:SetLabel(c:GetCode())
		if c:IsCode(beast) and Duel.IsPlayerCanDraw(tp,2) then
			Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
			Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)	
		end
		if c:IsCode(dragon) then
			if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
			if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
		end
		if c:IsCode(squamata) then
			if chkc then return chkc:IsLocation(LOCATION_MZONE) end
			if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g2=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		end
		if c:IsCode(hound) then
			if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tohandany(chkc) end
			if chk==0 then return Duel.IsExistingTarget(s.tohandany,tp,LOCATION_GRAVE,0,1,nil) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectTarget(tp,s.tohandany,tp,LOCATION_GRAVE,0,1,1,nil)
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
		end
		if c:IsCode(hedgehog) then
			if chk==0 then return Duel.IsExistingMatchingCard(s.tohandst,tp,LOCATION_DECK,0,1,nil) end
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		end
		if c:IsCode(falco) then
			if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.ssfilter_others(chkc,e,tp,falco) end
			if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.ssfilter_others,tp,LOCATION_GRAVE,0,1,nil,e,tp,falco) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectTarget(tp,s.ssfilter_others,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,falco)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
		end
		if c:IsCode(ariel) then
			if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.ssfilter_any(chkc,e,tp) end
			if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.ssfilter_any,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectTarget(tp,s.ssfilter_any,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
		end
		if c:IsCode(keios) then
			if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.ssfilter_any,tp,LOCATION_HAND,0,1,nil,e,tp) end
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		end
		if c:IsCode(wendi) then
			if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.ssfilter_others,tp,LOCATION_HAND,0,1,nil,e,tp,wendi) end
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		end	
		if c:IsCode(genius) then
			if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.immfilter(chkc) end
			if chk==0 then return Duel.IsExistingTarget(s.immfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
			Duel.SelectTarget(tp,s.immfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)		
		end
		if c:IsCode(void) then
			if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc) end
			if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
			Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
		end		
		if c:IsCode(medium) then
			if chkc then return chkc:IsLocation(LOCATION_HAND+LOCATION_DECK) and chkc:IsControler(tp) and s.ssfilter_others(chkc,e,tp,medium) end
			if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.ssfilter_others,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,medium) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectTarget(tp,s.ssfilter_others,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,medium)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
		end
		if c:IsCode(priestess) then
			if chk==0 then
				local chkf=tp
				local mg1=Duel.GetFusionMaterial(tp)
				local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
				if not res then
					local ce=Duel.GetChainMaterial(tp)
					if ce~=nil then
						local fgroup=ce:GetTarget()
						local mg2=fgroup(ce,e,tp)
						local mf=ce:GetValue()
						res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
					end
				end
				return res
			end
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		end
		if c:IsCode(spiderfang) then
			if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tohandmon(chkc) end
			if chk==0 then return Duel.IsExistingTarget(s.tohandmon,tp,LOCATION_GRAVE,0,1,nil) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectTarget(tp,s.tohandmon,tp,LOCATION_GRAVE,0,1,1,nil)
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
		end
	end
end
function s.copyoperation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==beast and Duel.IsPlayerCanDraw(tp,2) then
		local tc=Duel.GetFirstTarget()
		if Duel.Draw(tp,2,REASON_EFFECT)==2 then
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end	
	end	
	if e:GetLabel()==dragon then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then 
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
	if e:GetLabel()==squamata then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
	if e:GetLabel()==hound then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
	if e:GetLabel()==hedgehog then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.tohandst,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if e:GetLabel()==falco then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			Duel.ConfirmCards(1-tp,tc)
		end
	end
	if e:GetLabel()==ariel then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)
			Duel.ConfirmCards(1-tp,tc)
		end
	end
	if e:GetLabel()==keios then
		-- if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or not e:GetHandler():IsRelateToEffect(e) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.ssfilter_any,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)>0 and tc:IsFacedown() then
			Duel.ConfirmCards(1-tp,tc)
		end
	end
	if e:GetLabel()==wendi then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.ssfilter_others,tp,LOCATION_DECK,0,1,1,nil,e,tp,wendi)
		if #tc>0 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)
			Duel.ConfirmCards(1-tp,tc)
		end
	end	
	if e:GetLabel()==genius then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			--Unaffected by monster effects
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3101)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end	
	if e:GetLabel()==void then
		local tc=Duel.GetFirstTarget()
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,tc:GetAttribute())
		if tc:IsRelateToEffect(e) and #g>0 then
			local rg=g:Select(tp,1,1,nil)
			Duel.SendtoGrave(rg,REASON_EFFECT)
			if rg:GetFirst():IsLocation(LOCATION_GRAVE) then
				Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
			end
		end	
	end	
	if e:GetLabel()==medium then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			local spos=0
			if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) then spos=spos+POS_FACEUP_ATTACK end
			if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then spos=spos+POS_FACEDOWN_DEFENSE end
			Duel.SpecialSummon(tc,0,tp,tp,false,false,spos)
			if tc:IsFacedown() then
				Duel.ConfirmCards(1-tp,tc)
			end
		end
	end
	if e:GetLabel()==priestess then
		if not Fusion.SummonEffTG(table.unpack(params))(e,tp,eg,ep,ev,re,r,rp,0) then return end
		Duel.BreakEffect()
		Fusion.SummonEffOP(table.unpack(params))(e,tp,eg,ep,ev,re,r,rp)
	end
	if e:GetLabel()==spiderfang then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end