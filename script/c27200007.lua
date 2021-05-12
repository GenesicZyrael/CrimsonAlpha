--Naturia Tamer Zefrawendi
-- [ Pendulum Effect ]
-- You cannot Pendulum Summon monsters, except "Naturia" and "Zefra" monsters. This effect cannot be negated. If you Pendulum Summon 3 or more monsters, including a "Naturia" or "Zefra" monster: You can add "Naturia" or "Zefra" monsters from your GY or face-up Extra Deck to your hand up to the number of "Zefra" cards in your Pendulum Zones.
-- ----------------------------------------
-- [ Monster Effect ]
-- While you control no cards: You can banish this card from your hand, GY, or face-up Extra Deck; place up to 2 (min. 1) "Zefra" Pendulum Monster(s) from your Deck or face-up Extra Deck to your Pendulum Zone(s). You cannot Special Summon monsters while you control a card(s) in the Pendulum Zone(s) placed by this effect, except "Naturia" and "Zefra" monsters. You can only use this effect of "Naturia Tamer Zefrawendi" once per turn.local s,id=GetID()
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
end
s.listed_series={0x2a,0xc4}
-- {Pendulum Summon Restriction: Zefra & Constellar}
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x2a) or c:IsSetCard(0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end