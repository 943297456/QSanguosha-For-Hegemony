--���ܽ���7�������������͵���Ϻ͸��Ӽ��ܵ�ʵ�֣�����
--[[
	������½��У��ҽ������ҿ�һ�����ӵļ��ܡ�
	������ܼ����ۺ���ǰ��Lua����˵���ļ��ɡ�
	���ˣ�������˵���ϼ��ܣ�
]]

--[[
	�Զ���(���ƽ׶���һ��)ÿ������Ҫʹ�û���һ�Ż�����ʱ�����չʾ�ƶѶ�1+X���ƣ�XΪ�㵱ǰ����ʧ����ֵ������Ϊ1�������ʹ�û�����Щ����һ����Ӧ�����ơ�����Щ���У�����Խ�����Ϊ���ơ�������Ϊ��ɱ����÷��Ϊ����������
]]
--[[
	û��ʲô�����ֵ�÷����ģ���Ҫ˵�Ķ��ڴ������ˡ�
]]
local json = require ("json")
--����json�⣬���ǿ���ʹ��json.encode������json�ַ������ٿ�json��
function view(room, player, ids, enabled, disabled,skill_name)
	local result = -1;
    local jsonLog = {
		"$ViewDrawPile",
		player:objectName(),
		"",
		table.concat(sgs.QList2Table(ids),"+"),
		"",
		""
	}
    room:doNotify(player,sgs.CommandType.S_COMMAND_LOG_SKILL, json.encode(jsonLog))
	----------doNotify--------
	--��������������Ǹ��¿ͻ���
	--ͨ��Json����ص����������¿ͻ��ˡ�
	--����������ͬ�Ļ���doBroadcastNotify��
	--������
	--��һ��������ServerPlayer���ͣ���ָ�����¿ͻ��˵���ҡ�
	--�ڶ���������commandType���ͣ�ʵ����int�������¿ͻ��˵��������˵ͨѶЭ��
	--�������������ַ������ͣ�Ҳ�����²�����
	--����commandType���Բμ�lua\utilities.lua����󲿷�
	--��Դ���У�һ��ͨѶЭ��ı�ʾ��ʽ��������
	--QSanProtocol::����һ��ͨѶЭ��
	--����Lua�У�����ֻ��Ҫ��QSanProtocol::����sgs.CommandType.
	--���ڵ���������value��ͨ����������ʽ��
	--һ���value
	--����array
	--�������һ���value�Ļ�ֻ��Ҫ��json.encode(value)�Ϳ�����
	--���������array�Ļ�����Ҫ��ȫ����Դ���е�˳����д
	--��ʱ��array���滹������һ����QListת��������array
	--����ֻ��Ҫ���������sgs.QList2Table����ת��Lua table�Ϳ�����
	--����������json.encode��table���Json�ַ���
	--����������һ���������ʾ��
    room:notifySkillInvoked(player,skill_name)
	---��仰��������֪ͨ���пͻ���ĳ��ʹ����ʲô���ܡ�
	--�������þ�������ҿ�����ʾ��������
    if enabled:isEmpty() then
		local jsonValue = {
            ".",
            false,
            sgs.QList2Table(ids)
		}
        room:doNotify(player,sgs.CommandType.S_COMMAND_SHOW_ALL_CARDS, json.encode(jsonValue))
		--������ط�Դ��������д�ģ���Ա�һ�¡�
		--[[
		Json::Value arg(Json::arrayValue);
        arg[0] = QSanProtocol::Utils::toJsonString(".");
        arg[1] = false;
        arg[2] = QSanProtocol::Utils::toJsonArray(ids);
        room->doNotify(player, QSanProtocol::S_COMMAND_SHOW_ALL_CARDS, arg);
		]]
		--����˵���ֶ���û��Դ�����д����������
		--�����벻Ҫ������json
		--�����ܵĲο�Դ��д��
    else
        room:fillAG(ids, player, disabled)
        local id = room:askForAG(player, enabled, true,skill_name);
        if (id ~= -1) then
            ids:removeOne(id)
            result = id
        end
        room:clearAG(player)
		--���ﻹ��ʹ��AG����ѡ��
    end
	if ids:length() > 0 then
		local drawPile = room:getDrawPile() --�°��getDrawPile�Ƕ�������Pile�������á�
        for i = ids:length() - 1,0,-1 do
            drawPile:prepend(ids:at(i))
		end
		--���ƷŻ��ƶ�
        room:doBroadcastNotify(sgs.CommandType.S_COMMAND_UPDATE_PILE, sgs.QVariant(drawPile:length()))
		--֪ͨ�ͻ��˸����ƶ���Ŀ
	end
    if result == -1 then
        room:setPlayerFlag(player, "Global_"..skill_name.."Failed")
	end
    return result
