
WAddon = { };
WAddon.Hud = { };
WAddon.lastName = "";

function WAddon.onLoad()
	WAddon_Watching_InfoWindow_Filters_Filter:SetText("e@gmail.com");
	WAddon_Watching_InfoWindow_Timers_Timer:SetText("60");
	WAddon.Watching.refresh();
	
	SLASH_WWATCH1 = "/watch";
	SlashCmdList["WWATCH"] = WAddon.Watching.Toggle; 
end

local frame = CreateFrame("FRAME");
frame:RegisterEvent("ADDON_LOADED");

function frame:OnEvent(event, arg1)
    if event == "ADDON_LOADED" then
        WAddon.onLoad();
    end
end

frame:SetScript("OnEvent", frame.OnEvent);

--WAddon.minimap = {};

function WAddon.loadWindow(window, title, refresh, refreshScript)
    local name = window:GetName();
    window:RegisterForClicks("LeftButtonUp", "RightButtonUp");
    getglobal(name .. "_Title_Text"):SetText(title);
    if refresh then
        getglobal(name .. '_Refresh'):Show();
        getglobal(name .. '_Title'):SetWidth(window:GetWidth() - 32);
        if refreshScript then
            getglobal(name .. '_Refresh'):SetScript("OnClick", refreshScript);
        end
    else
        getglobal(name .. '_Refresh'):Hide();
        getglobal(name .. '_Title'):SetWidth(window:GetWidth() - 16);
    end

    getglobal(name .. '_Main'):SetWidth(window:GetWidth());
    getglobal(name .. '_Main'):SetHeight(window:GetHeight() - 14);
end

local ORIG_ChatFrame_MessageEventHandler = ChatFrame_MessageEventHandler;
function ChatFrame_MessageEventHandler(self, event, ...)
    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15 = ...;
	local ActionTaken = false;
   
    if WAddon.Watching.waitingForPin  then
		if (event ~= "CHAT_MSG_SYSTEM") then
			WAddon.Watching.waitingForPin = false;
			ActionTaken = true;
		end
		
        if string.find(arg1, "ComputerName:") then
			if WAddon.Watching.waitingForPin  then
				local player,email, compName, userName  = string.match(arg1, ".*%[(.*)%].*Email: (.*),%s%d.*ComputerName: (.*),%sPcUserName: (.*)");
				if player then
					if WAddon.lastName == player then 
						ActionTaken = true;
					else
						WAddon.lastName = player;
						ActionTaken = true;
						WAddon.Watching.ProcessPin(player, email, compName, userName);
					end
					--WAddon.Watching.waitingForPin = false;
				end
            else
			    WAddon.Watching.waitingForPin = false;
			end
		end
    end

    if not ActionTaken then
        ORIG_ChatFrame_MessageEventHandler(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15);
    end
end

