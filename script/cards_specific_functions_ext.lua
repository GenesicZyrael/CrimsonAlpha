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

-- Assault Mode Activate Summon: Made into a global function for future cards
if not aux.AssaultModeProcedure then
	aux.AssaultModeProcedure = {}
	AssaultMode = aux.AssaultModeProcedure
end
if not AssaultMode then
	AssaultMode = aux.AssaultModeProcedure
end

AssaultMode.CreateProc = aux.FunctionWithNamedArgs(
function(c,location,extracat,extrainfo,extraop)
	if not extracat then extracat=0 end
	-- Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON | extracat)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(AssaultMode.Cost)
	e1:SetTarget(AssaultMode.Target(c,extrainfo,location))
	e1:SetOperation(AssaultMode.Operation(c,extraop,location))
	return e1
end,"handler","location","extracat","extrainfo","extraop")

function AssaultMode.Cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function AssaultMode.filter(c,tc,e,tp)
	local code=tc:GetCode()
	local ocode=tc:GetOriginalCode()
	local nocheck=false
	if c:IsLocation(LOCATION_GRAVE) then nocheck=true end
	if tc.assault_mode_all then
		return c:IsSetCard(0x104f) and c:IsCanBeSpecialSummoned(e,0,tp,true,nocheck)
	else
		return c:IsSetCard(0x104f) and c.assault_mode 
			and (c.assault_mode==code or c.assault_mode==ocode)
			and c:IsCanBeSpecialSummoned(e,0,tp,true,nocheck)
	end
end
function AssaultMode.cfilter(c,e,tp,ft,location)
	if c:IsType(TYPE_SYNCHRO) and (ft>0 or (c:GetSequence()<5 and c:IsControler(tp))) then
		return Duel.IsExistingMatchingCard(AssaultMode.filter,tp,location,0,1,nil,c,e,tp)		
	end
end
function AssaultMode.Target(c,extrainfo,location)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if chk==0 then
			if e:GetLabel()~=1 then return false end
			e:SetLabel(0)
			return ft>-1 and Duel.CheckReleaseGroupCost(tp,AssaultMode.cfilter,1,false,nil,nil,e,tp,ft,location)
		end
		local rg=Duel.SelectReleaseGroupCost(tp,AssaultMode.cfilter,1,1,false,nil,nil,e,tp,ft,location)
		Duel.SetTargetCard(rg:GetFirst())
		Duel.Release(rg,REASON_COST)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
		if extrainfo then extrainfo(e,tp,eg,ep,ev,re,r,rp,chk) end
	end
end
function AssaultMode.Operation(c,extraop,location)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local c=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,AssaultMode.filter,tp,location,0,1,1,nil,c,e,tp,location):GetFirst()
		local nocheck=false
		if tc:IsLocation(LOCATION_GRAVE) then nocheck=true end
		if tc and Duel.SpecialSummon(tc,0,tp,tp,true,nocheck,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
		if c:IsLocation(LOCATION_MZONE) then
			if extraop then
				extraop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end
