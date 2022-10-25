-- regeff_list is a global table that we can add additional entries to, from outside of utility.lua
regeff_list={[REGISTER_FLAG_DETACH_XMAT]=511002571,[REGISTER_FLAG_CARDIAN]=511001692,[REGISTER_FLAG_THUNDRA]=12081875,[REGISTER_FLAG_ALLURE_LVUP]=511310036}
--for additional registers
local regeff=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	if c:IsStatus(STATUS_INITIALIZING) and not e then
		error("Parameter 2 expected to be Effect, got nil instead.",2)
	end
	local reg_e = regeff(c,e,forced)
	if not reg_e then
		return nil
	end
	local reg={...}
	local resetflag,resetcount=e:GetReset()
	for _,val in ipairs(reg) do
		local setcode=regeff_list[val]
		if setcode==nil then return end
		local prop=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE
		if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(prop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
		e2:SetCode(setcode)
		e2:SetLabelObject(e)
		e2:SetLabel(c:GetOriginalCode())
		if resetflag and resetcount then
			e2:SetReset(resetflag,resetcount)
		elseif resetflag then
			e2:SetReset(resetflag)
		end
		c:RegisterEffect(e2)
	end
	return reg_e
end

local function CheckEffectUniqueCheck(c,tp,code)
	if not (aux.FaceupFilter(Card.IsCode,code) and c:IsHasEffect(EFFECT_UNIQUE_CHECK)) then 
		return false
	end
	return true
end
local function AdjustOp(self,opp,limit,code,location)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local phase=Duel.GetCurrentPhase()
		local rm=Group.CreateGroup()
		if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
		if self then
			local g=Duel.GetMatchingGroup(CheckEffectUniqueCheck,tp,location,0,nil,tp,code)
			local rg=Group.CreateGroup()
			if #g>0 then
				g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,code),tp,location,0,nil)
				local ct=#g-limit
				if #g>limit then
					Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(code,1))
					rg=g:Select(1-tp,ct,ct,nil):GetFirst()
					Duel.HintSelection(rg,true)
				end
			end
			rm:Merge(rg)
		end
		if opp then
			local g=Duel.GetMatchingGroup(CheckEffectUniqueCheck,tp,0,location,nil,tp,code)
			local rg=Group.CreateGroup()
			if #g>0 then
				g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,code),tp,0,location,nil)
				local ct=#g-limit
				if #g>limit then
					Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(code,1))
					rg=g:Select(1-tp,ct,ct,nil):GetFirst()
					Duel.HintSelection(rg,true)
				end
			end
			rm:Merge(rg)
		end
		if #rm>0 then			
			Duel.SendtoGrave(rm,REASON_RULE)
			Duel.Readjust()
		end
	end
end
local function SummonLimit(limit,code,location)
	return function(e,c,sump,sumtype,sumpos,targetp)
		if not c:IsCode(code) then return false end
		local g=Duel.GetMatchingGroupCount(CheckEffectUniqueCheck,targetp or sump,location,0,1,targetp or sump,code) 
		if g>0 then
			local g=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,code),targetp or sump,location,0,1)
			return g>limit-1
		end
	end
end
function Card.SetLimitIdOnField(c,self,opp,limit,code,location)
	if location then
		location=location
	else
		location=LOCATION_ONFIELD
	end
	--Adjust
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_ADJUST)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(AdjustOp(self,opp,limit,code,location))
	c:RegisterEffect(e1,false,CUSTOM_REGISTER_LIMIT)
	--Cannot Normal/Flip/Special Summon
	local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
		e2:SetCode(EFFECT_CANNOT_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,1)
		e2:SetTarget(SummonLimit(limit,code,location))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
		e4:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
		e4:SetValue(POS_FACEDOWN)
	c:RegisterEffect(e4)
end
