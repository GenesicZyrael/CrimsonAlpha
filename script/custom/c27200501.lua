-- Ritual Beast Training
-- Add 1 "Ritual Beast" monster from your Deck to your hand. 
-- If this card is in your GY: You can banish this card and 1 other "Ritual Beast" card from your GY to activate one of these effects; 
--● Banish 1 "Ritual Beast" monster from your hand or GY.
--● Target 1 face-up monster you control; It is also treated as a "Spiritual Beast Tamer" monster while face-up on the field. 
--You can only use 1 "Ritual Beast Training" effect per turn, and only once that turn. 
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_ACTIVATE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1,id)
		e1:SetTarget(s.ActTarg)
		e1:SetOperation(s.ActOp)
	c:RegisterEffect(e1)
	--Banish
	local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetRange(LOCATION_GRAVE)
		e2:SetCountLimit(1,id)
		e2:SetCost(s.BanCost)
		e2:SetTarget(s.BanTarg)
		e2:SetOperation(s.BanOp)
	c:RegisterEffect(e2)
end
s.listed_series={0xb5,0x30b5}
-- {Activation Effect: Search Ritual Beast Monster}
function s.ActFilter(c)
	return c:IsSetCard(0xb5) 
		and c:IsType(TYPE_MONSTER) 
		and c:IsAbleToHand()
end
function s.ActTarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.ActFilter,tp,LOCATION_DECK,0,1,nil) 
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.ActOp(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.ActFilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
-- {Graveyard Effect: Activate 1 of these effects}
function s.CostFilter(c)
	return c:IsSetCard(0xb5) 
		and c:IsAbleToRemoveAsCost()
end
function s.BanCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.IsExistingMatchingCard(s.CostFilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.CostFilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.TargFilter1(c)
	return c:IsSetCard(0xb5) 
		and c:IsSummonable(true,nil)
end
function s.TargFilter2(c)
	return c:IsSetCard(0xb5) 
		and c:IsType(TYPE_MONSTER)
		and c:IsAbleToRemove()
end
function s.TargFilter3(c)
	return c:IsFaceup() 
		and not c:IsSetCard(0x30b5)
end
function s.BanTarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.TargFilter1,tp,LOCATION_HAND,0,1,nil)
			or Duel.IsExistingMatchingCard(s.TargFilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil)
			or Duel.IsExistingTarget(s.TargFilter3,tp,LOCATION_MZONE,0,1,nil)
	end
	local off=1
	local ops={}
	local opval={}
	-- if Duel.IsExistingMatchingCard(s.TargFilter1,tp,LOCATION_HAND,0,1,nil) then
		-- ops[off]=aux.Stringid(id,0)
		-- opval[off-1]=1
		-- off=off+1
	-- end
	if Duel.IsExistingMatchingCard(s.TargFilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil) then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if Duel.IsExistingTarget(s.TargFilter3,tp,LOCATION_MZONE,0,1,nil) then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=3
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		e:SetLabel(1)
	elseif opval[op]==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		e:SetLabel(2)
	elseif opval[op]==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		e:SetLabel(3)
		Duel.SelectTarget(tp,s.TargFilter3,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
function s.BanOp(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local g=Duel.SelectMatchingCard(tp,s.TargFilter1,tp,LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.Summon(tp,tc,true,nil)
		end	
	elseif e:GetLabel()==2 then
		local g=Duel.SelectMatchingCard(tp,s.TargFilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	elseif e:GetLabel()==3 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(tc)
				e1:SetDescription(aux.Stringid(id,3))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_ADD_SETCODE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetValue(0x30b5)
				e1:SetReset(RESET_EVENT+0x1fe0000)
			tc:RegisterEffect(e1)
		end
	end
end