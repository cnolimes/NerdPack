local _, NeP          = ...

-- Locals
local LibStub     = LibStub
local strupper    = strupper
local CreateFrame = CreateFrame

local DiesalGUI   = LibStub("DiesalGUI-1.0")
local DiesalTools = LibStub("DiesalTools-1.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")

function NeP.Interface:Header(element, parent, offset, table)
	local tmp = DiesalGUI:Create("FontString")
	tmp:SetParent(parent.content)
	parent:AddChild(tmp)
	tmp = tmp.fontString
	tmp:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset)
	tmp:SetText('|cff'..table.color..element.text)
	tmp:SetJustifyH(element.justify or 'LEFT')
	tmp:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 13)
	tmp:SetWidth(parent.content:GetWidth()-10)
	if element.align then tmp:SetJustifyH(strupper(element.align)) end
	return tmp
end

function NeP.Interface:Text(element, parent, offset)
	local tmp = DiesalGUI:Create("FontString")
	tmp:SetParent(parent.content)
	parent:AddChild(tmp)
	tmp = tmp.fontString
	tmp:SetPoint("TOPLEFT", parent.content, "TOPLEFT", element.text_offset1 or 5, offset)
	tmp:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
	tmp:SetText(element.text)
	tmp:SetJustifyH('LEFT')
	tmp:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), element.size or 10)
	tmp:SetWidth(parent.content:GetWidth()-10)
	element.offset = element.offset or tmp:GetStringHeight()
	if element.align then tmp:SetJustifyH(strupper(element.align)) end
	element.text_offset1 = nil
	return tmp
end

function NeP.Interface:Rule(_, parent, offset)
	local tmp = DiesalGUI:Create('Rule')
	parent:AddChild(tmp)
	tmp:SetParent(parent.content)
	tmp.frame:SetPoint('TOPLEFT', parent.content, 'TOPLEFT', 5, offset-3)
	tmp.frame:SetPoint('BOTTOMRIGHT', parent.content, 'BOTTOMRIGHT', -5, offset-3)
	return tmp
end

function NeP.Interface:Texture(element, parent, offset)
	local tmp = CreateFrame('Frame')
	tmp:SetParent(parent.content)
	if element.center then
		tmp:SetPoint('CENTER', parent.content, 'CENTER', (element.x or 0), offset-(element.y or 0))
	else
		tmp:SetPoint('TOPLEFT', parent.content, 'TOPLEFT', 5+(element.x or 0), offset-3+(element.y or 0))
	end
	tmp:SetWidth(parent:GetWidth()-10)
	tmp:SetHeight(element.height)
	tmp:SetWidth(element.width)
	tmp.texture = tmp:CreateTexture()
	tmp.texture:SetTexture(element.texture)
	tmp.texture:SetAllPoints(tmp)
	return tmp
end

function NeP.Interface:Checkbox(element, parent, offset, table)
	local tmp = DiesalGUI:Create('CheckBox')
	parent:AddChild(tmp)
	tmp:SetParent(parent.content)
	tmp:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset)
	tmp:SetEventListener('OnValueChanged', function(_, _, checked)
		NeP.Config:Write(table.key, element.key, checked)
	end)
	tmp:SetChecked(NeP.Config:Read(table.key, element.key, element.default or false))
	element.text_offset1 = 20
	tmp.text = self:Text(element, parent, offset-3)
	if element.desc then
		element.text=element.desc
		tmp.desc = self:Text(element, parent, offset-18)
		element.push = tmp.desc:GetStringHeight() + 10
	end
	return tmp
end

function NeP.Interface:Spinner(element, parent, offset, table)
	local tmp = DiesalGUI:Create('Spinner')
	parent:AddChild(tmp)
	tmp:SetParent(parent.content)
	tmp:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
	tmp:SetNumber(NeP.Config:Read(table.key, element.key, element.default))

	--Settings
	tmp.settings.width = element.width or tmp.settings.width
	tmp.settings.min = tmp.settings.min or element.min
	tmp.settings.max = element.max or tmp.settings.max
	tmp.settings.step = element.step or tmp.settings.step
	tmp.settings.shiftStep = element.shiftStep or tmp.settings.shiftStep

	tmp:ApplySettings()
	tmp:SetStylesheet(self.spinnerStyleSheet)
	tmp:SetEventListener('OnValueChanged', function(_, _, userInput, number)
		if not userInput then return end
		NeP.Config:Write(table.key, element.key, number)
	end)
	tmp.text = self:Text(element, parent, offset-3)
	if element.desc then
		element.text=element.desc
		tmp.desc = self:Text(element, parent, offset-18)
		element.push = tmp.desc:GetStringHeight() + 10
	end
	return tmp, self.spinnerStyleSheet
