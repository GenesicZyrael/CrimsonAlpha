-- Majestic monsters return proc
function Auxiliary.EnableMajesticReturn(c,extracat,extrainfo,extraop,returneff)
	if not extracat then extracat=0 end
	--return
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK | extracat)
	e1:SetDescription(aux.Stringid(27001071,2))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(Auxiliary.MajesticReturnCondition1)
	e1:SetTarget(Auxiliary.MajesticReturnTarget(c,extrainfo))
	e1:SetOperation(Auxiliary.MajesticReturnOperation(c,extraop))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(0)
	e2:SetCondition(Auxiliary.MajesticReturnCondition2)
	c:RegisterEffect(e2)
	if returneff then
		e1:SetLabelObject(returneff)
		e2:SetLabelObject(returneff)
	end	
end
function Auxiliary.MajesticReturnCondition1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsHasEffect(27001071)
end
function Auxiliary.MajesticReturnCondition2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsHasEffect(27001071)
end
function Auxiliary.MajesticReturnSubstituteFilter(c)
	return c:IsCode(27001073) and c:IsAbleToRemoveAsCost()
end
function Auxiliary.MajesticSPFilter(c,mc,e,tp)
	return mc.material and c:IsCode(table.unpack(mc.material)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(21159309)
end
function Auxiliary.MajesticReturnTarget(c,extrainfo)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
			local c=e:GetHandler()
			if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and Auxiliary.MajesticSPFilter(chkc,e,tp) end
			if chk==0 then return true end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectTarget(tp,Auxiliary.MajesticSPFilter,tp,LOCATION_GRAVE,0,1,1,nil,c,e,tp)
			Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
			if extrainfo then extrainfo(e,tp,eg,ep,ev,re,r,rp,chk) end
	end
end
function Auxiliary.MajesticReturnOperation(c,extraop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local tc=Duel.GetFirstTarget()
		local c=e:GetHandler()
		local sc=Duel.GetFirstMatchingCard(Auxiliary.NecroValleyFilter(Auxiliary.MajesticReturnSubstituteFilter),tp,LOCATION_GRAVE,0,nil)
		if sc and Duel.SelectYesNo(tp,aux.Stringid(27001073,2)) then
			Duel.Remove(sc,POS_FACEUP,REASON_COST)
		else
			if Duel.SendtoDeck(c,nil,0,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA) 
			and tc and tc:IsRelateToEffect(e) then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)	
			end
		end
		if c:IsLocation(LOCATION_EXTRA) then
			if extraop then
				extraop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end
---
-- Auxiliary.AddFlipProc = aux.FunctionWithNamedArgs(
-- function(c,desc,category,efftype,limit,cost,condition,target,operation)
	-- local e1=Effect.CreateEffect(c)
	-- if desc then
		-- e1:SetDescription(desc)
	-- end
	-- if efftype then
		-- e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+efftype)
	-- else
		-- e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	-- end
	-- if limit then
		-- e1:SetCountLimit(table.unpack(limit))
	-- end
	-- if cost then
		-- e1:SetCost(cost)
	-- end
	-- if condition then
		-- e1:SetCondition(condition)
	-- end
	-- if target then
		-- e1:SetTarget(target)
	-- end
	-- e1:SetProperty(EFFECT_FLAG_DELAY)
	-- e1:SetCategory(category)
	-- e1:SetOperation(operation)
	-- c:RegisterEffect(e1,false,REGISTER_FLAG_FLIP)
	-- return e1
-- end,"handler","desc","category","efftype","limit","condition","target","operation")
-- ---
-- function Auxiliary.AddOnActivate(c,extracat,limit,filter,location)
	-- -- format: local limit={1,{id,1}} 
	-- if location then location=LOCATION_DECK end
	-- --Activate
	-- local e1=Effect.CreateEffect(c)
	-- e1:SetCategory(CATEGORY_TOHAND | extracat)
	-- e1:SetType(EFFECT_TYPE_ACTIVATE)
	-- e1:SetCode(EVENT_FREE_CHAIN)
	-- if limit then
		-- e1:SetCountLimit(table.unpack(limit))
	-- end
	-- if filter then
		-- e1:SetTarget(AddTarget(filter,location))
		-- e1:SetOperation(AddOperation(filter,location))
	-- end
	-- c:RegisterEffect(e1)
-- end

-- function AddTarget(c,filter,location)
	-- return function(e,tp,eg,ep,ev,re,r,rp,chk)
		-- if chk==0 then return Duel.IsExistingMatchingCard(filter,tp,location,0,1,nil) end
		-- Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,location)
	-- end
-- end
-- function AddOperation(c,filter,location)
	-- return function(e,tp,eg,ep,ev,re,r,rp)
		-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- local g=Duel.SelectMatchingCard(tp,filter,tp,location,0,1,1,nil)
		-- if #g>0 then
			-- Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- Duel.ConfirmCards(1-tp,g)
		-- end
	-- end
-- end

-- aux.XenoMatCheckSummoned = "Cannot be used as material, except for the Special Summon of a ..."
--	-- matfilter: Required function 
function Auxiliary.XenoMatCheckSummoned(c,matfilter)
	if not matfilter then return false end
	local x1=Effect.CreateEffect(c)
	x1:SetType(EFFECT_TYPE_SINGLE)
	x1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	x1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	x1:SetValue(matfilter)
	c:RegisterEffect(x1)	
	local x2=x1:Clone()
	x2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(x2)
	local x3=x1:Clone()
	x3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(x3)
	local x4=x1:Clone()
	x4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(x4)
end

-- aux.XenoMatCheckOthers = "... all other materials are ..."
--	-- matfilter: Required function
function Auxiliary.XenoMatCheckOthers(c,matfilter)
	if not matfilter then return false end
	local x1=Effect.CreateEffect(c)
	x1:SetType(EFFECT_TYPE_SINGLE)
	x1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	x1:SetCode(EFFECT_FUSION_MAT_RESTRICTION)
	x1:SetValue(matfilter)
	c:RegisterEffect(x1)
	local x2=x1:Clone()
	x2:SetCode(EFFECT_SYNCHRO_MAT_RESTRICTION)
	c:RegisterEffect(x2)
	local x3=x1:Clone()
	x3:SetCode(EFFECT_XYZ_MAT_RESTRICTION)
	c:RegisterEffect(x3)	
	local x4=x1:Clone()
	x4:SetCode(CUSTOM_LINK_MAT_RESTRICTION)
	c:RegisterEffect(x4)
end
