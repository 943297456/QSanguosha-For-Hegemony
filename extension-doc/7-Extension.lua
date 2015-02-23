--���ܽ���6��LuaAPI����չ
--[[
	��Һã��������֣�Xusine��
	����һ���½����ҽ��������о�һ�¹�ս0.8.3֮��汾��Lua�ӿڵ������չ��
	���½��ǽ��������ܹ���������ȷ��д����Lua�������϶����е������չ��
	�����û�нϺõ�Lua�������������Ķ����½ڵ�ʱ�����һЩ������
	���ˣ��ϻ�����˵�����ǿ�ʼ�ɡ�
]]
--[[
	1.expand_pile
	����ڽ�����Ϊ����ʱ����΢����һ�㣬��ʵ����һ������Ϊ���󶨵�Pile��
	���Ķ��������ݵ�ʱ������ȥ����һ�ѵ˰�������Ϯ�Ŀ�С���
	�ڴ�ͳ����ɱ�У����ְ�Pile�ϵ��Ƶ���ĳ����ʹ�ö����ü��ܿ�����askForAGʵ�ֵġ�
	�Ҳ�˵���ַ�����д����ʱ���鷳���û�����Ҳ�ǲ������⡣
	Ȼ���������ַ�ʽ����ʹ�ü��ܼ����ˡ�
	���ǵ���һ����������һ�����ܡ���ʸ��ô��������ǿ��԰����ĳ�����һ��д����
]]

--[[
	��ʸ��ÿ����ĺ�ɫ�������ö�ʧȥʱ����ɽ���Щ����������佫���ϳ�Ϊ���������غ�����ɽ����š��������ɡ���и�ɻ���ʹ�á�
]]

devJianshiVS = sgs.CreateViewAsSkill{ --��ϸ������Բο�lua\sgs_ex.lua
	name = "devJianshi",
	n = 2,
	expand_pile = "devJianshi", --���������expand_pile��Ա���ڵ����ť��ʱ��ͻ��Pile�ƶ��������С�
	--���Ҫ����Pile�Ļ��������ö��Ÿ�����
	view_filter = function(self, selected, to_select)
		if #selected >= 2 or to_select:hasFlag("using") then return false end
		local pat = ".|.|.|devJianshi"
		--expattern �������һ������λ�ÿ�����Pile�����֡�
		if string.endsWith(pat, "!") then
			if sgs.Self:isJilei(to_select) then return false end
			pat = string.sub(pat, 1, -2)
		end
		return sgs.Sanguosha:matchExpPattern(pat, sgs.Self, to_select)
	end,
	view_as = function(self,cards) 
		if #cards == 2 then
			local ac = sgs.Sanguosha:cloneCard("nullification")
			ac:setSkillName("devJianshi")
			ac:setShowSkill("devJianshi")
			ac:addSubcard(cards[1])
			ac:addSubcard(cards[2])
			return ac
		end
	end, 
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "nullification" and player:getPile("devJianshi"):length() > 1
	end,
	enabled_at_nullification = function(self, player)
		return player:getPile("devJianshi"):length() > 1 
	end
}
devJianshi = sgs.CreateTriggerSkill{
	name = "devJianshi",
	view_as_skill = devJianshiVS,
	events = {sgs.BeforeCardsMove},
	can_trigger = function(self, event, room, player, data)
		if player and player:isAlive() and player:hasSkill(self:objectName()) then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() ~= player:objectName() then return "" end
			if bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD then
				for i = 0, move.card_ids:length()-1, 1 do
					local id = move.card_ids:at(i)
					card = sgs.Sanguosha:getCard(id)
					if move.from_places:at(i) == sgs.Player_PlaceHand or move.from_places:at(i) == sgs.Player_PlaceEquip then
						if card:isBlack() then							
							return self:objectName()
						end
					end					
				end
			end
			return ""
		end
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke(self:objectName(), data) then
			return true 
		end
		return false
	end ,
	on_effect = function(self, event, room, player, data)
		local move = data:toMoveOneTime()
		local card
		local dummy = sgs.Sanguosha:cloneCard("jink") 
		for i = 0, move.card_ids:length()-1, 1 do
			local id = move.card_ids:at(i)
			card = sgs.Sanguosha:getCard(id)
			if move.from_places:at(i) == sgs.Player_PlaceHand or move.from_places:at(i) == sgs.Player_PlaceEquip then
				if card:isBlack() then							
					dummy:addSubcard(id)
				end
			end					
		end
		for _,id in sgs.qlist(dummy:getSubcards()) do
			move.card_ids:removeOne(id)
		end
		data:setValue(move) --�����data��������һ����Ҫ����setValue
		player:addToPile("devJianshi", dummy:getSubcards())
		dummy:deleteLater() --��ס��DummyCard����һ��Ҫɾ�������������ڴ�й©��
	end,
}
--[[
	ͨ�����������ӵ���ᣬ���Ƿ���ܵ���expand_pile���������ã�
	��ʵ��expand_pile�����û�������Щ������������һ��������ص�pile:
	2.%pile
	��ȥ��һ���о��Žǵ�Ⱥ�ۣ����Ժ뷨��
	ʲô���ñ������ϵ�Pile������������˼��ɡ�
	�ǵģ���expand_pile��������Pile��ʱ�������ǰ׺%�Ļ�������������Ѱ�����PileȻ���ƶ������ơ�
	��������������һ�����ܡ�
]]

