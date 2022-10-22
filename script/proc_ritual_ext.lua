local function WrapTableReturn(func)
	return function(...)
		return {func(...)}
	end
end

Ritual.Target = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,specificmatfilter,requirementfunc,sumpos,extratg)
	location = location or LOCATION_HAND
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp,not requirementfunc)
					local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp,chk) or Group.CreateGroup()
					--if an EFFECT_EXTRA_RITUAL_MATERIAL effect has a forcedselection of its own
					--add that forcedselection to the one of the Ritual Spell, if any
					local extra_eff_g=mg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
					if #extra_eff_g>0 then
						local prev_repl_function=nil
						for tmp_c in extra_eff_g:Iter() do
							local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
							for _,eff in ipairs(effs) do
								local repl_function=eff:GetLabelObject()
								if repl_function and prev_repl_function~=repl_function[1] then
									prev_repl_function=repl_function[1]
									if not forcedselection then
										forcedselection=repl_function[1]
									elseif forcedselection~=repl_function[1] then
										forcedselection=(function()
															local oldfunc=forcedselection
															return function(e,tp,sg,sc)
																local ret1,ret2=oldfunc(e,tp,sg,sc)
																local repl1,repl2=repl_function[1](e,tp,sg,sc)
																return ret1 and repl1,ret2 or repl2
															end
														end)()
									end
								end
							end
						end
					end
					Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
					--- Custom ---
					local extra_loc = Duel.GetFlagEffectLabel(tp,CUSTOM_RITUAL_LOCATION)
					if Duel.GetFlagEffect(tp,CUSTOM_RITUAL_LOCATION)==1 and extra_loc and (location&extra_loc)==0 then
						return Duel.IsExistingMatchingCard(Ritual.Filter,tp,extra_loc,0,1,e:GetHandler(),filter,_type,e,tp,mg,mg2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos)
					else
						return Duel.IsExistingMatchingCard(Ritual.Filter,tp,location,0,1,e:GetHandler(),filter,_type,e,tp,mg,mg2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos)
					end
					--------------
				end
				if extratg then extratg(e,tp,eg,ep,ev,re,r,rp,chk) end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection","specificmatfilter","requirementfunc","sumpos","extratg")

Ritual.Operation = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos)
	location = location or LOCATION_HAND
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local mg=Duel.GetRitualMaterial(tp,not requirementfunc)
				local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp) or Group.CreateGroup()
				--if an EFFECT_EXTRA_RITUAL_MATERIAL effect has a forcedselection of its own
				--add that forcedselection to the one of the Ritual Spell, if any
				local extra_eff_g=mg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
				if #extra_eff_g>0 then
					local prev_repl_function=nil
					for tmp_c in extra_eff_g:Iter() do
						local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
						for _,eff in ipairs(effs) do
							local repl_function=eff:GetLabelObject()
							if repl_function and prev_repl_function~=repl_function[1] then
								prev_repl_function=repl_function[1]
								if not forcedselection then
									forcedselection=repl_function[1]
								elseif forcedselection~=repl_function[1] then
									forcedselection=(function()
														local oldfunc=forcedselection
														return function(e,tp,sg,sc)
															local ret1,ret2=oldfunc(e,tp,sg,sc)
															local repl1,repl2=repl_function[1](e,tp,sg,sc)
															return ret1 and repl1,ret2 or repl2
														end
													end)()
								end
							end
						end
					end
				end
				Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				--- Custom ---
				local prev_loc = location
				local extra_loc = Duel.GetFlagEffectLabel(tp,CUSTOM_RITUAL_LOCATION)
				if Duel.GetFlagEffect(tp,CUSTOM_RITUAL_LOCATION)==1 and extra_loc and (location&extra_loc)==0 then
					if Duel.IsExistingMatchingCard(Ritual.Filter,tp,extra_loc,0,1,e:GetHandler(),filter,_type,e,tp,mg,mg2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos) then 
						if Duel.IsExistingMatchingCard(Ritual.Filter,tp,location,0,1,e:GetHandler(),filter,_type,e,tp,mg,mg2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos) then 
							if Duel.SelectYesNo(tp,aux.Stringid(CUSTOM_RITUAL_LOCATION,1)) then
								Duel.RegisterFlagEffect(tp,CUSTOM_RITUAL_LOCATION,RESET_PHASE+PHASE_END,0,1,extra_loc)
								location = Duel.GetFlagEffectLabel(tp,CUSTOM_RITUAL_LOCATION)
							end
						else
							Duel.RegisterFlagEffect(tp,CUSTOM_RITUAL_LOCATION,RESET_PHASE+PHASE_END,0,1,LOCATION_DECK)
							location = Duel.GetFlagEffectLabel(tp,CUSTOM_RITUAL_LOCATION)
						end
					end
				end
				--------------
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
						if ft>0 and not func then
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
					--check if a card from an "once per turn" EFFECT_EXTRA_RITUAL_MATERIAL effect was selected
					local extra_eff_g=mat:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
					for tmp_c in extra_eff_g:Iter() do
						local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
						for _,eff in ipairs(effs) do
							--if eff is OPT and tmp_c is not returned
							--by the Ritual Spell's exrafil
							--then use the count limit and register
							--the flag to turn the extra eff OFF
							--requires the EFFECT_EXTRA_RITUAL_MATERIAL effect
							--to check the flag in its condition
							local _,max_count_limit=eff:GetCountLimit()
							if max_count_limit>0 and not mg2:IsContains(tmp_c) then
								eff:UseCountLimit(tp,1)
								Duel.RegisterFlagEffect(tp,eff:GetHandler():GetCode(),RESET_PHASE+PHASE_END,0,1)
							end
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
						if tc:IsFacedown() then Duel.ConfirmCards(1-tp,tc) end
						if stage2 then
							stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
						end
					else
						customoperation(mat:Clone(),e,tp,eg,ep,ev,re,r,rp,tc)
					end
					Ritual.SummoningLevel=nil
				end
				--- Custom ---
				location = prev_loc
				--------------
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter","requirementfunc","sumpos")
