
WAddon.Watching = { };
WAddon.Watching.On = false;
WAddon.Watching.Visible = false;
WAddon.Watching.waitingForPin = false;
WAddon.Watching.name = "";
WAddon.Watching.guid = 0;
WAddon.Watching.account = "";
WAddon.Watching.filter = "";
WAddon.Watching.Email = "";
WAddon.Watching.Email_use = false;
WAddon.Watching.PcUserName = "";
WAddon.Watching.PcUserName_use = false;
WAddon.Watching.ComputerName = "";
WAddon.Watching.ComputerName_use = false;
WAddon.Watching.AutoBan_use = false;

function WAddon.Watching.refresh()
	WAddon.Watching.waitingForPin = false;
end

function WAddon.Watching.useEmail()
	if WAddon.Watching.Email_use then
		WAddon.Watching.Email_use = false;
	else
		WAddon.Watching.Email_use = true;
	end
end

function WAddon.Watching.useComputerName()
	if WAddon.Watching.ComputerName_use then
		WAddon.Watching.ComputerName_use = false;
	else
		WAddon.Watching.ComputerName_use = true;
	end
end

function WAddon.Watching.usePcUserName()
	if WAddon.Watching.PcUserName_use then
		WAddon.Watching.PcUserName_use = false;
	else
		WAddon.Watching.PcUserName_use = true;
	end
end

function WAddon.Watching.useAutoBan()
	if WAddon.Watching.AutoBan_use then
		WAddon.Watching.AutoBan_use = false;
	else
		WAddon.Watching.AutoBan_use = true;
	end
end

function WAddon.Watching.Toggle()
--[[
    if WAddon_Watching_InfoWindow:IsVisible() then
        WAddon_Watching_InfoWindow:Hide();
    else
        WAddon_Watching_InfoWindow:Show();
    end
]]	
	if WAddon.Watching.Visible then
		WAddon.Watching.Visible = false;
		WAddon_Watching_InfoWindow:Hide();
	else
		WAddon.Watching.Visible = true;
		WAddon_Watching_InfoWindow:Show();
	end
end

function WAddon.Watching.WaitingPinReset()
	WAddon.Watching.waitingForPin = false;
end

function WAddon.Watching.GetOnlineInfo()
	WAddon.Watching.waitingForPin = true;
	local filter = WAddon_Watching_InfoWindow_Filters_Filter:GetText();
	SendChatMessage(".lookup pla online "..filter, "WHISPER", nil, UnitName("player"));
	Chronos.schedule(2,WAddon.Watching.WaitingPinReset);
--[[
	if UnitIsAFK("player") then
		DEFAULT_CHAT_FRAME.editBox:SetText("/afk");
		ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0);
	end
	]]
end

function WAddon.Watching.ProcessPin(player, email, compName, userName)
	local finding_email, finding_compName, finding_userName = false; 
	local email_check = true;
	local compName_check = true;
	local userName_check = true;
	
	if WAddon.Watching.Email_use then
		local filter_email = WAddon_Watching_InfoWindow_Emails_Email:GetText();
		for _, filter_one in ipairs({ strsplit(",", filter_email) }) do
			local index = string.find(strupper(email), strupper(filter_one));
			if #filter_one ~=0 and index then
				finding_email = true;
				--email = email:gsub(strupper(filter_one), "|cffff0000"..strupper(filter_one).."|r");
				--email = email:gsub(strlower(filter_one), "|cffff0000"..strlower(filter_one).."|r");
				email = email:gsub(email:sub(index, #filter_one), "|cffff0000"..email:sub(index, #filter_one).."|r");
			end
		end
	end

	if WAddon.Watching.ComputerName_use then
		local filter_compName = WAddon_Watching_InfoWindow_ComputerNames_ComputerName:GetText();
		for _, filter_two in ipairs({ strsplit(",", filter_compName) }) do
			local index = string.find(strupper(compName), strupper(filter_two));
			if #filter_two ~= 0 and index then
				finding_compName = true;
				--compName = compName:gsub(strupper(filter_two), "|cffff0000"..strupper(filter_two).."|r");
				--compName = compName:gsub(strlower(filter_two), "|cffff0000"..strlower(filter_two).."|r");
				compName = compName:gsub(compName:sub(index, #filter_two), "|cffff0000"..compName:sub(index, #filter_two).."|r");
			end
		end
	end

	if WAddon.Watching.PcUserName_use then
		local filter_userName = WAddon_Watching_InfoWindow_PcUserNames_PcUserName:GetText();
		for _, filter_three in ipairs({ strsplit(",", filter_userName) }) do
			local index = string.find(strupper(userName), strupper(filter_three));
			if #filter_three ~= 0 and index then
				finding_userName = true;
				--userName = userName:gsub(strupper(filter_three), "|cffff0000"..strupper(filter_three).."|r");
				--userName = userName:gsub(strlower(filter_three), "|cffff0000"..strlower(filter_three).."|r");
				userName = userName:gsub(userName:sub(index, #filter_three), "|cffff0000"..userName:sub(index, #filter_three).."|r");
			end
		end
	end		

	if WAddon.Watching.Email_use then
		if not finding_email then
			email_check = false;
		end
	end
	
	if WAddon.Watching.ComputerName_use then
		if not finding_compName then
			compName_check = false;
		end
	end
		
	if WAddon.Watching.PcUserName_use then
		if not finding_userName then
			userName_check = false;
		end
	end
	
	if email_check and compName_check and userName_check then
		Chronos.schedule(0.25,WAddon.Watching.FoundPlayer, player, email, compName, userName);
		--print("Найден игрок: |cff7ff531"..player .. "|r Почта: ".. email .." Имя компьютера: ".. compName .." Имя пользователя: ".. userName);
	end
	
end

function WAddon.Watching.FoundPlayer(player, email, compName, userName)
	print("Найден игрок: |cff7ff531"..player .. "|r Почта: ".. email .." Имя компьютера: ".. compName .." Имя пользователя: ".. userName);
	
	if WAddon.Watching.AutoBan_use then
		local ban_Time = WAddon_Watching_InfoWindow_Bans_BanTime:GetText();
		local ban_Reason = WAddon_Watching_InfoWindow_Bans_BanReason:GetText();
		if #ban_Time ~=0 and #ban_Reason ~= 0 then
			SendChatMessage(".ban pla "..player.. " " .. ban_Time .. " " .. ban_Reason, "WHISPER", nil, UnitName("player"));
		end
	end
end

function WAddon.Watching.watch()
	if WAddon.Watching.On then
		WAddon.Watching.On = false;
		Chronos.unscheduleByName('watchingTimer');
		WAddon_Watching_InfoWindow_StartButton:SetText("Отслеживать");
	else
		local watchTimer = tonumber(WAddon_Watching_InfoWindow_Timers_Timer:GetText());
		if watchTimer then
			WAddon.Watching.On = true;
			Chronos.scheduleRepeating('watchingTimer', watchTimer, WAddon.Watching.GetOnlineInfo);
			WAddon_Watching_InfoWindow_StartButton:SetText("Остановить");
		end
	end
end