--[[
	ʩ��:	���������غϿ�ʼʱ��������佫����û���ƣ�����Է����ƶѶ�X���ƣ������еĻ����ƺ͡���и�ɻ����������佫���ϣ����������������ƶ�.(XΪ��ǰ����������ͬ�Ľ�ɫ*3)
	��������ֻҪ����佫�������ƣ���ӵ�С������顱
	#�����飺
	����һ������������ͬ�Ľ�ɫ��Ҫʹ�û��ߴ����ʱ��������佫��������Ҫ���ƣ����Դ�����佫����ʹ�û���֮��
]]

--[[
	������
	������ܿ���˵��һ���Ƚϸ��ӵļ����ˣ��������ľ��飬����Ӧ�ÿ���ʹ��expand_pile��
	Ϊ����ǿ�û����飬���ǻ���Ҫ���ƺ�enable_at_*****������
	�������£�
]]

devShiren = sgs.CreateTriggerSkill{
	name = "devShiren$" ,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if player and player:isAlive() and player:hasSkill(self:objectName()) then
			if player:getPhase() == sgs.Player_Start and player:getPile("devShiren"):length() < player:getPlayerNumWithSameKingdom(self:objectName()) then
				return self:objectName()
			else
				return ""
			end
		end
		return ""
	end ,
	on_cost = function(self, event, room, player, data)
		if player:hasShownSkill(self) or player:askForSkillInvoke(self:objectName(), data) then
			room:notifySkillInvoked(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			return true 
		end
		return false
	end ,
	on_effect = function(self, event, room, player, data)
		local shiren = room:getNCards(player:getPlayerNumWithSameKingdom(self:objectName())*3)
		for _,id in sgs.qlist(shiren)do
			local c = sgs.Sanguosha:getCard(id)
			if c:isKindOf("BasicCard") or c:isKindOf("Nullification") then
				player:addToPile("devShiren",c,true)
			else
				room:throwCard(id,player,nil,self:objectName())
			end
		end
		return false
	end ,
}
--[[
	����ļ�����Ϊ����Pile����װ�ơ�
]]

devShirenAddSkill = sgs.CreateTriggerSkill{ --���������Ϊ����Ӽ���
	name = "devShirenAddSkill" ,
	global = true,
	events = {sgs.GeneralShown,sgs.EventLoseSkill},
	can_trigger = function(self, event, room, player, data)
		if player and player:isAlive() then
			if event == sgs.GeneralShown then
				local source = room:findPlayerBySkillName("devShiren")
				if source and source:isAlive() and source:hasShownSkill("devShiren") then
					for _,p in sgs.qlist(room:getAlivePlayers())do
						if p:isFriendWith(source) and not p:hasSkill("devShirenAsk") then
							room:attachSkillToPlayer(p,"devShirenAsk")
							source:speak(p:screenName())
						end
					end
				end
			else
				local skill_name = data:toString()
				if skill_name == "devShiren" then
					for _,p in sgs.qlist(room:getAlivePlayers())do
						if p:hasSkill("devShirenAsk") then
							room:detachSkillFromPlayer(p,"devShirenAsk")
						end
					end
				end
			end
		end
		return ""
	end ,
}
addSkillToEngine(devShirenAddSkill) --���Ķ��������������������Ϊ�˰Ѽ��ܼ���Engine

devShirenAsk = sgs.CreateOneCardViewAsSkill{ --��Ϊ�����������ܵĺ��ġ�
	name = "devShirenAsk",
	expand_pile = "devShiren,%devShiren",
	--����ȱ�ٵ�expand_pile,�ö��Ÿ�������д���
	--���е�һ��devShiren�Ǹ������õ�
	--�ڶ���%devShiren���Ǹ�����ͬ������ɫ�õġ�
	view_filter = function(self,to_select)
		local pat = ".|.|.|devShiren,%devShiren" --��expand_pile����Ӧ��Pattern
		if not sgs.Sanguosha:matchExpPattern(pat, sgs.Self, to_select) then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then --������ʹ�õ����
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if to_select:match(pattern) or (pattern == "nullification" and to_select:isKindOf("Nullification")) then
				return true
			else
				return false
			end
		else --����ʹ�õ����
			if to_select:isAvailable(sgs.Self) then
				return true
			else
				return false
			end
		end
		return false
	end,
	view_as = function(self,origin) --ֱ�ӷ���ԭ���������ı�
		return origin
	end,
	enabled_at_play = function(self, player) --����ܲ�������ʹ��
		local bool = false
		local lord = player:getLord()
		if lord == nil then return false end
		local pile = lord:getPile("devShiren")
		for _,id in sgs.qlist(pile)do
			local c = sgs.Sanguosha:getCard(id)
			if c:isAvailable(player) then
				bool = true
				break
			end
		end
		return bool
	end,
	enabled_at_response = function(self, player, pattern) --�������
		sgs.ShirenPattern = pattern
		local bool = false
		local lord = player:getLord()
		local pile = lord:getPile("devShiren")
		for _,id in sgs.qlist(pile)do
			local c = sgs.Sanguosha:getCard(id)
			if pattern == "nullification" then
				if c:isKindOf("Nullification") then
					bool = true
					break
				end
			end
			if c:match(pattern) then --�м������match����Lua��match��������Card::match
				bool = true
				break
			end
		end
		return bool
	end,
	enabled_at_nullification = function(self,player) --��Ӧ��и�ɻ�
		local lord = player:getLord()
		if lord then
			local pile = lord:getPile("devShiren")
			for _,id in sgs.qlist(pile)do
				local c = sgs.Sanguosha:getCard(id)
				if c:isKindOf("Nullification") then
					return true
				end
			end
		end
		return false
	end,
}
--[[
	�����������������о������˵Ļ�����������Ϳ��Լ������ǿ�������^_^
	���������������������뿪����Ŀ�����ϵ���֡� Email : xusine@mogara.org ��
	��Ȼ���о�����Ҳ��Ҫ�����Լ�����һЩ�������Ծͺ��ˡ�
	�õģ���������������һ��Pile��
	3.&Pile
	Pile����&��ͷ�Ķ�����ľţ������������ʹ�úʹ��ʱ�ᱻ��Ϊ���ơ�
	����������һ�����ܣ�
]]

--[[
	��ϣ�ÿ��һ����ɫ��ʼ�ж�ʱ������԰��ƶѶ������Ʒŵ��佫���ϣ���֮Ϊ������ơ�������Խ�����Ƶ�������ʹ�û�����
]]

--���ϻ��ˣ�ֱ���ϼ��ܣ�

devZhenduan = sgs.CreateTriggerSkill{
	name = "devZhenduan",
	events = {sgs.StartJudge},
	can_trigger = function(self, event, room, player, data)
		if player and player:isAlive() then
			local source = room:findPlayerBySkillName(self:objectName())
			if source and source:isAlive() then
				return self:objectName(),source
			end
		end
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		return room:askForSkillInvoke(ask_who,self:objectName(),data)
	end,
	on_effect = function(self, evnet, room, player, data,ask_who)
		ask_who:addToPile("&devZhenduan",room:getNCards(2)) --����缧��ǳ�ϲ�С���
		--[[
			��ע�������&devZhenduan���Pile���ڷ���Ͳ�����ʱ��&���뱣����
		]]
		return false
	end,
}

--[[
	��ʵ����ʹ����������Pile������ɲ��ٿ������ѵĹ�����
	ֵ��ע����ǣ�����Lua��Ϊ����&Pile��Ҫ�ֶ�����Ϊ���и㶨��
	��������������һ���ڿͻ����ܹ�ʹ�õĶ�����
	4.ServerInfo
	����˼�壬���Ƿ�������Ϣ�����Ķ������£�
]]
struct ServerInfoStruct {
    const QString Name; --����������
    const QString GameMode; --��Ϸģʽ������أ���ο�Դ����
    const int OperationTimeout; --����ʱ��
    const int NullificationCountDown; --��и�ɻ�ʱ��
    const QStringList Extensions; --��չ��
    const bool RandomSeat; --�����λ
    const bool EnableCheat; --��������
    const bool FreeChoose; --����ѡ��
    const bool ForbidAddingRobot; --��ֹAI
    const bool DisableChat; --��ֹ����
    const bool FirstShowingReward; --��������

    const bool DuringGame; --����Ϸ��
};

extern ServerInfoStruct ServerInfo;

--����C++���룬��Lua�ļ�����ʾ�����ô�����
--��Ȼ����Ҳ���Բο�swig/sanguosha.i �ļ���
--[[
	�Ӷ�����ԣ����ǿ���ͨ��sgs.ServerInfo����������ṹ�壬����˵
	sgs.ServerInfo.Name�����
	��������Ƚϼ򵥣���������Ͳ���ϸ�����ˡ�
	5.SkipGameRule
	�������Ͽ�����������Ϸ����������������һ�����ܡ�
]]

--[[
	���ɣ���������ÿ����ʹ�á�ɱ��ָ��һ����ɫʱ��������Ŀ���ɫʹ�á�ɱ������Ӧ��
]]
--[[
	������
	������ܸı�����������Ϸ���̣���������Ҫ��SkipGameRule����ɡ�
	�������£�
]]
devCaiyi = sgs.CreateTriggerSkill{
	name = "devCaiyi",
	events = {sgs.SlashProceed},
	relate_to_place = "head",
	can_trigger = function(self, event, room, player, data)
		local effect = data:toSlashEffect()
		if effect.from and effect.from:isAlive() and effect.from:hasSkill(self:objectName()) then
			return self:objectName()
		end
	end ,
	on_cost = function(self, event, room, player, data)
		local ai_data = sgs.QVariant()
		ai_data:setValue(data:toSlashEffect().to)
		if room:askForSkillInvoke(player,self:objectName(),ai_data) then
			return true
		end
	end ,
	on_effect = function(self, evnet, room, player, data) --��Щ��������GameRule.cpp
		local effect = data:toSlashEffect()
		if effect.jink_num == 1 then
            local jink = room:askForCard(effect.to, "slash", "slash-slash:" .. effect.from:objectName(), data, sgs.Card_MethodResponse, effect.from)
			----���������handling_method��һЩ���⣬�һ�������ɴ����
			if room:isJinkEffected(effect.to, jink) then else jink = nil end
            room:slashResult(effect, jink)
        else
            local jink = sgs.Sanguosha:cloneCard("slash")
            local asked_jink = nil
            for i = 1,effect.jink_num,1 do
				local prompt
				if i == 1 then
					prompt = ("@multi-slash%s:%s::%d"):format("-start",effect.from:objectName(),i)
				else
					prompt = ("@multi-slash%s:%s::%d"):format("",effect.from:objectName(),i)
				end
                asked_jink = room:askForCard(effect.to, "slash", prompt, data, sgs.Card_MethodResponse, effect.from)
				--ͬ�ϡ�
                if ( not room:isJinkEffected(effect.to, asked_jink)) then
					jink:deleteLater()
                    jink = nil
					break
                else
                    jink:addSubcard(asked_jink:getEffectiveId())
                end
            end
            room:slashResult(effect, jink)
        end
		room:setTag("SkipGameRule",sgs.QVariant(true)) --����SkipGameRule�ˡ�һ���������SkipGameRule�ġ�
	end ,
	priority = 1 --���SkipGameRule�Ļ�������Ȩһ��Ϊ1
}
--[[
	����Ҳ�����Ǻ��Ѱ���
	6.extra_cost 
	�����һ�����ܿ����ԣ�һ����ƴ���ʱ���ʹ�õ���
	��������һ�����ܣ�
]]

--[[
	���ģ�	���������غ���ÿ��һ����ɫ��������׶�ʱ��������뵱ǰ��ɫƴ�㣬����Ӯ����Ϊ��Ե�ǰ������ɫʹ��һ�š��ҡ���������ظ��˹���ֱ����ƴ��ʧ�ܻ��߲������ƴ��Ϊֹ��
]]

devRexinCard=sgs.CreateSkillCard{
	name="devRexinCard",
	will_throw = false,
	skill_name = "devRexin",
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:getPhase() ~= sgs.Player_NotActive and to_select:objectName() ~= sgs.Self:objectName()
	end ,
	extra_cost = function(self,room,card_use) --Ҫ�����ʱ��ѯ��ƴ���ƺͼ�¼ƴ�����
		local source = card_use.from
		local subcard = sgs.Sanguosha:getCard(self:getEffectiveId())
		local pd 
		if subcard then
			pd = source:pindianSelect(room:getCurrent(),"devRexin",subcard)
		else
			pd = source:pindianSelect(room:getCurrent(),"devRexin")
		end
		local data = sgs.QVariant()
		data:setValue(pd)
		source:setTag("devRexin",data)
	end,
	on_effect = function(self,effect)
		local pd = effect.from:getTag("devRexin"):toPindian()
		effect.from:removeTag("devRexin")
		local success = effect.from:pindian(pd) --������ƴ����������
		if success then
			local peach = sgs.Sanguosha:cloneCard("peach")
			peach:setSkillName("devRexin")
			peach:deleteLater()
			effect.from:getRoom():useCard(sgs.CardUseStruct(peach,effect.from,effect.from:getRoom():getCurrentDyingPlayer()))
		else
			effect.from:getRoom():setPlayerFlag(effect.from,"Global_devRexinFailed")
			--[[
				������˵һ��Global_***Failed���Flag
				���Flag����ǡ����ʱ����ChoiceMade����ϵͳ�����
				���ԣ��о�Ӧ�ñ����Ƶ�ʱ����ðɡ���
				����ChoiceMade�����Բο���ɱLua�������һƪChoiceMade��˵��
			]]
		end
	end
}
devRexin = sgs.CreateOneCardViewAsSkill{
	name = "devRexin",
	enabled_at_play = function() --һ����������ʹ��
		return false
	end,
	filter_pattern = ".",
	enabled_at_response=function(self, player, pattern)
		if player:hasFlag("Global_devRexinFailed") or player:hasFlag("Global_PreventPeach") then return false end --������ɱ��ʧ�ܡ�
		if player:isKongcheng() then return false end
		if not string.find(pattern,"peach") then return false end
		for _,p in sgs.qlist(player:getAliveSiblings()) do --������ǰ�ͻ��˵��������
			if p:getPhase() ~= sgs.Player_NotActive and not p:isKongcheng() then --��ǰ�غϽ�ɫ���ճ�
				return true
			end
		end
		return false
		end,
	view_as = function(self,card)
		local acard = devRexinCard:clone()
		acard:addSubcard(card)
		acard:setShowSkill(self:objectName()) --������
		acard:setSkillName(self:objectName())
		return acard
	end,
}
--[[
	��ʵ������ɱΪ�˹������Ƶ�һ���ӿڣ���extra_cost��ʱ����һ�û�������佫�����Կ���ִ��һЩЧ����
	��Ȼ����չ�Ե����ݲ���������ô�࣬��һЩ�Ѿ����ܹ��ˣ�����أ����Բο�������ĵ���
	1.��Ϊ������
	2.ʹ��Json�����ƿͻ���
	3.����������
]]