end

devLvedongCard=sgs.CreateSkillCard{
	name="devLvedongCard",
	will_throw = false,
	skill_name = "devLvedong",
	filter = function(self, targets, to_select)
		local name = ""
		local card
		local plist = sgs.PlayerList()
		for i = 1, #targets do plist:append(targets[i]) end
		local aocaistring = self:getUserString()
		if aocaistring ~= "" then
			local uses = aocaistring:split("+")
			name = uses[1]
			card = sgs.Sanguosha:cloneCard(name)
		end
		card:deleteLater() --���õ�Ҫɾ��
		return card and card:targetFilter(plist, to_select, sgs.Self) --�������Card����غ���
	end ,
	feasible = function(self, targets)
		local name = ""
		local card
		local plist = sgs.PlayerList()
		for i = 1, #targets do plist:append(targets[i]) end
		local aocaistring = self:getUserString()
		if aocaistring ~= "" then
			local uses = aocaistring:split("+")
			name = uses[1]
			card = sgs.Sanguosha:cloneCard(name)
		end
		card:deleteLater()
		return card and card:targetsFeasible(plist, sgs.Self)--ͬ��
	end,
	on_validate_in_response = function(self, user) --�ڼ��ܿ��н��ܹ�
		local room = user:getRoom()
		local ids = room:getNCards(1 + math.max(user:getLostHp(),1), false)
		local aocaistring = self:getUserString()
		local names = aocaistring:split("+")
		if table.contains(names, "slash") then
			table.insert(names,"fire_slash")
			table.insert(names,"thunder_slash")
		end
		local filterFunction = function(id)
			local card = sgs.Sanguosha:getCard(id)
			if card == nil then return nil end
			if card:getSuit() == sgs.Card_Spade then
				return "analeptic"
			elseif card:getSuit() == sgs.Card_Club then
				return "jink"
			elseif card:getSuit() == sgs.Card_Diamond then
				return "slash"
			else
				return card:objectName()
			end
		end
		local enabled, disabled = sgs.IntList(), sgs.IntList()
		for _,id in sgs.qlist(ids) do
			if table.contains(names, filterFunction(id)) or table.contains(names,sgs.Sanguosha:getCard(id):objectName())  then
				enabled:append(id)
			else
				disabled:append(id)
			end
		end
		local id = view(room, user, ids, enabled, disabled,"devLvedong")
		if id == -1 then return nil end
		if table.contains(names,sgs.Sanguosha:getCard(id):objectName()) then
			return sgs.Sanguosha:getCard(id)
		else
			local returnCard = sgs.Sanguosha:cloneCard(filterFunction(id))
			if returnCard then 
				returnCard:addSubcard(id)
				returnCard:setSkillName("devLvedong")
			end
			return returnCard
		end
	end,
	on_validate = function(self, cardUse) --�ڼ��ܿ��н��ܹ�
		cardUse.m_isOwnerUse = false
		local user = cardUse.from
		local room = user:getRoom()
		local ids = room:getNCards(1 + math.max(user:getLostHp(),1), false)
		local aocaistring = self:getUserString()
		local names = aocaistring:split("+")
		if table.contains(names, "slash") then
			table.insert(names,"fire_slash")
			table.insert(names,"thunder_slash")
		end
		local filterFunction = function(id)
			local card = sgs.Sanguosha:getCard(id)
			if card == nil then return nil end
			if card:getSuit() == sgs.Card_Spade then
				return "analeptic"
			elseif card:getSuit() == sgs.Card_Club then
				return "jink"
			elseif card:getSuit() == sgs.Card_Diamond then
				return "slash"
			else
				return card:objectName()
			end
		end
		local enabled, disabled = sgs.IntList(), sgs.IntList()
		for _,id in sgs.qlist(ids) do
			if table.contains(names, filterFunction(id)) or table.contains(names,sgs.Sanguosha:getCard(id):objectName())  then
				enabled:append(id)
			else
				disabled:append(id)
			end
		end
		local id = view(room, user, ids, enabled, disabled,"devLvedong")
		if id == -1 then return nil end
		if table.contains(names,sgs.Sanguosha:getCard(id):objectName()) then
			return sgs.Sanguosha:getCard(id)
		else
			local returnCard = sgs.Sanguosha:cloneCard(filterFunction(id))
			if returnCard then 
				returnCard:addSubcard(id)
				returnCard:setSkillName("devLvedong")
			end
			return returnCard
		end
	end
}
devLvedongVS = sgs.CreateZeroCardViewAsSkill{
	name = "devLvedong",
	enabled_at_play = function(self, player)
		if player:hasFlag("Global_devLvedongFailed") or player:hasUsed("#devLvedongCard") then return false end
		return sgs.Slash_IsAvailable(player) or sgs.Analeptic_IsAvailable(player) or player:isWounded()
	end,
	enabled_at_response=function(self, player, pattern)
		if player:hasFlag("Global_devLvedongFailed") then return end
		if pattern == "slash" then
			return sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
		elseif (pattern == "peach") then
			return not player:hasFlag("Global_PreventPeach")
		elseif string.find(pattern, "analeptic") then
			return true
		end
		return false
	end,
	view_as = function(self)
		local acard = devLvedongCard:clone()
		local pattern = "233"
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			pattern = sgs.Self:getTag("devLvedong"):toString() --�ƻ�����֮��ͻ��ѡ���Ƶ�objectName������sgs.Self����Ϊ�ü���objectName��Tag��
		else
			pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if pattern == "peach+analeptic" and sgs.Self:hasFlag("Global_PreventPeach") then
				pattern = "analeptic"
			end
		end
		local ac = sgs.Sanguosha:cloneCard(pattern:split("+")[1])
		ac:deleteLater()
		acard:setTargetFixed(ac:targetFixed()) --����TargetFixed
		acard:setUserString(pattern)
		acard:setShowSkill(self:objectName())
		acard:setSkillName(self:objectName())
		return acard
	end,
}
devLvedong = sgs.CreateTriggerSkill{
	name = "devLvedong" ,
	events = {sgs.CardAsked},
	view_as_skill = devLvedongVS,
	guhuo_type = "b", --�ƻ�����ͣ�����Ϊ�����ֽ��ܹ���
	can_trigger = function(self, event, room, player, data)
		if player and player:isAlive() and player:hasSkill(self:objectName()) then
			local pattern = data:toStringList()[1]
			if pattern == "slash" or pattern == "jink" then
				return self:objectName()
			end
		end
		return ""
	end ,
	on_cost = function(self, event, room, player, data)
		if room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
	end ,
	on_effect = function(self, evnet, room, player, data)
		local pattern = data:toStringList()[1]
		local ids = room:getNCards(1 + math.max(player:getLostHp(),1), false)
		local enabled, disabled = sgs.IntList(), sgs.IntList()
		local filterFunction = function(id)
			local card = sgs.Sanguosha:getCard(id)
			if card == nil then return nil end
			if card:getSuit() == sgs.Card_Spade then
				return "analeptic"
			elseif card:getSuit() == sgs.Card_Club then
				return "jink"
			elseif card:getSuit() == sgs.Card_Diamond then
				return "slash"
			else
				return card:objectName()
			end
		end
		for _,id in sgs.qlist(ids) do
			if string.find(filterFunction(id), pattern) or string.find(sgs.Sanguosha:getCard(id):objectName(), pattern) then
				enabled:append(id)
			else
				disabled:append(id)
			end
		end
		local id = view(room, player, ids, enabled, disabled,self:objectName())
		if id ~= -1 then
			if string.find(sgs.Sanguosha:getCard(id):objectName(), pattern) then
				room:provide(sgs.Sanguosha:getCard(id))
			else
				local returnCard = sgs.Sanguosha:cloneCard(filterFunction(id))
				if returnCard then 
					returnCard:addSubcard(id)
					returnCard:setSkillName(self:objectName())
				end
				room:provide(returnCard)
			end
			return true
		end
	end ,
}
--[[
	������ӵļ��ܴ����˺ö�߼��Ķ����ͼ��ɣ�ϣ���ܸ����һ�������
]]
--[[
	�������ս��ɱ��չ�ĵ��͸�һ�����ˣ�ϣ����Щ�򵥵������ܹ�������ҽ�����⡣
	�������ʲô�õĽ�����������������ϵ���֡��������䲻֪�����ĸ��ļ�����
]]