end

function NeP.Interface:Checkspin(element, parent, offset, table)
	local tmp = DiesalGUI:Create('Spinner')
	parent:AddChild(tmp)
	tmp:SetParent(parent.content)
	tmp:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)

	--settings
	tmp.settings.width = element.width or tmp.settings.width
	tmp.settings.min = element.min or tmp.settings.min
	tmp.settings.max = element.max or tmp.settings.max
	tmp.settings.step = element.step or tmp.settings.step
	tmp.settings.shiftStep = element.shiftStep or tmp.settings.shiftStep

	tmp:SetNumber(NeP.Config:Read(table.key, element.key..'_spin', element.default_spin or 0))
	tmp:SetStylesheet(self.spinnerStyleSheet)
	tmp:ApplySettings()
	tmp:SetEventListener('OnValueChanged', function(_, _, userInput, number)
		if not userInput then return end
		NeP.Config:Write(table.key, element.key..'_spin', number)
	end)
	tmp.check = DiesalGUI:Create('CheckBox')
	parent:AddChild(tmp.check)
	tmp.check:SetParent(parent.content)
	tmp.check:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-2)
	tmp.check:SetEventListener('OnValueChanged', function(_, _, checked)
		NeP.Config:Write(table.key, element.key..'_check', checked)
	end)
	tmp.check:SetChecked(NeP.Config:Read(table.key, element.key..'_check', element.default_check or false))
	tmp.text = self:Text(element, parent, offset-3)
	if element.desc then
		element.text=element.desc
		tmp.desc = self:Text(element, parent, offset-18)
		element.push = tmp.desc:GetStringHeight() + 10
	end
	return tmp, self.spinnerStyleSheet
end

function NeP.Interface:Combo(element, parent, offset, table)
	local tmp = DiesalGUI:Create('Dropdown')
	parent:AddChild(tmp)
	tmp:SetParent(parent.content)
	tmp:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
	local orderdKeys = { }
	local list = { }
	for i, value in pairs(element.list) do
		orderdKeys[i] = value.key
		list[value.key] = value.text
	end
	tmp:SetList(list, orderdKeys)
	tmp:SetEventListener('OnValueChanged', function(_, _, value)
		NeP.Config:Write(table.key, element.key, value)
	end)
	tmp:SetValue(NeP.Config:Read(table.key, element.key, element.default))
	tmp.text = self:Text(element, parent, offset-3)
	if element.desc then
		element.text=element.desc
		tmp.desc = self:Text(element, parent, offset-18)
		element.push = tmp.desc:GetStringHeight() + 10
	end
	return tmp
end

function NeP.Interface:Button(element, parent, offset)
	local tmp = DiesalGUI:Create("Button")
	parent:AddChild(tmp)
	tmp:SetParent(parent.content)
	tmp:SetText(element.text)
	tmp:SetWidth(element.width or parent.content:GetWidth()-10)
	tmp:SetHeight(element.height or 20)
	tmp:SetStylesheet(self.buttonStyleSheet)
	tmp:SetEventListener("OnClick", element.callback)
	if element.desc then
		element.text=element.desc
		tmp.desc = self:Text(element, parent, offset-18)
		element.push = tmp.desc:GetStringHeight() + 10
	end
	if element.align then
		local loc = element.align
		tmp:SetPoint(loc, parent.content, 0, offset)
	else
		tmp:SetPoint("TOP", parent.content, 0, offset)
	end
	return tmp, self.buttonStyleSheet
end

function NeP.Interface:Input(element, parent, offset, table)
	local tmp = DiesalGUI:Create('Input')
	parent:AddChild(tmp)
	tmp:SetParent(parent.content)
	tmp:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
	if element.width then tmp:SetWidth(element.width) end
	tmp:SetText(NeP.Config:Read(table.key, element.key, element.default or ''))
	tmp:SetEventListener('OnEditFocusLost', function(this)
		NeP.Config:Write(table.key, element.key, this:GetText())
	end)
	tmp.text = self:Text(element, parent, offset-3)
	if element.desc then
		element.text=element.desc
		tmp.desc = self:Text(element, parent, offset-18)
		element.push = tmp.desc:GetStringHeight() + 10
	end
	return tmp
end

function NeP.Interface:Statusbar(element, parent)
	local tmp = DiesalGUI:Create('StatusBar')
	parent:AddChild(tmp)
	tmp:SetParent(parent.content)
	tmp.frame:SetStatusBarColor(DiesalTools:GetColor(element.color))
	if element.value then tmp:SetValue(element.value) end
	if element.textLeft then tmp.frame.Left:SetText(element.textLeft) end
	if element.textRight then tmp.frame.Right:SetText(element.textRight) end
	return tmp
end
