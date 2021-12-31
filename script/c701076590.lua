--Dimension Dice Magician
local s,id=GetID()
local sid=300102004
function s.initial_effect(c)
	c:SetUniqueOnField(1,1,id)
	Link.AddProcedure(c,s.filter,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_TOSS_DICE_CHOOSE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation("dice",Duel.GetDiceResult,Duel.SetDiceResult,function(tp) Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(sid,3)) return Duel.AnnounceNumber(tp,1,2,3,4,5,6) end))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TOSS_COIN_CHOOSE)
	e2:SetOperation(s.operation("coin",Duel.GetCoinResult,Duel.SetCoinResult,function(tp) Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(sid,4)) return 1-Duel.AnnounceCoin(tp) end))
	c:RegisterEffect(e2)
end
function s.filter(c,lc,sumtype,tp)
	return c:IsType(TYPE_EFFECT,lc,sumtype,tp) and ( c.roll_dice or c.toss_coin )
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(ep,id)==0 
		and ep==tp
end
function s.operation(typ,func1,func2,func3)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local dc={func1()}
		local ct=(ev&0xff)+(ev>>16)
		local val=2
		local idx=1
		local tab={}
		if Duel.GetFlagEffect(ep,id)>0 then return end
		if Duel.SelectEffectYesNo(ep,e:GetHandler()) then
			Duel.SetLP(ep,Duel.GetLP(ep)-2000)
			Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1)
			if ct>1 then
				if typ=="dice" then
					Duel.Hint(HINT_SELECTMSG,ep,aux.Stringid(sid,1))
					val=6
				else
					Duel.Hint(HINT_SELECTMSG,ep,aux.Stringid(sid,2))
				end
				for i=1,ct do
					table.insert(tab,aux.Stringid(id,i))
				end
				for i=1,val do
					dc[i]=math.abs(math.random(val))
				end
				idx=Duel.SelectOption(ep,table.unpack(tab))
				idx=idx+1
			end
			dc[idx]=func3(ep)
			func2(table.unpack(dc))
		else
			if typ=="dice" then
				val=6
			end
			for i=1,val do
				dc[i]=math.abs(math.random(val))
			end
			func2(table.unpack(dc))
		end
	end
end