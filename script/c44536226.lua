--Eria the Blizzard Charmer
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--tohand
	-- local e2=Effect.CreateEffect(c)
	-- e2:SetDescription(aux.Stringid(id,0))
	-- e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	-- e2:SetType(EFFECT_TYPE_IGNITION)
	-- e2:SetRange(LOCATION_HAND)
	-- e2:SetCountLimit(1,id)
	-- e2:SetCost(s.thcost)
	-- e2:SetTarget(s.thtg)
	-- e2:SetOperation(s.thop)
	-- c:RegisterEffect(e2)	
end
s.listed_series={0x14d,0xc0}
s.listed_names={26141622}

