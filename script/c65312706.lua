--Advanced Tactics
--Special Summon 1 Level 10 monster that requires 3 or more Tributes to be Normal Summoned/Set from your hand in face-down Defense Position, ignoring its Summoning Conditions, and if you do, add 1 Level 10 monster with the same name from your Deck. If you would Tribute Summon during this turn, you can use 1 monster with the same name for the entire Tribute. For the rest of this turn after you activate this card, you cannot Special Summon from the Extra Deck. You can only activate 1 "Advanced Tactics" once per turn.
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
