Ritual.Target = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,specificmatfilter,requirementfunc,sumpos)
	location = location or LOCATION_HAND
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp,not requirementfunc)
					local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp,chk) or Group.CreateGroup()
					Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
					--- START of INSERT: CrimsonAlpha
					local fg=Group.CreateGroup()
					for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,27200101)}) do
						fg:AddCard(pe:GetHandler())
					end
					if #fg>0 then
						location = location + LOCATION_DECK
						return Duel.IsExistingMatchingCard(Ritual.Filter,tp,location,0,1,e:GetHandler(),filter,_type,e,tp,mg,mg2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos)
							or Duel.IsExistingMatchingCard(Ritual.Filter,tp,LOCATION_DECK,0,1,e:GetHandler(),filter,_type,e,tp,mg,mg2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos)
					else
						return Duel.IsExistingMatchingCard(Ritual.Filter,tp,location,0,1,e:GetHandler(),filter,_type,e,tp,mg,mg2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos)
					end
					--- END of INSERT: CrimsonAlpha						
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection","specificmatfilter","requirementfunc","sumpos")

Ritual.Operation = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos)
	location = location or LOCATION_HAND
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local mg=Duel.GetRitualMaterial(tp,not requirementfunc)
				local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp) or Group.CreateGroup()
				Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				--- START of INSERT: CrimsonAlpha
				local fg=Group.CreateGroup()
				for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,27200101)}) do
					fg:AddCard(pe:GetHandler())
				end
				local g=Duel.GetMatchingGroup(Ritual.Filter,tp,location,0,nil,filter,_type,e,tp,mg,mg2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos)
				if #fg>0 then
					local g2=Duel.GetMatchingGroup(Ritual.Filter,tp,LOCATION_DECK,0,nil,filter,_type,e,tp,mg,mg2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos)
					if #g>0 then
						if #g2>0 then 
							if (location ~= LOCATION_DECK) and Duel.SelectYesNo(tp,aux.Stringid(27200101,0)) then
								location = LOCATION_DECK
								local fc=nil
								if #fg==1 then
									fc=fg:GetFirst()
								else
									fc=fg:Select(tp,1,1,nil)
								end
								Duel.Hint(HINT_CARD,0,fc:GetCode())
								fc:RegisterFlagEffect(27200101,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)							
							end
						end	
					else
						location = LOCATION_DECK
						local fc=nil
						if #fg==1 then
							fc=fg:GetFirst()
						else
							fc=fg:Select(tp,1,1,nil)
						end
						Duel.Hint(HINT_CARD,0,fc:GetCode())
						fc:RegisterFlagEffect(27200101,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)					
					end					
				end
				--- END of INSERT: CrimsonAlpha					
				local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Ritual.Filter),tp,location,0,1,1,e:GetHandler(),filter,_type,e,tp,mg,mg2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos)
				if #tg>0 then
					local tc=tg:GetFirst()
					local lv=(lv and (type(lv)=="function" and lv(tc)) or lv) or tc:GetLevel()
					lv=math.max(1,lv)
					Ritual.SummoningLevel=lv
					local mat=nil
					mg:Match(Card.IsCanBeRitualMaterial,tc,tc)
					mg:Merge(mg2-tc)
					if specificmatfilter then
						mg:Match(specificmatfilter,nil,tc,mg,tp)
					end
					if tc.ritual_custom_operation then
						tc:ritual_custom_operation(mg,forcedselection,_type)
						mat=tc:GetMaterial()
					else
						local func=forcedselection and WrapTableReturn(forcedselection) or nil
						if tc.ritual_custom_check then
							if forcedselection then
								func=aux.tableAND(WrapTableReturn(tc.ritual_custom_check),forcedselection)
							else
								func=WrapTableReturn(tc.ritual_custom_check)
							end
						end
						if tc.mat_filter then
							mg:Match(tc.mat_filter,tc,tp)
						end
						if not mg:IsExists(Card.IsLocation,1,nil,LOCATION_OVERLAY) and ft>0 and not func then
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
							if _type==RITPROC_EQUAL then
								mat=mg:SelectWithSumEqual(tp,requirementfunc or Card.GetRitualLevel,lv,1,#mg,tc)
							else
								mat=mg:SelectWithSumGreater(tp,requirementfunc or Card.GetRitualLevel,lv,tc)
							end
						else
							mat=aux.SelectUnselectGroup(mg,e,tp,1,lv,Ritual.Check(tc,lv,func,_type,requirementfunc),1,tp,HINTMSG_RELEASE,Ritual.Finishcon(tc,lv,requirementfunc,_type))
						end
					end
					if not customoperation then
						tc:SetMaterial(mat)
						if extraop then
							extraop(mat:Clone(),e,tp,eg,ep,ev,re,r,rp,tc)
						else
							Duel.ReleaseRitualMaterial(mat)
						end
						Duel.BreakEffect()
						Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,sumpos)
						tc:CompleteProcedure()
						if stage2 then
							stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
						end
					else
						customoperation(mat:Clone(),e,tp,eg,ep,ev,re,r,rp,tc)
					end
					Ritual.SummoningLevel=nil
				end
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter","requirementfunc","sumpos")
