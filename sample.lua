-- Vanta UI - Matcha by @43xe on discord


local Library = {}
Library.Name    = "VANTA"
Library.Version = "1.0.0"
Library.ScrollSpeed = 32


local Vector2_new      = Vector2.new
local Color3_fromRGB   = Color3.fromRGB
local Color3_new       = Color3.new
local math_floor       = math.floor
local math_max         = math.max
local math_min         = math.min
local math_clamp       = math.clamp or function(v, a, b) return v < a and a or (v > b and b or v) end
local math_abs         = math.abs
local math_sin         = math.sin
local math_cos         = math.cos
local math_pi          = math.pi
local string_format    = string.format
local string_sub       = string.sub
local string_gsub      = string.gsub
local string_lower     = string.lower
local string_match     = string.match
local table_insert     = table.insert
local table_concat     = table.concat
local tostring_        = tostring
local tonumber_        = tonumber
local type_            = type
local pcall_           = pcall

local game_GetService  = game and game.GetService


local function DirectService(name)
	if not game_GetService then return nil end
	local ok, svc = pcall_(game_GetService, game, name)
	return ok and svc or nil
end

local Players           = DirectService("Players") or {}
local RunService         = DirectService("RunService")
local UserInputService   = DirectService("UserInputService")
local HttpService        = DirectService("HttpService")
local MarketplaceService = DirectService("MarketplaceService")




local CachedGameName = nil
do
	local raw = nil
	pcall_(function()
		if type_(getgamename) == "function" then raw = getgamename() end
	end)
	if raw ~= nil then CachedGameName = tostring_(raw) end
end

if _G.VANTA_UI then
	return _G.VANTA_UI
end


local function SafeRead(object, property)
	if object == nil then return nil end
	local ok, value = pcall_(function() return object[property] end)
	return ok and value or nil
end

local LocalPlayer = SafeRead(Players, "LocalPlayer")
local Mouse = { X = 0, Y = 0 }
do
	if LocalPlayer and type_(LocalPlayer.GetMouse) == "function" then
		local ok, mouse = pcall_(function() return LocalPlayer:GetMouse() end)
		if ok and mouse then Mouse = mouse end
	end
end

local ViewportW = 1920
local ViewportH = 1080


local function Clamp(value, minimum, maximum)
	value = tonumber_(value) or minimum
	return math_clamp(value, minimum, maximum)
end

local function Lerp(a, b, t)
	return a + (b - a) * t
end

local black = Color3_fromRGB(0, 0, 0)
local white = Color3_fromRGB(255, 255, 255)

local function Mix(first, second, amount)
	amount = Clamp(amount, 0, 1)
	local r1, g1, b1 = (first.R or 0) * 255, (first.G or 0) * 255, (first.B or 0) * 255
	local r2, g2, b2 = (second.R or 0) * 255, (second.G or 0) * 255, (second.B or 0) * 255
	return Color3_fromRGB(Lerp(r1, r2, amount), Lerp(g1, g2, amount), Lerp(b1, b2, amount))
end



local function ColorChannel(c, ch)
	if ch == "R" then return math_floor((c.R or 0) * 255 + 0.5) end
	if ch == "G" then return math_floor((c.G or 0) * 255 + 0.5) end
	return math_floor((c.B or 0) * 255 + 0.5)
end


local BASE_W, BASE_H      = 640, 430
local BASE_SIDEBAR        = 160
local BASE_TOPBAR         = 30
local BASE_FOOTER         = 40
local BASE_CONTENT_X      = BASE_SIDEBAR + 16
local BASE_CONTENT_Y      = BASE_TOPBAR + 12
local BASE_ROW            = 24
local BASE_GAP            = 4
local BASE_CONTROL_W      = 180
local BASE_SCALE_MIN       = 0.65
local BASE_SCALE_MAX       = 2
local SCROLL_SPEED          = 32 
local DEFAULT_THEME       = "Neverlose"


local BaseTheme = {
	text    = Color3_fromRGB(228, 231, 236),
	textDim = Color3_fromRGB(122, 130, 143),
	success = Color3_fromRGB(60, 205, 120),
	warn    = Color3_fromRGB(240, 190, 70),
	danger  = Color3_fromRGB(235, 80, 95),
}

local Themes = {
	Neverlose         = { Background = Color3_fromRGB(10, 15, 25),  Accent = Color3_fromRGB(0, 180, 255)  },
	Skeet             = { Background = Color3_fromRGB(17, 17, 17),  Accent = Color3_fromRGB(140, 200, 80) },
	OneTap            = { Background = Color3_fromRGB(20, 20, 20),  Accent = Color3_fromRGB(255, 100, 0)  },
	["Custom Red"]    = { Background = Color3_fromRGB(15, 10, 10),  Accent = Color3_fromRGB(220, 20, 60)  },
	["Custom Purple"] = { Background = Color3_fromRGB(15, 10, 20),  Accent = Color3_fromRGB(160, 32, 240) },
	["Vanta Pink"]    = { Background = Color3_fromRGB(28, 10, 22),  Accent = Color3_fromRGB(255, 64, 196) },
}

Library.CustomTheme = {
	Background = Color3_fromRGB(15, 15, 15),
	Accent     = Color3_fromRGB(0, 180, 255),
	Text       = Color3_fromRGB(255, 255, 255),
	Borders    = Color3_fromRGB(35, 35, 35),
}

-- Tracks the active custom theme name and active config slot for persistence.
Library.CustomThemeName = "Custom"
Library.ActiveConfig = nil

local ThemeKeys = {
	"Background", "Accent", "Text", "Borders", "bg", "sidebar", "topbar", "bottombar", "border",
	"element", "elementAlt", "hover", "text", "textDim", "success", "warn", "danger", "accent", "accent2",
}

local function IsColor(value)
	if value == nil then return false end
	local ok, r, g, b = pcall_(function() return value.R, value.G, value.B end)
	return ok and type_(r) == "number" and type_(g) == "number" and type_(b) == "number"
end

local function MakeTheme(background, accent, overrideText, overrideBorders)
	local text    = overrideText    or BaseTheme.text
	local borders = overrideBorders or Mix(background, white, 0.14)
	return {
		Background = background, Accent = accent, Text = text, Borders = borders,
		bg = background, sidebar = Mix(background, black, 0.28), topbar = Mix(background, white, 0.08),
		bottombar = Mix(background, black, 0.22), border = borders, element = Mix(background, white, 0.08),
		elementAlt = Mix(background, white, 0.14), hover = Mix(background, white, 0.21),
		text = text, textDim = BaseTheme.textDim, success = BaseTheme.success, warn = BaseTheme.warn,
		danger = BaseTheme.danger, accent = accent, accent2 = Mix(accent, white, 0.18),
	}
end

local function CopyTheme(theme)
	local copy = {}
	for i = 1, #ThemeKeys do copy[ThemeKeys[i]] = theme[ThemeKeys[i]] end
	return copy
end

local function ResolveTheme(name)
	local selected = type_(name) == "string" and Themes[name] or nil
	local canonical = selected and name or DEFAULT_THEME
	if type_(selected) ~= "table" or not IsColor(selected.Background) or not IsColor(selected.Accent) then
		selected = Themes[DEFAULT_THEME]
		canonical = DEFAULT_THEME
	end
	return MakeTheme(selected.Background, selected.Accent, selected.Text, selected.Borders), canonical
end

local InitialTheme = ResolveTheme(DEFAULT_THEME)


Library.Registry          = {}
Library.ActiveConnections = {}

local Pool        = Library.Registry
local Connections = Library.ActiveConnections
local ByKey       = {}
local KeyNames, KeyList = {}, {}

local function TrackDrawing(object)
	Pool[#Pool + 1] = object
	return object
end

local function AddConnection(connection)
	if connection then Connections[#Connections + 1] = connection end
	return connection
end

local function CloseConnection(connection)
	if connection and type_(connection.Disconnect) == "function" then
		pcall_(function() connection:Disconnect() end)
	end
end


local function ResolveFont(name, fallback)
	local ok, result = pcall_(function()
		local fonts = Drawing and Drawing.Fonts
		return fonts and fonts[name]
	end)
	return ok and result ~= nil and result or fallback
end

local ModernFont = ResolveFont("ProximaSoftBold", ResolveFont("System", 1))
local Fonts = { System = ModernFont, Bold = ResolveFont("SystemBold", ModernFont) }

local function NewSquare(width, height, z, filled)
	local object = Drawing.new("Square")
	object.Position  = Vector2_new(0, 0)
	object.Size      = Vector2_new(width, height)
	object.Color     = Color3_fromRGB(255, 255, 255)
	object.Thickness = 1
	object.Filled    = filled ~= false
	object.Rounding  = 3
	object.ZIndex    = z or 1
	object.Visible   = false
	return TrackDrawing(object)
end

local function NewLine(z)
	local object = Drawing.new("Line")
	object.From      = Vector2_new(0, 0)
	object.To        = Vector2_new(0, 0)
	object.Thickness = 1
	object.ZIndex    = z or 1
	object.Visible   = false
	return TrackDrawing(object)
end

local function NewText(size, font, center, z)
	local object = Drawing.new("Text")
	object.Text     = ""
	object.Position = Vector2_new(0, 0)
	object.Size     = size
	object.Font     = font or Fonts.System
	object.Center   = center == true
	object.Outline   = false
	object.ZIndex    = z or 1
	object.Visible   = false
	return TrackDrawing(object)
end

local function NewTriangle(z)
	local object = Drawing.new("Triangle")
	object.PointA = Vector2_new(0, 0)
	object.PointB = Vector2_new(0, 0)
	object.PointC = Vector2_new(0, 0)
	object.Filled = true
	object.ZIndex = z or 1
	object.Visible = false
	return TrackDrawing(object)
end


local State = {
	Open = true, OpenAnim = 1, Tab = 1, Tabs = {}, Scroll = {},
	ScrollMax = 0, ScrollBounds = nil, ScrollThumbRect = nil, ScrollThumbHeight = 0, ScrollTop = 0,
	ScrollDrag = false, ScrollOffset = 0,
	MX = 0, MY = 0, Down = false, PrevDown = false, MousePressPending = false,
	Dirty = true, LayoutDirty = true, Bind = nil, BindBlink = 0, MenuKey = 161,
	TextInput = nil, ActiveSlider = nil, ActivePress = nil,
	Dragging = false, DragStart = nil, StartPos = nil,
	Scale = 1, WindowW = BASE_W, WindowH = BASE_H, WinX = 0, WinY = 0,
	Layout = nil, Metrics = nil, Notifs = true, Watermark = true, Rainbow = false, BlockInput = false,
	RainbowHue = 0, KeyConsumeCode = nil, KeyConsumeStamp = 0,
	FPS = 0, Frames = 0, FpsTime = 0, ThemeName = DEFAULT_THEME,
	Cur = CopyTheme(InitialTheme), Tgt = CopyTheme(InitialTheme),
	ImportLast = nil, Unloaded = false, KeyStates = {},
}

local ActiveTheme = State.Cur
Library.ActiveTheme = ActiveTheme
Library.Themes      = Themes


local function SetVisible(object, value)
	if object and object.Visible ~= value then object.Visible = value end
end

local function HidePool()
	for i = 1, #Pool do
		local object = Pool[i]
		if object and object.Visible then object.Visible = false end
	end
end

local function S(value, scale)
	return (tonumber_(value) or 0) * (tonumber_(scale) or 1)
end

local function ScaleText(object, baseSize, scale)
	if object then object.Size = S(baseSize, scale) end
end

local function FitText(value, width, size)
	local text = tostring_(value or "")
	local available = math_max(1, tonumber_(width) or 1)
	local charWidth = math_max(1, (tonumber_(size) or 11) * 0.55)
	local maximum = math_max(1, math_floor(available / charWidth))
	if #text <= maximum then return text end
	if maximum <= 3 then return string_sub(text, 1, maximum) end
	return string_sub(text, 1, maximum - 3) .. "..."
end

local function TextWidth(object, fallback)
	local bounds = SafeRead(object, "TextBounds")
	local width = bounds and (type_(bounds) == "table" and bounds.X or (type_(bounds) == "number" and bounds))
	if type_(width) ~= "number" then width = nil end
	return width or fallback or 0
end

local function SetRect(item, field, x, y, width, height)
	local rect = item[field] or {}
	rect[1], rect[2], rect[3], rect[4] = x, y, width, height
	item[field] = rect
	return rect
end

local function PointInRect(x, y, rect)
	if type_(rect) ~= "table" then return false end
	local sx, sy = x, y
	if type_(sx) ~= "number" or type_(sy) ~= "number" then
		sx, sy = SafeRead(x, "X"), SafeRead(y, "Y")
	end
	if type_(sx) ~= "number" or type_(sy) ~= "number" then return false end
	local left, top, width, height = rect[1], rect[2], rect[3], rect[4]
	if type_(left) ~= "number" or type_(top) ~= "number" or type_(width) ~= "number" or type_(height) ~= "number" then return false end
	return sx >= left and sx <= left + width and sy >= top and sy <= top + height
end

local function GetMetrics()
	local metrics = State.Metrics or {}
	local scale = Clamp(State.Scale, BASE_SCALE_MIN, BASE_SCALE_MAX)
	metrics.Scale    = scale
	metrics.W        = S(BASE_W, scale)
	metrics.H        = S(BASE_H, scale)
	metrics.Sidebar  = S(BASE_SIDEBAR, scale)
	metrics.Topbar   = S(BASE_TOPBAR, scale)
	metrics.Footer   = S(BASE_FOOTER, scale)
	metrics.ContentX = S(BASE_CONTENT_X, scale)
	metrics.ContentY = S(BASE_CONTENT_Y, scale)
	metrics.Row      = S(BASE_ROW, scale)
	metrics.Gap      = S(BASE_GAP, scale)
	metrics.Bottom   = metrics.H - metrics.Footer
	State.Metrics    = metrics
	return metrics
end

local function BuildLayout(move, metrics, contentBottom)
	local layout = State.Layout or {}
	local scale = metrics.Scale
	local contentWidth = math_max(S(220, scale), metrics.W - metrics.Sidebar - S(32, scale))
	local leftWidth = Clamp(math_floor(contentWidth * 0.34), S(132, scale), S(190, scale))
	leftWidth = math_min(leftWidth, contentWidth - S(120, scale))
	local gap = S(16, scale)
	layout.Scale       = scale
	layout.ContentX    = move + metrics.ContentX
	layout.ContentW    = contentWidth
	layout.ContentRight= layout.ContentX + contentWidth
	layout.ContentTop  = contentBottom and (contentBottom - (metrics.Bottom - metrics.ContentY)) or 0
	layout.ContentBottom = contentBottom or 0
	layout.LeftX       = layout.ContentX
	layout.LeftW       = leftWidth
	layout.ControlX    = layout.ContentX + leftWidth + gap
	layout.ControlW    = math_max(S(120, scale), contentWidth - leftWidth - gap)
	layout.Gap         = gap
	State.Layout       = layout
	return layout
end


local function Axis(value, key)
	if type_(value) == "number" then return value end
	local ok, scalar = pcall_(function()
		local position = value and (value.Position or value)
		return position and position[key]
	end)
	return ok and type_(scalar) == "number" and scalar or nil
end

local function GetMousePosition()
	local x, y = Axis(SafeRead(Mouse, "X"), "X"), Axis(SafeRead(Mouse, "Y"), "Y")
	if x and y then return x, y end
	if type_(mouse) == "table" then
		x, y = Axis(mouse.X, "X"), Axis(mouse.Y, "Y")
		if x and y then return x, y end
	end
	if type_(getmouse) == "function" then
		local ok, position = pcall_(getmouse)
		if ok then
			x, y = Axis(position, "X"), Axis(position, "Y")
			if x and y then return x, y end
		end
	end
	if UserInputService and type_(UserInputService.GetMouseLocation) == "function" then
		local ok, position = pcall_(function() return UserInputService:GetMouseLocation() end)
		if ok then
			x, y = Axis(position, "X"), Axis(position, "Y")
			if x and y then return x, y end
		end
	end
	return 0, 0
end

local function IsMouseDown(button)
	if button == 1 and type_(ismouse1pressed) == "function" then
		local ok, result = pcall_(ismouse1pressed)
		if ok then return result == true end
	end
	if button == 2 and type_(ismouse2pressed) == "function" then
		local ok, result = pcall_(ismouse2pressed)
		if ok then return result == true end
	end
	if UserInputService and type_(UserInputService.IsMouseButtonPressed) == "function" and Enum and Enum.UserInputType then
		local enumType = button == 1 and Enum.UserInputType.MouseButton1 or Enum.UserInputType.MouseButton2
		local ok, result = pcall_(function() return UserInputService:IsMouseButtonPressed(enumType) end)
		if ok then return result == true end
	end
	return false
end


local Win = {
	Bg          = NewSquare(BASE_W, BASE_H, 2),
	Border      = NewSquare(BASE_W, BASE_H, 3, false),
	Topbar      = NewSquare(BASE_W, BASE_TOPBAR, 3),
	TopLine     = NewLine(3),
	Logo1       = NewLine(5),
	Logo2       = NewLine(5),
	Logo        = NewText(15, Fonts.Bold, false, 4),
	Fps         = NewText(11, Fonts.System, false, 4),
	Sidebar     = NewSquare(BASE_SIDEBAR, BASE_H - BASE_TOPBAR, 3),
	SidebarLine = NewLine(3),
	Footer      = NewSquare(BASE_W, BASE_FOOTER, 3),
	FooterLine  = NewLine(3),
	AvatarBox   = NewSquare(32, 32, 4),
	Avatar      = TrackDrawing(Drawing.new("Image")),
	Name1       = NewText(13, Fonts.Bold, false, 4),
	Name2       = NewText(11, Fonts.System, false, 4),
	Foot        = NewText(12, Fonts.Bold, false, 4),
	WmBg        = NewSquare(160, 24, 15),
	WmBorder    = NewSquare(160, 24, 16, false),
	WmText      = NewText(11, Fonts.Bold, false, 17),
}
Win.Avatar.ZIndex  = 5
Win.Avatar.Visible = false




local ScrollTrack = NewSquare(4, 4, 4)
local ScrollThumb = NewSquare(4, 4, 5)

local NOTIF_W      = 280
local NOTIF_H      = 52
local NOTIF_GAP   = 8
local NOTIF_DISPLAY = 5.0
local NOTIF_FADE   = 0.4
local NotificationVisuals = {}
for i = 1, 4 do
	NotificationVisuals[i] = {
		Bg    = NewSquare(NOTIF_W, NOTIF_H, 20),
		Strip = NewSquare(3, NOTIF_H, 21),
		Title = NewText(12, Fonts.Bold, false, 21),
		Desc  = NewText(11, Fonts.System, false, 21),
	}
end
local Notifications = {}
local MAX_NOTIFICATIONS = 16

local function NotificationColors(style)
	local background = ActiveTheme.Background or ActiveTheme.bg
	local accent     = ActiveTheme.Accent     or ActiveTheme.accent
	local panel      = ActiveTheme.element or Mix(background, white, 0.08)
	local stateColor = style == "success" and ActiveTheme.success
		or style == "warn" and ActiveTheme.warn
		or style == "error" and ActiveTheme.danger
		or accent
	return panel, stateColor or accent, ActiveTheme.text, ActiveTheme.textDim
end

function Library.Notify(title, description, style)
	if not State.Notifs then return end
	if #Notifications >= MAX_NOTIFICATIONS then Notifications[#Notifications] = nil end
	local record = {
		Age = 0, Life = NOTIF_DISPLAY + NOTIF_FADE,
		Title = tostring_(title or "VANTA"), Description = tostring_(description or ""),
		Style = tostring_(style or "info"), Gone = false,
	}
	for i = #Notifications + 1, 2, -1 do Notifications[i] = Notifications[i - 1] end
	Notifications[1] = record
end

local function RenderNotifications(dt, metrics)
	if #Notifications == 0 then return end
	local scale = metrics.Scale
	local width, height = S(NOTIF_W, scale), S(NOTIF_H, scale)
	local gap = S(NOTIF_GAP, scale)
	local visible = math_min(#Notifications, 4)
	for i = 1, visible do
		local record = Notifications[i]
		local visual = NotificationVisuals[i]
		record.Age = record.Age + dt
		local intro = Clamp(record.Age / 0.25, 0, 1)
		local x = Lerp(ViewportW + S(30, scale), ViewportW - width - S(16, scale), 1 - (1 - intro) * (1 - intro))
		local alpha = 1 - Clamp((record.Age - (record.Life - NOTIF_FADE)) / NOTIF_FADE, 0, 1)
		if record.Age >= record.Life then record.Gone = true end
		if not record.Gone then
			local background, accent, textColor, dimColor = NotificationColors(record.Style)
			local y = S(14, scale) + (i - 1) * (height + gap)
			visual.Bg.Position = Vector2_new(x, y)
			visual.Bg.Size = Vector2_new(width, height)
			visual.Bg.Color = background
			visual.Bg.Transparency = 1 - alpha
			visual.Bg.Visible = true
			visual.Strip.Position = Vector2_new(x, y)
			visual.Strip.Size = Vector2_new(S(3, scale), height)
			visual.Strip.Color = accent
			visual.Strip.Transparency = 1 - alpha
			visual.Strip.Visible = true
			ScaleText(visual.Title, 12, scale)
			visual.Title.Text = FitText(record.Title:upper(), width - S(24, scale), visual.Title.Size)
			visual.Title.Position = Vector2_new(x + S(12, scale), y + S(6, scale))
			visual.Title.Color = textColor
			visual.Title.Transparency = 1 - alpha
			visual.Title.Visible = true
			ScaleText(visual.Desc, 11, scale)
			visual.Desc.Text = FitText(record.Description, width - S(24, scale), visual.Desc.Size)
			visual.Desc.Position = Vector2_new(x + S(12, scale), y + S(24, scale))
			visual.Desc.Color = dimColor
			visual.Desc.Transparency = 1 - alpha
			visual.Desc.Visible = true
		end
	end
	for i = visible + 1, 4 do
		local visual = NotificationVisuals[i]
		SetVisible(visual.Bg, false); SetVisible(visual.Strip, false)
		SetVisible(visual.Title, false); SetVisible(visual.Desc, false)
	end
	local write = 0
	for i = 1, #Notifications do
		if not Notifications[i].Gone then write = write + 1; Notifications[write] = Notifications[i] end
	end
	for i = write + 1, #Notifications do Notifications[i] = nil end
end


function Library.GetValue(key) local c = ByKey[key]; return c and c.Value or nil end
function Library.GetControl(key) return ByKey[key] end
function Library.SetValue(key, value, silent)
	local c = ByKey[key]
	if c and type_(c.SetValue) == "function" then c:SetValue(value, silent) end
end

local function MarkDirty(layoutOnly)
	State.Dirty = true
	if layoutOnly then State.LayoutDirty = true end
end

local function SafeUpper(value) return tostring_(value or ""):upper() end

local function NewItem(tab, height)
	local item = { Tab = tab, H = height, Rect = nil, HitRect = nil, Hover = false, Interactive = true, FixedBottom = false }
	tab.Items[#tab.Items + 1] = item
	return item
end

local function RegisterKey(tab, item, key)
	if key == nil then return end
	item.FullKey = tab.Name .. "." .. tostring_(key)
	ByKey[item.FullKey] = item
end

local function DrawSection(item, x, y, layout)
	local s = layout.Scale
	ScaleText(item.Text, 11, s)
	item.Text.Text = FitText(SafeUpper(item.Title), layout.LeftW - S(8, s), item.Text.Size)
	item.Text.Position = Vector2_new(x, y + S(9, s))
	item.Text.Color = State.Cur.textDim
	item.Text.Visible = true
	local tw = TextWidth(item.Text, #item.Text.Text * item.Text.Size * 0.55)
	item.Line.From = Vector2_new(x + math_min(tw + S(12, s), layout.LeftW - S(4, s)), y + S(16, s))
	item.Line.To = Vector2_new(layout.ContentRight, y + S(16, s))
	item.Line.Color = State.Cur.border
	item.Line.Visible = true
	SetRect(item, "Rect", x, y, layout.LeftW, S(item.H, s))
end

function Library.Section(tab, title)
	local item = NewItem(tab, 28)
	item.Interactive = false
	item.Title = tostring_(title or "")
	item.Text  = NewText(11, Fonts.Bold, false, 4)
	item.Line  = NewLine(3)
	item.Draw  = DrawSection
	return item
end

function Library.Label(tab, text)
	local item = NewItem(tab, 18)
	item.Interactive = false
	item.Title = tostring_(text or "")
	item.Text = NewText(12, Fonts.System, false, 4)
	function item.Draw(self, x, y, layout)
		local s = layout.Scale
		ScaleText(self.Text, 12, s)
		self.Text.Text = FitText(self.Title, layout.LeftW - S(8, s), self.Text.Size)
		self.Text.Position = Vector2_new(x, y + S(2, s))
		self.Text.Color = State.Cur.textDim
		self.Text.Visible = true
		SetRect(self, "Rect", x, y, layout.LeftW, S(self.H, s))
	end
	return item
end

function Library.Toggle(tab, options)
	options = options or {}
	local item = NewItem(tab, BASE_ROW)
	item.Title = tostring_(options.title or "")
	item.Value = options.default == true
	item.Callback = options.callback
	item.NotifyOn = options.notify ~= false
	RegisterKey(tab, item, options.key)
	item.Label = NewText(13, Fonts.System, false, 4)
	item.Box   = NewSquare(14, 14, 4)
	item.Fill  = NewSquare(10, 10, 5)
	item.Check1= NewLine(6)
	item.Check2= NewLine(6)
	function item.SetValue(self, value, silent)
		local v = value == true
		if self.Value == v then return end
		self.Value = v
		if type_(self.Callback) == "function" then pcall_(self.Callback, v) end
		if self.NotifyOn and not silent then Library.Notify(SafeUpper(self.Title), v and "ENABLED" or "DISABLED", v and "success" or "warn") end
		MarkDirty()
	end
	function item.Draw(self, x, y, layout)
		local s = layout.Scale
		ScaleText(self.Label, 13, s)
		self.Label.Text = FitText(self.Title, layout.LeftW - S(8, s), self.Label.Size)
		self.Label.Position = Vector2_new(x, y + S(6, s))
		self.Label.Color = State.Cur.text
		self.Label.Visible = true
		local bx = layout.ControlX + layout.ControlW - S(14, s)
		local by = y + S(5, s)
		self.Box.Position = Vector2_new(bx, by)
		self.Box.Size = Vector2_new(S(14, s), S(14, s))
		self.Box.Color = State.Cur.element
		self.Box.Visible = true
		local fill = S(10, s)
		self.Fill.Position = Vector2_new(bx + S(2, s), by + S(2, s))
		self.Fill.Size = Vector2_new(fill, fill * (self.Value and 1 or 0))
		self.Fill.Color = State.Cur.accent
		self.Fill.Visible = self.Value
		local cx, cy = bx + S(7, s), by + S(7, s)
		self.Check1.From = Vector2_new(cx - S(3.5, s), cy)
		self.Check1.To   = Vector2_new(cx - S(1, s), cy + S(2.5, s))
		self.Check1.Color= Color3_new(1, 1, 1)
		self.Check1.Visible = self.Value
		self.Check2.From = Vector2_new(cx - S(1, s), cy + S(2.5, s))
		self.Check2.To   = Vector2_new(cx + S(4, s), cy - S(3.5, s))
		self.Check2.Color= Color3_new(1, 1, 1)
		self.Check2.Visible = self.Value
		SetRect(self, "Rect", layout.ContentX, y, layout.ContentW, S(self.H, s))
		self.HitRect = self.Rect
	end
	function item.Click() item:SetValue(not item.Value) end
	return item
end

function Library.Slider(tab, options)
	options = options or {}
	local item = NewItem(tab, BASE_ROW)
	local minimum = tonumber_(options.min) or 0
	local maximum = tonumber_(options.max) or 100
	if maximum < minimum then minimum, maximum = maximum, minimum end
	local step = math_abs(tonumber_(options.step) or 1)
	if step == 0 then step = 1 end
	item.Title = tostring_(options.title or "")
	item.Min, item.Max, item.Step = minimum, maximum, step
	item.Suffix = tostring_(options.suffix or "")
	item.Precision = tonumber_(options.precision) or (step >= 1 and 0 or 2)
	item.Value = Clamp(tonumber_(options.default) or minimum, minimum, maximum)
	item.Callback = options.callback
	item.Drag = false
	RegisterKey(tab, item, options.key)
	item.Label = NewText(13, Fonts.System, false, 4)
	item.Box   = NewSquare(BASE_CONTROL_W, 18, 4)
	item.Track = NewSquare(BASE_CONTROL_W, 3, 5)
	item.Thumb = NewSquare(3, 14, 5)
	item.ValueText = NewText(11, Fonts.Bold, false, 5)
	local function Snap(value)
		value = tonumber_(value) or item.Value or item.Min
		return Clamp(item.Min + math_floor((value - item.Min) / item.Step + 0.5) * item.Step, item.Min, item.Max)
	end
	function item.SetValue(self, value, silent)
		local v = Snap(value)
		if self.Value == v then return end
		self.Value = v
		if type_(self.Callback) == "function" then pcall_(self.Callback, v) end
		MarkDirty()
	end
	function item.Draw(self, x, y, layout)
		local s = layout.Scale
		ScaleText(self.Label, 13, s)
		self.Label.Text = FitText(self.Title, layout.LeftW - S(8, s), self.Label.Size)
		self.Label.Position = Vector2_new(x, y + S(6, s))
		self.Label.Color = State.Cur.text
		self.Label.Visible = true
		local bx, by, bw = layout.ControlX, y + S(3, s), layout.ControlW
		self.Box.Position = Vector2_new(bx, by)
		self.Box.Size = Vector2_new(bw, S(18, s))
		self.Box.Color = State.Cur.element
		self.Box.Visible = true
		local pct = self.Max > self.Min and Clamp((self.Value - self.Min) / (self.Max - self.Min), 0, 1) or 0
		local trackWidth = math_max(S(1, s), bw - S(4, s))
		local thumbX = bx + S(2, s) + trackWidth * pct
		self.Track.Position = Vector2_new(bx + S(2, s), by + S(8, s))
		self.Track.Size = Vector2_new(trackWidth, S(3, s))
		self.Track.Color = State.Cur.elementAlt
		self.Track.Visible = true
		self.Thumb.Position = Vector2_new(thumbX - S(1.5, s), by + S(2, s))
		self.Thumb.Size = Vector2_new(S(3, s), S(14, s))
		self.Thumb.Color = State.Cur.accent
		self.Thumb.Visible = true
		ScaleText(self.ValueText, 11, s)
		self.ValueText.Text = FitText(string_format("%." .. self.Precision .. "f", self.Value) .. self.Suffix, bw - S(12, s), self.ValueText.Size)
		self.ValueText.Position = Vector2_new(bx + bw - S(7, s) - TextWidth(self.ValueText, #self.ValueText.Text * self.ValueText.Size * 0.55), by + S(3.5, s))
		self.ValueText.Color = State.Cur.text
		self.ValueText.Visible = true
		SetRect(self, "ControlRect", bx, by, bw, S(18, s))
		SetRect(self, "Rect", layout.ContentX, y, layout.ContentW, S(self.H, s))
		self.HitRect = self.Rect
	end
	function item.Pressed(self, mouseX)
		local rect = self.ControlRect
		if not rect or mouseX == nil then return end
		self.Drag = true
		State.ActiveSlider = self
		local pct = Clamp((mouseX - rect[1] - S(2, State.Scale)) / math_max(1, rect[3] - S(4, State.Scale)), 0, 1)
		self:SetValue(self.Min + pct * (self.Max - self.Min))
	end
	function item.UpdateDrag(self, mouseX)
		if not self.Drag or not self.ControlRect then return end
		if mouseX == nil then return end
		local rect = self.ControlRect
		local pct = Clamp((mouseX - rect[1] - S(2, State.Scale)) / math_max(1, rect[3] - S(4, State.Scale)), 0, 1)
		self:SetValue(self.Min + pct * (self.Max - self.Min))
	end
	function item.Released(self)
		self.Drag = false
		if State.ActiveSlider == self then State.ActiveSlider = nil end
	end
	return item
end

function Library.Dropdown(tab, options)
	options = options or {}
	local item = NewItem(tab, BASE_ROW)
	item.Title = tostring_(options.title or "")
	item.Options = type_(options.options) == "table" and options.options or {}
	item.Value = options.default ~= nil and options.default or item.Options[1]
	item.Callback = options.callback
	item.OnOpen = options.onOpen
	item.Open = false
	item.VisibleOptions = 0
	RegisterKey(tab, item, options.key)
	item.Label    = NewText(13, Fonts.System, false, 4)
	item.Box      = NewSquare(BASE_CONTROL_W, 18, 4)
	item.ValueText= NewText(11, Fonts.System, false, 5)
	item.Arrow    = NewTriangle(5)
	item.ListBg    = NewSquare(BASE_CONTROL_W, 0, 6)
	item.ListBorder= NewSquare(BASE_CONTROL_W, 0, 7, false)
	item.OpRows, item.OpTexts = {}, {}
	for i = 1, 6 do
		item.OpRows[i]  = NewSquare(BASE_CONTROL_W, 18, 6)
		item.OpTexts[i] = NewText(11, Fonts.System, false, 7)
	end
	function item.SetOptions(self, values)
		local normalized = {}
		if type_(values) == "table" then
			for i = 1, #values do if values[i] ~= nil then normalized[#normalized + 1] = values[i] end end
		end
		self.Options = normalized
		self.VisibleOptions = math_min(#normalized, 6)
		local valid = false
		for i = 1, #normalized do if normalized[i] == self.Value then valid = true break end end
		if not valid then self.Value = normalized[1] end
	end
	item:SetOptions(item.Options)
	function item.SetValue(self, value, silent)
		local valid = false
		for i = 1, #self.Options do if self.Options[i] == value then valid = true break end end
		if not valid or self.Value == value then return end
		self.Value = value
		if type_(self.Callback) == "function" then pcall_(self.Callback, value) end
		MarkDirty()
	end
	function item.Close(self)
		self.Open = false
		self.ListRect = nil
		if State.DDOpen == self then State.DDOpen = nil end
		MarkDirty()
	end
	function item.Draw(self, x, y, layout)
		local s = layout.Scale
		ScaleText(self.Label, 13, s)
		self.Label.Text = FitText(self.Title, layout.LeftW - S(8, s), self.Label.Size)
		self.Label.Position = Vector2_new(x, y + S(6, s))
		self.Label.Color = State.Cur.text
		self.Label.Visible = true
		local bx, by, bw = layout.ControlX, y + S(3, s), layout.ControlW
		self.Box.Position = Vector2_new(bx, by)
		self.Box.Size = Vector2_new(bw, S(18, s))
		self.Box.Color = State.Cur.element
		self.Box.Visible = true
		ScaleText(self.ValueText, 11, s)
		self.ValueText.Text = FitText(self.Value or "NONE", bw - S(30, s), self.ValueText.Size)
		self.ValueText.Position = Vector2_new(bx + S(8, s), by + S(3.5, s))
		self.ValueText.Color = State.Cur.text
		self.ValueText.Visible = true
		local ax, ay = bx + bw - S(13, s), by + S(9, s)
		if self.Open then
			self.Arrow.PointA = Vector2_new(ax, ay + S(4, s))
			self.Arrow.PointB = Vector2_new(ax + S(5, s), ay)
			self.Arrow.PointC = Vector2_new(ax + S(10, s), ay + S(4, s))
		else
			self.Arrow.PointA = Vector2_new(ax, ay)
			self.Arrow.PointB = Vector2_new(ax + S(10, s), ay)
			self.Arrow.PointC = Vector2_new(ax + S(5, s), ay + S(4, s))
		end
		self.Arrow.Color = State.Cur.textDim
		self.Arrow.Visible = true
		SetRect(self, "BoxRect", bx, by, bw, S(18, s))
		SetRect(self, "Rect", layout.ContentX, y, layout.ContentW, S(self.H, s))
		self.HitRect = self.Rect
		self.ListRect = nil
		if self.Open and self.VisibleOptions > 0 then
			local rowHeight, listHeight = S(18, s), self.VisibleOptions * S(18, s)
			local listY = by + S(20, s)
			if listY + listHeight > layout.ContentBottom then listY = by - listHeight - S(2, s) end
			if listY >= layout.ContentTop and listY + listHeight <= layout.ContentBottom then
				self.ListBg.Position = Vector2_new(bx, listY)
				self.ListBg.Size = Vector2_new(bw, listHeight)
				self.ListBg.Color = State.Cur.element
				self.ListBg.Visible = true
				self.ListBorder.Position = Vector2_new(bx, listY)
				self.ListBorder.Size = Vector2_new(bw, listHeight)
				self.ListBorder.Color = State.Cur.accent
				self.ListBorder.Visible = true
				for i = 1, 6 do
					local row, text = self.OpRows[i], self.OpTexts[i]
					if i <= #self.Options then
						local rowY = listY + (i - 1) * rowHeight
						row.Position = Vector2_new(bx, rowY)
						row.Size = Vector2_new(bw, rowHeight)
						row.Color = self.Options[i] == self.Value and Mix(State.Cur.element, State.Cur.hover, 0.35) or State.Cur.element
						row.Visible = true
						ScaleText(text, 11, s)
						text.Text = FitText(self.Options[i], bw - S(16, s), text.Size)
						text.Position = Vector2_new(bx + S(8, s), rowY + S(3.5, s))
						text.Color = self.Options[i] == self.Value and State.Cur.accent or State.Cur.textDim
						text.Visible = true
					else
						row.Visible, text.Visible = false, false
					end
				end
				SetRect(self, "ListRect", bx, listY, bw, listHeight)
			else
				self.ListBg.Visible, self.ListBorder.Visible = false, false
				for i = 1, 6 do self.OpRows[i].Visible, self.OpTexts[i].Visible = false, false end
			end
		else
			self.ListBg.Visible, self.ListBorder.Visible = false, false
			for i = 1, 6 do self.OpRows[i].Visible, self.OpTexts[i].Visible = false, false end
		end
	end
	function item.Click(self)
		if self.Open then self:Close() return end
		if type_(self.OnOpen) == "function" then pcall_(self.OnOpen) end
		self:SetOptions(self.Options)
		if #self.Options == 0 then return end
		if State.DDOpen and State.DDOpen ~= self then State.DDOpen:Close() end
		self.Open = true
		State.DDOpen = self
		MarkDirty()
	end
	function item.PickOption(self, mouseY)
		if not self.ListRect then return end
		if type_(mouseY) ~= "number" then return end
		local index = math_floor((mouseY - self.ListRect[2]) / math_max(1, S(18, State.Scale))) + 1
		if index >= 1 and index <= #self.Options then self:SetValue(self.Options[index]) end
		self:Close()
	end
	return item
end

function Library.Keybind(tab, options)
	options = options or {}
	local item = NewItem(tab, BASE_ROW)
	item.Title = tostring_(options.title or "")
	item.Value = options.default
	item.Callback = options.callback
	RegisterKey(tab, item, options.key)
	item.Label = NewText(13, Fonts.System, false, 4)
	item.Box   = NewSquare(BASE_CONTROL_W, 18, 4)
	item.ValueText = NewText(11, Fonts.Bold, false, 5)
	function item.SetValue(self, value, silent)
		value = tonumber_(value)
		if self.Value == value then return end
		self.Value = value
		if type_(self.Callback) == "function" then pcall_(self.Callback, value) end
		if not silent then Library.Notify(SafeUpper(self.Title), KeyNames[value] or "UNBOUND", "info") end
		MarkDirty()
	end
	function item.Draw(self, x, y, layout)
		local s = layout.Scale
		ScaleText(self.Label, 13, s)
		self.Label.Text = FitText(self.Title, layout.LeftW - S(8, s), self.Label.Size)
		self.Label.Position = Vector2_new(x, y + S(6, s))
		self.Label.Color = State.Cur.text
		self.Label.Visible = true
		local bx, by, bw = layout.ControlX, y + S(3, s), layout.ControlW
		self.Box.Position = Vector2_new(bx, by)
		self.Box.Size = Vector2_new(bw, S(18, s))
		self.Box.Color = State.Cur.element
		self.Box.Visible = true
		ScaleText(self.ValueText, 11, s)
		self.ValueText.Text = "[ " .. (KeyNames[self.Value] or "NONE") .. " ]"
		self.ValueText.Position = Vector2_new(bx + (bw - TextWidth(self.ValueText, #self.ValueText.Text * self.ValueText.Size * 0.55)) / 2, by + S(3.5, s))
		self.ValueText.Color = State.Cur.text
		self.ValueText.Visible = true
		SetRect(self, "ControlRect", bx, by, bw, S(18, s))
		SetRect(self, "Rect", layout.ContentX, y, layout.ContentW, S(self.H, s))
		self.HitRect = self.Rect
	end
	function item.Click(self)
		State.Bind = State.Bind == self and nil or self
		State.BindBlink = 0
		MarkDirty()
	end
	return item
end


local TextKeyMap = {
	Zero="0", One="1", Two="2", Three="3", Four="4", Five="5", Six="6", Seven="7", Eight="8", Nine="9",
	Space=" ", Minus="-", Equals="=", LeftBracket="[", RightBracket="]", BackSlash="\\",
	Semicolon=";", Quote="'", Comma=",", Period=".", Slash="/", Backquote="`",
}

local KeyLookup = {}
local function AddKey(code, name)
	KeyNames[code] = name
	KeyList[#KeyList + 1] = code
	if type_(name) == "string" then
		local normalized = name:upper():gsub("%W", "")
		KeyLookup[normalized] = code
		KeyLookup[name] = code
		if normalized:match("^LEFT(.*)") then
			KeyLookup["L" .. normalized:sub(5)] = code
		end
		if normalized:match("^RIGHT(.*)") then
			KeyLookup["R" .. normalized:sub(6)] = code
		end
	end
end
for i = 65, 90 do AddKey(i, string.char(i)) end
for i = 48, 57 do AddKey(i, string.char(i)) end
for i = 112, 123 do AddKey(i, "F" .. (i - 111)) end
AddKey(27, "ESC"); AddKey(8, "BACKSPACE"); AddKey(13, "ENTER"); AddKey(32, "SPACE"); AddKey(160, "LSHIFT"); AddKey(161, "RSHIFT")
AddKey(45, "INSERT"); AddKey(46, "DELETE"); AddKey(36, "HOME"); AddKey(35, "END")
AddKey(186, "SEMICOLON"); AddKey(187, "EQUALS"); AddKey(188, "COMMA"); AddKey(189, "MINUS"); AddKey(190, "PERIOD")
AddKey(191, "SLASH"); AddKey(192, "BACKQUOTE"); AddKey(219, "LEFTBRACKET"); AddKey(220, "BACKSLASH"); AddKey(221, "RIGHTBRACKET"); AddKey(222, "QUOTE")

local function NormalizeKeyName(name)
	if type_(name) ~= "string" then return nil end
	return name:upper():gsub("^ENUM%.?KEYCODE%.?", ""):gsub("^ENUM%.?USERINPUTTYPE%.?", ""):gsub("%W", "")
end

local function GetKeyCode(input)
	if type_(input) == "number" then return input end
	if type_(input) == "string" then
		local normalized = NormalizeKeyName(input)
		return normalized and KeyLookup[normalized]
	end
	local key = SafeRead(input, "KeyCode")
	if type_(key) == "number" then return key end
	local value = SafeRead(key, "Value")
	if type_(value) == "number" then return value end
	local name = NormalizeKeyName(SafeRead(key, "Name") or tostring_(key or ""))
	if name and KeyLookup[name] then return KeyLookup[name] end
	name = NormalizeKeyName(tostring_(key or ""))
	if name and KeyLookup[name] then return KeyLookup[name] end
	name = NormalizeKeyName(SafeRead(input, "KeyCode") or tostring_(input or ""))
	return name and KeyLookup[name] or nil
end

local function InputKeyName(input)
	local key = GetKeyCode(input)
	if type_(key) == "number" then return KeyNames[key] or tostring_(key) end
	local raw = SafeRead(input, "KeyCode")
	local name = SafeRead(raw, "Name") or tostring_(raw or "")	
	local normalized = NormalizeKeyName(name)
	if normalized and KeyLookup[normalized] then return KeyNames[KeyLookup[normalized]] end
	return tostring_(name):gsub("^Enum%.KeyCode%.", "")
end

local function IsShiftDown()
	if type_(iskeypressed) == "function" then
		local ok1, a = pcall_(iskeypressed, 160)
		local ok2, b = pcall_(iskeypressed, 161)
		return (ok1 and a == true) or (ok2 and b == true)
	end
	return false
end

local function TextCharacter(name)
	if TextKeyMap[name] then return TextKeyMap[name] end
	if #name == 1 and string_match(name, "[%a%d]") then return IsShiftDown() and name:upper() or name:lower() end
	return nil
end

local function ProcessTextInput(input)
	local item = State.TextInput
	if not item then return false end
	
	local keyCode = SafeRead(input, "KeyCode")
	if type_(keyCode) ~= "number" then
		keyCode = SafeRead(keyCode, "Value")
	end
	if type_(keyCode) ~= "number" or keyCode < 8 then return false end
	
	if keyCode == 8 then 
		local current = tostring_(item.Value or "")
		local updated = ""
		if #current > 1 then
			updated = string_sub(current, 1, #current - 1)
		end
		item.Value = updated
		if type_(item.Callback) == "function" then pcall_(item.Callback, updated) end
	elseif keyCode == 13 or keyCode == 27 then 
		State.TextInput = nil
	elseif keyCode == 32 then 
		if #tostring_(item.Value or "") < item.MaxLength then 
			local updated = tostring_(item.Value or "") .. " "
			item.Value = updated
			if type_(item.Callback) == "function" then pcall_(item.Callback, updated) end
		end
	else
		
		local compiledString = nil
		if keyCode >= 65 and keyCode <= 90 then 
			local rawChar = string.char(keyCode)
			compiledString = IsShiftDown() and rawChar:upper() or rawChar:lower()
		elseif keyCode >= 48 and keyCode <= 57 then 
			compiledString = string.char(keyCode)
		end
		
		if compiledString and #tostring_(item.Value or "") < item.MaxLength then
			local updated = tostring_(item.Value or "") .. compiledString
			item.Value = updated
			if type_(item.Callback) == "function" then pcall_(item.Callback, updated) end
		end
	end
	
	
	
	State.Dirty = true
	State.LayoutDirty = true
	MarkDirty(true)
	
	return true
end

local function ProcessTextCode(code)
	local item = State.TextInput
	if not item then return false end
	if type_(code) ~= "number" or code < 8 then return false end
	if code == 8 then
		item:SetValue(string_sub(item.Value, 1, math_max(0, #item.Value - 1)), true)
		MarkDirty(true)
		return true
	elseif code == 27 or code == 13 then
		State.TextInput = nil
		MarkDirty(true)
		return true
	elseif code == 32 then
		if #item.Value < item.MaxLength then item:SetValue(item.Value .. " ", true) end
		MarkDirty(true)
		return true
	else
		local name = KeyNames[code]
		local character = TextKeyMap[name] or TextCharacter(name or "")
		if character and #item.Value < item.MaxLength then
			item:SetValue(item.Value .. character, true)
			MarkDirty(true)
		end
		return character ~= nil
	end
end

function Library.Textbox(tab, options)
	options = options or {}
	local item = NewItem(tab, BASE_ROW)
	item.Title = tostring_(options.title or "")
	item.Value = tostring_(options.default or "")
	item.Placeholder = tostring_(options.placeholder or "Type a name")
	item.MaxLength = math_max(1, tonumber_(options.maxLength) or 32)
	item.Callback = options.callback
	RegisterKey(tab, item, options.key)
	item.Label = NewText(13, Fonts.System, false, 4)
	item.Box   = NewSquare(BASE_CONTROL_W, 18, 4)
	item.Text  = NewText(11, Fonts.System, false, 5)
	function item.SetValue(self, value, silent)
		self.Value = tostring_(value or ""):sub(1, self.MaxLength)
		if type_(self.Callback) == "function" and not silent then pcall_(self.Callback, self.Value) end
		MarkDirty()
	end
	function item.Draw(self, x, y, layout)
		local s = layout.Scale
		ScaleText(self.Label, 13, s)
		self.Label.Text = FitText(self.Title, layout.LeftW - S(8, s), self.Label.Size)
		self.Label.Position = Vector2_new(x, y + S(6, s))
		self.Label.Color = State.Cur.text
		self.Label.Visible = true
		local bx, by, bw = layout.ControlX, y + S(3, s), layout.ControlW
		self.Box.Position = Vector2_new(bx, by)
		self.Box.Size = Vector2_new(bw, S(18, s))
		self.Box.Color = State.TextInput == self and State.Cur.accent or State.Cur.element
		self.Box.Visible = true
		ScaleText(self.Text, 11, s)
		local shown = self.Value ~= "" and self.Value or self.Placeholder
		if State.TextInput == self then shown = shown .. "|" end
		self.Text.Text = FitText(shown, bw - S(16, s), self.Text.Size)
		self.Text.Position = Vector2_new(bx + S(8, s), by + S(3.5, s))
		self.Text.Color = self.Value ~= "" and State.Cur.text or State.Cur.textDim
		self.Text.Visible = true
		SetRect(self, "ControlRect", bx, by, bw, S(18, s))
		SetRect(self, "Rect", layout.ContentX, y, layout.ContentW, S(self.H, s))
		self.HitRect = self.Rect
	end
	function item.Click(self)
		State.TextInput = self
		State.Bind = nil
		if State.DDOpen then State.DDOpen:Close() end
		MarkDirty()
	end
	return item
end

function Library.Button(tab, options)
	options = options or {}
	local item = NewItem(tab, BASE_ROW)
	item.Title = tostring_(options.title or "")
	item.Callback = options.callback
	item.Danger = options.danger == true
	item.FixedBottom = options.bottom == true
	item.Armed = false
	item.Box = NewSquare(BASE_CONTROL_W, 18, 4)
	item.Text = NewText(11, Fonts.Bold, true, 5)
	if item.FixedBottom then tab.FixedItems[#tab.FixedItems + 1] = item end
	function item.Draw(self, x, y, layout)
		local s = layout.Scale
		local bx, by = layout.ControlX, y + S(3, s)
		self.Box.Position = Vector2_new(bx, by)
		self.Box.Size = Vector2_new(layout.ControlW, S(18, s))
		self.Box.Color = self.Danger and Mix(State.Cur.element, State.Cur.danger, 0.35) or State.Cur.element
		self.Box.Visible = true
		ScaleText(self.Text, 11, s)
		self.Text.Text = FitText(SafeUpper(self.Title), layout.ControlW - S(12, s), self.Text.Size)
		self.Text.Position = Vector2_new(bx + layout.ControlW / 2, by + S(9, s))
		self.Text.Color = self.Danger and State.Cur.danger or State.Cur.accent
		self.Text.Visible = true
		SetRect(self, "ControlRect", bx, by, layout.ControlW, S(18, s))
		SetRect(self, "Rect", layout.ContentX, y, layout.ContentW, S(self.H, s))
		self.HitRect = self.ControlRect
	end
	function item.Pressed(self)
		self.Armed = true
		State.ActivePress = self
		MarkDirty()
	end
	function item.Released(self, mouseX, mouseY)
		if self.Armed and PointInRect(mouseX, mouseY, self.ControlRect) and type_(self.Callback) == "function" then pcall_(self.Callback) end
		self.Armed = false
		if State.ActivePress == self then State.ActivePress = nil end
		MarkDirty()
	end
	return item
end

function Library.Panel(tab, options)
	options = options or {}
	local item = NewItem(tab, tonumber_(options.height) or 56)
	item.Title = tostring_(options.title or "")
	item.LeftText, item.RightText = tostring_(options.leftText or ""), tostring_(options.rightText or "")
	item.OnLeft, item.OnRight = options.onLeft, options.onRight
	item.LeftBg, item.RightBg = NewSquare(BASE_CONTROL_W / 2, 48, 6), NewSquare(BASE_CONTROL_W / 2, 48, 6)
	item.Label = NewText(13, Fonts.System, false, 4)
	item.LeftLabel, item.RightLabel = NewText(12, Fonts.Bold, false, 7), NewText(11, Fonts.System, false, 7)
	function item.Draw(self, x, y, layout)
		local s = layout.Scale
		ScaleText(self.Label, 13, s)
		self.Label.Text = FitText(self.Title, layout.LeftW - S(8, s), self.Label.Size)
		self.Label.Position = Vector2_new(x, y + S(6, s))
		self.Label.Color = State.Cur.textDim
		self.Label.Visible = self.Title ~= ""
		local bx, by = layout.ControlX, y + S(4, s)
		local half = math_floor((layout.ControlW - S(8, s)) / 2)
		local panelHeight = S(self.H, s) - S(8, s)
		self.LeftBg.Position = Vector2_new(bx, by)
		self.LeftBg.Size = Vector2_new(half, panelHeight)
		self.RightBg.Position = Vector2_new(bx + half + S(8, s), by)
		self.RightBg.Size = Vector2_new(half, panelHeight)
		self.LeftBg.Color = State.Cur.element
		self.RightBg.Color = State.Cur.elementAlt
		self.LeftBg.Visible = true
		self.RightBg.Visible = true
		ScaleText(self.LeftLabel, 12, s); ScaleText(self.RightLabel, 11, s)
		self.LeftLabel.Text = FitText(self.LeftText, half - S(16, s), self.LeftLabel.Size)
		self.RightLabel.Text = FitText(self.RightText, half - S(16, s), self.RightLabel.Size)
		self.LeftLabel.Position = Vector2_new(bx + S(8, s), by + S(8, s))
		self.RightLabel.Position = Vector2_new(bx + half + S(16, s), by + S(8, s))
		self.LeftLabel.Color = State.Cur.text
		self.RightLabel.Color = State.Cur.textDim
		self.LeftLabel.Visible = true
		self.RightLabel.Visible = true
		SetRect(self, "Rect", layout.ContentX, y, layout.ContentW, S(self.H, s))
		self.HitRect = self.Rect
		SetRect(self, "LeftRect", bx, by, half, panelHeight)
		SetRect(self, "RightRect", bx + half + S(8, s), by, half, panelHeight)
	end
	function item.Released(self, mouseX, mouseY)
		if PointInRect(mouseX, mouseY, self.LeftRect) and type_(self.OnLeft) == "function" then pcall_(self.OnLeft) return end
		if PointInRect(mouseX, mouseY, self.RightRect) and type_(self.OnRight) == "function" then pcall_(self.OnRight) end
	end
	return item
end








local function HSVtoRGB(h, s, v)
	local c = v * s
	local x = c * (1 - math_abs((h * 6) % 2 - 1))
	local m = v - c
	local r, g, b = 0, 0, 0
	local sector = math_floor(h * 6)
	if sector == 0 then r, g, b = c, x, 0
	elseif sector == 1 then r, g, b = x, c, 0
	elseif sector == 2 then r, g, b = 0, c, x
	elseif sector == 3 then r, g, b = 0, x, c
	elseif sector == 4 then r, g, b = x, 0, c
	else r, g, b = c, 0, x end
	return Color3_fromRGB(math_floor((r + m) * 255), math_floor((g + m) * 255), math_floor((b + m) * 255))
end


local function RGBtoHSV(r, g, b)
	r, g, b = r / 255, g / 255, b / 255
	local max, min = math_max(r, g, b), math_min(r, g, b)
	local d = max - min
	local h = 0
	if d > 0 then
		if max == r then h = ((g - b) / d) % 6
		elseif max == g then h = (b - r) / d + 2
		else h = (r - g) / d + 4 end
		h = h / 6
	end
	local s = max == 0 and 0 or d / max
	return h, s, max
end

function Library.ColorPicker(tab, options)
	options = options or {}
	local item = NewItem(tab, BASE_ROW)
	item.Title = tostring_(options.title or "")
	item.Target = options.target
	item.Open = false
	RegisterKey(tab, item, options.key)

	
	item.Label   = NewText(13, Fonts.System, false, 4)
	item.Preview = NewSquare(18, 18, 5)
	item.PickerBg     = NewSquare(180, 130, 8)
	item.PickerBorder = NewSquare(180, 130, 9, false)
	item.TitleBar     = NewSquare(180, 22, 9)
	item.TitleStrip   = NewSquare(180, 1, 9)
	item.HueBar       = NewSquare(170, 12, 10)
	item.HueOverlay   = {}  
	for i = 1, 16 do item.HueOverlay[i] = NewSquare(1, 12, 11) end
	item.HueCursor    = NewSquare(3, 14, 12, false)
	item.SVGrid       = {}  
	for i = 1, 49 do item.SVGrid[i] = NewSquare(1, 1, 11) end
	item.SVCursor     = NewSquare(5, 5, 12, false)
	item.HexText      = NewText(11, Fonts.System, false, 12)
	item.PopupTitle   = NewText(13, Fonts.Bold, false, 12)

	
	local hue, sat, val = 0, 1, 1
	
	
	local function syncFromTheme()
		local c = Library.CustomTheme[item.Target]
		if c then
			local r = ColorChannel(c, "R")
			local g = ColorChannel(c, "G")
			local b = ColorChannel(c, "B")
			hue, sat, val = RGBtoHSV(r, g, b)
		end
	end
	syncFromTheme()

	local function applyColor()
		
		
		local color = HSVtoRGB(Clamp(hue, 0, 1), Clamp(sat, 0, 1), Clamp(val, 0, 1))
		Library.CustomTheme[item.Target] = color
		ApplyCustomTheme()
		MarkDirty()
	end

	function item.Click(self, mouseX, mouseY)
		if not self.Open then
			syncFromTheme()
			self.Open = true
			MarkDirty()
			return
		end
		
		
		if self.PickerRect and PointInRect(mouseX, mouseY, self.PickerRect) then return end
		self.Open = false
		if State.ActiveSlider == item then State.ActiveSlider = nil end
		MarkDirty()
	end

	function item.Draw(self, x, y, layout)
		local s = layout.Scale
		ScaleText(self.Label, 13, s)
		self.Label.Text = FitText(self.Title, layout.LeftW - S(8, s), self.Label.Size)
		self.Label.Position = Vector2_new(x, y + S(6, s))
		self.Label.Color = State.Cur.text
		self.Label.Visible = true

		
		local bx, by, bw = layout.ControlX, y + S(3, s), layout.ControlW
		local psize = S(20, s)
		self.Preview.Position = Vector2_new(bx + bw - psize - S(2, s), by)
		self.Preview.Size = Vector2_new(psize, psize)
		self.Preview.Color = Library.CustomTheme[self.Target] or State.Cur.accent
		self.Preview.Visible = true

		SetRect(self, "Rect", layout.ContentX, y, layout.ContentW, S(self.H, s))
		self.HitRect = self.Rect

		
		-- The picker opens in its OWN themed box to the right of the menu window.
		local menuW = S(BASE_W, s)
		local pickerW = S(200, s)
		local pickerH = S(222, s)
		local px = State.WinX + menuW + S(10, s)
		local py = State.WinY + S(6, s)
		if px + pickerW > ViewportW - S(8, s) then px = State.WinX - pickerW - S(10, s) end
		if py + pickerH > ViewportH - S(8, s) then py = ViewportH - pickerH - S(8, s) end
		if py < S(4, s) then py = S(4, s) end
		bx = px
		bw = pickerW
		local pickerY = py

		if self.Open then
			-- Themed window shell: background, accent border, and a title bar
			-- that matches the main menu's chrome (topbar / sidebar colors).
			self.PickerBg.Position = Vector2_new(bx, pickerY)
			self.PickerBg.Size = Vector2_new(bw, pickerH)
			self.PickerBg.Color = State.Cur.bg
			self.PickerBg.Visible = true

			self.PickerBorder.Position = Vector2_new(bx, pickerY)
			self.PickerBorder.Size = Vector2_new(bw, pickerH)
			self.PickerBorder.Color = State.Cur.border
			self.PickerBorder.Visible = true

			local titleH = S(24, s)
			self.TitleBar.Position = Vector2_new(bx, pickerY)
			self.TitleBar.Size = Vector2_new(bw, titleH)
			self.TitleBar.Color = State.Cur.topbar
			self.TitleBar.Visible = true

			-- An accent strip under the title, like the menu's sidebar bar
			self.TitleStrip.Position = Vector2_new(bx, pickerY + titleH - S(1, s))
			self.TitleStrip.Size = Vector2_new(bw, S(1, s))
			self.TitleStrip.Color = State.Cur.accent
			self.TitleStrip.Visible = true

			ScaleText(self.PopupTitle, 13, s)
			self.PopupTitle.Text = FitText(SafeUpper(self.Title), bw - S(16, s), self.PopupTitle.Size)
			self.PopupTitle.Position = Vector2_new(bx + S(8, s), pickerY + S(5, s))
			self.PopupTitle.Color = State.Cur.accent
			self.PopupTitle.Visible = true

			-- A shared centered column so the picker reads as one unit
			local colW = S(140, s)
			local colX = bx + (bw - colW) / 2

			-- Hue bar (the main control, per request: just for changing the hue)
			local hbY = pickerY + titleH + S(10, s)
			local hbX = colX
			local hbW = colW
			local segW = hbW / 16
			for i = 1, 16 do
				local segHue = (i - 1) / 16
				self.HueOverlay[i].Position = Vector2_new(hbX + (i - 1) * segW, hbY)
				self.HueOverlay[i].Size = Vector2_new(math_max(1, segW + 1), S(12, s))
				self.HueOverlay[i].Color = HSVtoRGB(segHue, 1, 1)
				self.HueOverlay[i].Visible = true
			end

			local hcx = hbX + hue * hbW
			self.HueCursor.Position = Vector2_new(hcx - S(1, s), hbY - S(2, s))
			self.HueCursor.Size = Vector2_new(S(3, s), S(16, s))
			self.HueCursor.Visible = true

			-- Saturation / value grid (7x7) below the hue bar, same column width
			local gridY = hbY + S(12, s) + S(8, s)
			local gridSize = colW
			local cellSize = gridSize / 7
			for row = 0, 6 do
				for col = 0, 6 do
					local sVal = col / 6
					local vVal = 1 - row / 6
					local idx = row * 7 + col + 1
					self.SVGrid[idx].Position = Vector2_new(hbX + col * cellSize, gridY + row * cellSize)
					self.SVGrid[idx].Size = Vector2_new(math_max(1, cellSize + 1), math_max(1, cellSize + 1))
					self.SVGrid[idx].Color = HSVtoRGB(hue, sVal, vVal)
					self.SVGrid[idx].Visible = true
				end
			end

			local scx = hbX + sat * gridSize
			local scy = gridY + (1 - val) * gridSize
			self.SVCursor.Position = Vector2_new(scx - S(2, s), scy - S(2, s))
			self.SVCursor.Size = Vector2_new(S(5, s), S(5, s))
			self.SVCursor.Visible = true

			-- Hex readout centered below the grid
			local c = Library.CustomTheme[self.Target]
			local hexStr = string_format("#%02X%02X%02X", ColorChannel(c, "R"), ColorChannel(c, "G"), ColorChannel(c, "B"))
			ScaleText(self.HexText, 11, s)
			self.HexText.Text = hexStr
			self.HexText.Position = Vector2_new(colX, gridY + gridSize + S(8, s))
			self.HexText.Color = State.Cur.accent
			self.HexText.Visible = true

			self.HueRect = { hbX, hbY, hbW, S(12, s) }
			self.SVRect  = { hbX, gridY, gridSize, gridSize }
			self.PickerRect = { bx, pickerY, bw, pickerH }
		else
			
			self.PickerBg.Visible = false
			self.PickerBorder.Visible = false
			self.TitleBar.Visible = false
			self.TitleStrip.Visible = false
			self.HueCursor.Visible = false
			self.SVCursor.Visible = false
			self.HexText.Visible = false
			self.PopupTitle.Visible = false
			for i = 1, 16 do self.HueOverlay[i].Visible = false end
			for i = 1, 49 do self.SVGrid[i].Visible = false end
			self.PickerRect = nil
			self.HueRect = nil
			self.SVRect = nil
		end

		
		-- Extend the hit region to cover BOTH the row and the side window so the
		-- row toggles the popup and hue/SV clicks inside the window register.
		if self.Open and self.PickerRect then
			local row = self.Rect
			local pr = self.PickerRect
			local left = math_min(row[1], pr[1])
			local top = math_min(row[2], pr[2])
			local right = math_max(row[1] + row[3], pr[1] + pr[3])
			local bottom = math_max(row[2] + row[4], pr[2] + pr[4])
			self.HitRect = { left, top, right - left, bottom - top }
		end
	end

	
	function item.Pressed(self, mouseX, mouseY)
		if not self.Open then return end
		if self.HueRect and PointInRect(mouseX, mouseY, self.HueRect) then
			hue = Clamp((mouseX - self.HueRect[1]) / math_max(1, self.HueRect[3]), 0, 1)
			State.ActiveSlider = self
			applyColor()
			return
		end
		if self.SVRect and PointInRect(mouseX, mouseY, self.SVRect) then
			sat = Clamp((mouseX - self.SVRect[1]) / math_max(1, self.SVRect[3]), 0, 1)
			val = Clamp(1 - (mouseY - self.SVRect[2]) / math_max(1, self.SVRect[4]), 0, 1)
			State.ActiveSlider = self
			applyColor()
			return
		end
	end

	
	function item.UpdateDrag(self, mouseX)
		if not self.Open then return end
		if self.HueRect and PointInRect(mouseX, State.MY, self.HueRect) then
			hue = Clamp((mouseX - self.HueRect[1]) / math_max(1, self.HueRect[3]), 0, 1)
			applyColor()
			return
		end
		if self.SVRect then
			
			sat = Clamp((mouseX - self.SVRect[1]) / math_max(1, self.SVRect[3]), 0, 1)
			val = Clamp(1 - (State.MY - self.SVRect[2]) / math_max(1, self.SVRect[4]), 0, 1)
			applyColor()
		end
	end

	function item.Released(self)
		if State.ActiveSlider == self then State.ActiveSlider = nil end
	end

	return item
end


local function MakeTabVisuals()
	return { Hover = NewSquare(BASE_SIDEBAR, 32, 3), Bar = NewSquare(3, 32, 5), Text = NewText(13, Fonts.Bold, false, 4) }
end

function Library.AddTab(title)
	local tab = {
		Title = tostring_(title or ""), Name = SafeUpper(title),
		Items = {}, FixedItems = {}, FixedLayout = {}, RowGap = BASE_GAP, Visuals = MakeTabVisuals(),
	}
	tab.AddSection  = function(_, v) return Library.Section(tab, v) end
	tab.AddLabel    = function(_, v) return Library.Label(tab, v) end
	tab.AddToggle   = function(_, v) return Library.Toggle(tab, v) end
	tab.AddSlider   = function(_, v) return Library.Slider(tab, v) end
	tab.AddDropdown = function(_, v) return Library.Dropdown(tab, v) end
	tab.AddKeybind  = function(_, v) return Library.Keybind(tab, v) end
	tab.AddTextbox  = function(_, v) return Library.Textbox(tab, v) end
	tab.AddButton   = function(_, v) return Library.Button(tab, v) end
	tab.AddColorPicker = function(_, v) return Library.ColorPicker(tab, v) end
	tab.AddPanel    = function(_, v) return Library.Panel(tab, v) end
	State.Tabs[#State.Tabs + 1] = tab
	State.Scroll[#State.Scroll + 1] = 0
	return tab
end


local function ThemeNames()
	local names = {}
	for name in pairs(Themes) do names[#names + 1] = name end
	table.sort(names)
	return names
end

-- Forward-declared: assigned in the config-file section below. ApplyTheme /
-- SaveTheme / SaveConfig call it to persist the active session.
local SaveSessionState

local function ApplyTheme(name)
	local resolved, canonical = ResolveTheme(name)
	State.Tgt = resolved
	for i = 1, #ThemeKeys do State.Cur[ThemeKeys[i]] = resolved[ThemeKeys[i]] end
	State.ThemeName = canonical
	-- Keep the custom-theme name in sync with the applied theme so color edits
	-- target the active theme key instead of snapping back to "Custom".
	Library.CustomThemeName = canonical
	MarkDirty(true)
	local themeControl = ByKey["SETTINGS.theme"]
	if themeControl then themeControl.Value = canonical end
	if SaveSessionState then SaveSessionState() end
	return canonical == name
end
Library.SetTheme = ApplyTheme

local function ApplyCustomTheme()
	local ct = Library.CustomTheme
	-- Color modifications update the ACTIVE theme key directly (tracked by
	-- ApplyTheme), never reverting to a hardcoded "Custom" entry.
	local name = Library.CustomThemeName or State.ThemeName or "Custom"
	Themes[name] = { Background = ct.Background, Accent = ct.Accent, Text = ct.Text, Borders = ct.Borders }
	return ApplyTheme(name)
end
Library.ApplyCustomTheme = ApplyCustomTheme




local function Color3RGB(c)
	return string_format("%d,%d,%d", ColorChannel(c, "R"), ColorChannel(c, "G"), ColorChannel(c, "B"))
end

local function CustomSlider(parent, title, channel, target)
	
	
	local currentThemeTarget = Library.CustomTheme and Library.CustomTheme[target]
	local channelIndex = (channel == "R" and 1 or (channel == "G" and 2 or 3))
	local rawValue = currentThemeTarget and (currentThemeTarget[channelIndex] or currentThemeTarget[channel]) or 1 
	parent:AddSlider({
		title = title,
		key = "custom_" .. target .. "_" .. channel,
		default = math_floor(rawValue * 255 + 0.5),
		min = 0, max = 255,
		callback = function(value)
			local c = Library.CustomTheme[target]
			local r, g, b = ColorChannel(c, "R"), ColorChannel(c, "G"), ColorChannel(c, "B")
			if channel == "R" then r = value
			elseif channel == "G" then g = value
			else b = value end
			Library.CustomTheme[target] = Color3_fromRGB(Clamp(r, 0, 255), Clamp(g, 0, 255), Clamp(b, 0, 255))
			ApplyCustomTheme()
		end,
	})
end

local function EncodeCustomTheme()
	local ct = Library.CustomTheme
	return string_format('{"Background":[%s],"Accent":[%s],"Text":[%s],"Borders":[%s]}',
		Color3RGB(ct.Background), Color3RGB(ct.Accent), Color3RGB(ct.Text), Color3RGB(ct.Borders))
end

local function ParseRGBTriple(s)
	local r, g, b = s:match("(%-?%d+),(%-?%d+),(%-?%d+)")
	if not r then return nil end
	return tonumber_(r), tonumber_(g), tonumber_(b)
end


local GameNameCache = nil
local function GetGameName()
	if GameNameCache ~= nil then return GameNameCache end
	local name = CachedGameName or "GAME"
	if name == "GAME" and type_(getgamename) == "function" then
		local ok, value = pcall_(getgamename)
		if ok and value ~= nil and tostring_(value) ~= "" then name = tostring_(value) end
	end
	if name == "GAME" and game ~= nil then
		local ok, value = pcall_(function()
			if type_(game.GetName) == "function" then return game:GetName() end
			return SafeRead(game, "Name")
		end)
		if ok and value ~= nil and tostring_(value) ~= "" then name = tostring_(value) end
	end
	if MarketplaceService and game and SafeRead(game, "PlaceId") ~= nil then
		local ok, info = pcall_(function() return MarketplaceService:GetProductInfo(SafeRead(game, "PlaceId")) end)
		if ok and type_(info) == "table" and info.Name and info.Name ~= "" then
			name = tostring_(info.Name)
		end
	end
	GameNameCache = name
	return name
end

local function GetEnvironmentInfo()
	local placeId   = SafeRead(game, "PlaceId")
	local universeId= SafeRead(game, "GameId")
	return {
		Name      = GetGameName(),
		PlaceId   = placeId    ~= nil and tostring_(placeId)    or "unknown",
		UniverseId= universeId ~= nil and tostring_(universeId) or "unknown",
	}
end

local function IsGameQuery(query)
	if type_(query) ~= "string" then return false end
	return string_lower(query):gsub("%s+", " "):match("^%s*(.-)%s*$") == "what game am i in"
end

function Library.HandleDiagnosticQuery(query)
	if not IsGameQuery(query) then return nil end
	local info = GetEnvironmentInfo()
	return string_format("Game: %s | ID: %s | Universe: %s", info.Name, info.PlaceId, info.UniverseId), info
end
Library.Query              = Library.HandleDiagnosticQuery
Library.GetEnvironmentInfo= GetEnvironmentInfo


local CONFIG_ROOT = "vanta"
local CONFIG_PATH = "C:\\matcha\\workspace\\vanta"

local function EnsureConfigFolder()
	if type_(isfolder) == "function" then
		local ok, exists = pcall_(isfolder, CONFIG_ROOT)
		if ok and exists then return end
	end
	if type_(makefolder) == "function" then pcall_(makefolder, CONFIG_ROOT) end
end

local function SanitizeName(value)
	local name = tostring_(value or ""):gsub("[^%w_%-]", "")
	return name ~= "" and name or "config"
end

local function ConfigFile(value)
	return CONFIG_ROOT .. "/" .. SanitizeName(value) .. ".json"
end

local function BuildConfig()
	local values = {}
	for key, control in pairs(ByKey) do values[key] = control.Value end
	return { fmt = 1, theme = State.ThemeName, values = values }
end

local function JsonEncode(value)
	if HttpService and type_(HttpService.JSONEncode) == "function" then
		local ok, result = pcall_(function() return HttpService:JSONEncode(value) end)
		if ok then return result end
	end
	local function encode(item)
		if type_(item) == "string" then return '"' .. item:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"' end
		if type_(item) == "number" or type_(item) == "boolean" then return tostring_(item) end
		if type_(item) ~= "table" then return "null" end
		local parts = {}
		for k, v in pairs(item) do parts[#parts + 1] = '"' .. tostring_(k) .. '":' .. encode(v) end
		return "{" .. table_concat(parts, ",") .. "}"
	end
	return encode(value)
end

local function JsonDecode(value)
	if HttpService and type_(HttpService.JSONDecode) == "function" then
		local ok, result = pcall_(function() return HttpService:JSONDecode(value) end)
		if ok then return result end
	end
	return nil
end

local function ApplyConfigString(value)
	local decoded = JsonDecode(value)
	if type_(decoded) ~= "table" then Library.Notify("CONFIG", "Invalid config data", "error") return false end
	if decoded.theme then ApplyTheme(decoded.theme) end
	if type_(decoded.values) == "table" then
		for key, setting in pairs(decoded.values) do
			local control = ByKey[key]
			if control and type_(control.SetValue) == "function" then pcall_(control.SetValue, control, setting, true) end
		end
	end
	MarkDirty(true)
	Library.Notify("CONFIG", "Config applied", "success")
	return true
end

function Library.GetConfigSlots()
	EnsureConfigFolder()
	local output = {}
	if type_(listfiles) == "function" then
		local ok, files = pcall_(listfiles, CONFIG_ROOT)
		if ok and type_(files) == "table" then
			for i = 1, #files do
				local path = tostring_(files[i])
				-- Only real config files (folders like "themes" and stray
				-- non-JSON files must never appear as config slots).
				if path:match("%.json$") then
					local name = path:gsub("^.*[\\/]", ""):gsub("%.json$", "")
					if name ~= "" then output[#output + 1] = name end
				end
			end
		end
	end
	table.sort(output)
	return output
end

function Library.SaveConfig(name)
	EnsureConfigFolder()
	if type_(writefile) ~= "function" then Library.Notify("CONFIG", "writefile unavailable", "error") return false end
	local slot = SanitizeName(name)
	local ok = pcall_(writefile, ConfigFile(slot), JsonEncode(BuildConfig()))
	if ok then
		Library.ActiveConfig = slot
		if SaveSessionState then SaveSessionState() end
	end
	Library.Notify("CONFIG", ok and ("Saved to \"" .. slot .. "\"") or "Failed to save", ok and "success" or "error")
	return ok
end

function Library.LoadConfig(name)
	EnsureConfigFolder()
	if type_(readfile) ~= "function" then Library.Notify("CONFIG", "readfile unavailable", "error") return false end
	local ok, value = pcall_(readfile, ConfigFile(name))
	if not ok or type_(value) ~= "string" then Library.Notify("CONFIG", "Config not found", "error") return false end
	if ApplyConfigString(value) then
		Library.ActiveConfig = SanitizeName(name)
		if SaveSessionState then SaveSessionState() end
		return true
	end
	return false
end

function Library.DeleteConfig(name)
	if type_(delfile) == "function" then pcall_(delfile, ConfigFile(name)) end
	Library.Notify("CONFIG", "Config deleted", "warn")
	return true
end

function Library.RenameConfig(oldName, newName)
	if type_(readfile) ~= "function" or type_(writefile) ~= "function" then return false end
	local oldSlot, newSlot = SanitizeName(oldName), SanitizeName(newName)
	if oldSlot == newSlot then return false end
	local ok, value = pcall_(readfile, ConfigFile(oldSlot))
	if not ok or type_(value) ~= "string" then return false end
	if not pcall_(writefile, ConfigFile(newSlot), value) then return false end
	if type_(delfile) == "function" then pcall_(delfile, ConfigFile(oldSlot)) end
	Library.Notify("CONFIG", "Config renamed", "success")
	return true
end

function Library.CopySettings()
	if type_(setclipboard) == "function" and pcall_(setclipboard, JsonEncode(BuildConfig())) then Library.Notify("SETTINGS", "Settings copied", "info") return true end
	return false
end

--==[ 18a. SESSION STATE (vanta/settings.json) ]===============================
-- Persists the active theme name + active config slot so the UI restores the
-- exact session on the next execution.
local SETTINGS_FILE = CONFIG_ROOT .. "/settings.json"
local LastSessionSig = ""

SaveSessionState = function()
	if type_(writefile) ~= "function" then return false end
	local theme = State.ThemeName or DEFAULT_THEME
	local config = Library.ActiveConfig
	-- Cheap change-detection: only touch disk when the active theme/config
	-- actually changed (color-drag ticks re-apply the same theme name).
	local sig = tostring_(theme) .. "|" .. tostring_(config or "")
	if sig == LastSessionSig then return true end
	LastSessionSig = sig
	local payload = JsonEncode({ theme = theme, config = config })
	if type_(payload) ~= "string" then return false end
	local ok = pcall_(writefile, SETTINGS_FILE, payload)
	return ok == true
end

local function LoadSessionState()
	if type_(readfile) ~= "function" then return false end
	local ok, raw = pcall_(readfile, SETTINGS_FILE)
	if not ok or type_(raw) ~= "string" or raw == "" then return false end
	local data = JsonDecode(raw)
	if type_(data) ~= "table" then return false end
	if type_(data.theme) == "string" and data.theme ~= "" then
		pcall_(ApplyTheme, data.theme)
	end
	if type_(data.config) == "string" and data.config ~= "" then
		pcall_(Library.LoadConfig, data.config)
	end
	MarkDirty(true)
	return true
end

--==[ 18b. THEME FILE SYSTEM (vanta/themes) ]=================================
-- Custom themes are persisted as JSON files inside the vanta folder so the
-- preset dropdown and the file system stay in sync across sessions.
local THEME_DIR = CONFIG_ROOT .. "/themes"

local function EnsureThemeDir()
	if type_(isfolder) == "function" then
		local ok, exists = pcall_(isfolder, THEME_DIR)
		if ok and exists then return end
	end
	if type_(makefolder) == "function" then pcall_(makefolder, THEME_DIR) end
end

local function ThemeFile(value)
	return THEME_DIR .. "/" .. SanitizeName(value) .. ".json"
end

-- Serialize a saved theme to a JSON string: {Background:[r,g,b],...}
local function SerializeTheme()
	local ct = Library.CustomTheme
	local function rgb(c)
		return string_format("[%d,%d,%d]", ColorChannel(c, "R"), ColorChannel(c, "G"), ColorChannel(c, "B"))
	end
	return string_format('{"Background":%s,"Accent":%s,"Text":%s,"Borders":%s}',
		rgb(ct.Background), rgb(ct.Accent), rgb(ct.Text), rgb(ct.Borders))
end

-- Parse a saved theme JSON string into { Background=Color3, Accent=Color3, ... }.
local function DeserializeTheme(raw)
	if type_(raw) ~= "string" then return nil end
	local data = JsonDecode(raw)
	if type_(data) ~= "table" then return nil end
	local function toColor(t)
		if type_(t) ~= "table" then return nil end
		local r, g, b = tonumber_(t[1] or t.R), tonumber_(t[2] or t.G), tonumber_(t[3] or t.B)
		if r and g and b then return Color3_fromRGB(Clamp(r,0,255), Clamp(g,0,255), Clamp(b,0,255)) end
		return nil
	end
	local bg = toColor(data.Background)
	if bg == nil then return nil end
	return {
		Background = bg,
		Accent     = toColor(data.Accent)     or State.Cur.accent,
		Text       = toColor(data.Text)       or State.Cur.text,
		Borders    = toColor(data.Borders)    or State.Cur.border,
	}
end

function Library.SaveTheme(name)
	EnsureThemeDir()
	if type_(writefile) ~= "function" then Library.Notify("THEME", "writefile unavailable", "error") return false end
	local slot = SanitizeName(name)
	local ok = pcall_(writefile, ThemeFile(slot), SerializeTheme())
	if ok then
		-- Remember the chosen name so subsequent color edits keep applying under it.
		Library.CustomThemeName = slot
		if SaveSessionState then SaveSessionState() end
		-- Register the saved theme under its chosen name so it applies correctly
		-- and stays selectable in the preset dropdown this session and after reload.
		Themes[slot] = {
			Background = Library.CustomTheme.Background,
			Accent     = Library.CustomTheme.Accent,
			Text       = Library.CustomTheme.Text,
			Borders    = Library.CustomTheme.Borders,
		}
		Library.Notify("THEME", "Theme \"" .. slot .. "\" saved", "success")
		-- Refresh the preset dropdown so the saved theme is selectable.
		local themeControl = ByKey["SETTINGS.theme"]
		if themeControl then
			themeControl:SetOptions(ThemeNames())
			themeControl:SetValue(slot, true)
		end
		MarkDirty(true)
	else
		Library.Notify("THEME", "Failed to save theme", "error")
	end
	return ok
end

function Library.LoadSavedThemes()
	EnsureThemeDir()
	if type_(listfiles) ~= "function" then return end
	local ok, files = pcall_(listfiles, THEME_DIR)
	if not ok or type_(files) ~= "table" then return end
	for i = 1, #files do
		local path = tostring_(files[i])
		if type_(readfile) == "function" and path:match("%.json$") then
			local name = path:gsub("^.*[\\/]", ""):gsub("%.json$", "")
			local rok, raw = pcall_(readfile, path)
			if rok and type_(raw) == "string" then
				local theme = DeserializeTheme(raw)
				if theme then Themes[name] = { Background = theme.Background, Accent = theme.Accent, Text = theme.Text, Borders = theme.Borders } end
			end
		end
	end
end
Library.LoadSavedThemes = Library.LoadSavedThemes



function Library.SetMenuOpen(value) State.Open = value == true; MarkDirty(true) end

local function SetScale(scale)
	local old = State.Scale
	scale = Clamp(scale, BASE_SCALE_MIN, BASE_SCALE_MAX)
	if old ~= scale then
		local ratio = scale / math_max(0.001, old)
		for i = 1, #State.Scroll do State.Scroll[i] = (State.Scroll[i] or 0) * ratio end
	end
	State.Scale = scale
	State.WindowW, State.WindowH = S(BASE_W, scale), S(BASE_H, scale)
	MarkDirty(true)
end

function Library.SetSize(width, height)
	width, height = tonumber_(width), tonumber_(height)
	if not width or not height or width <= 0 or height <= 0 then return false end
	SetScale(math_min(width / BASE_W, height / BASE_H))
	return true, State.WindowW, State.WindowH
end

function Library.GetSize() return State.WindowW, State.WindowH, State.Scale end






local function StartAvatarLoad()
	if not LocalPlayer then return end
	local userId = SafeRead(LocalPlayer, "UserId")
	if type_(userId) ~= "number" then return end
	task.spawn(function()
		if type_(httpget) ~= "function" then return end
		
		local apiUrl = string_format(
			"https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=420x420&format=Png&isCircular=false",
			userId
		)
		local ok1, json = pcall_(httpget, apiUrl)
		if not ok1 or type_(json) ~= "string" then return end
		local imageUrl = string_match(json, '"imageUrl"%s*:%s*"([^"]+)"')
		if not imageUrl then return end
		imageUrl = imageUrl:gsub("\\/", "/")
		
		local ok2, imgData = pcall_(httpget, imageUrl)
		if not ok2 or type_(imgData) ~= "string" or #imgData < 100 then return end
		
		local b1, b2 = string.byte(imgData, 1, 2)
		if b1 ~= 137 or b2 ~= 80 then return end
		Win.Avatar.Data = imgData
	end)
end


local function TabSection(tab, title) return tab:AddSection(title) end

local function BuildTabs()
	local t1 = Library.AddTab("Tab One")
	TabSection(t1, "MAIN")
	t1:AddToggle({ title = "Enabled", key = "enable", default = true })
	t1:AddKeybind({ title = "Activate Key", key = "firekey", default = 161 })
	TabSection(t1, "COMBAT")
	t1:AddSlider({ title = "Strength", key = "strength", default = 80, min = 0, max = 100, suffix = "%" })
	t1:AddSlider({ title = "FOV", key = "fov", default = 90, min = 10, max = 360, suffix = "°" })
	t1:AddDropdown({ title = "Hitbox", key = "hitbox", default = "Head", options = { "Head", "Torso", "Legs" } })
	t1:AddToggle({ title = "Silent Aim", key = "silent" })
	t1:AddToggle({ title = "Auto Fire", key = "autofire" })
	TabSection(t1, "UTILS")
	t1:AddButton({ title = "Button 1", callback = function() Library.Notify("TAB ONE", "Button pressed", "info") end })
	t1:AddButton({ title = "Button 2", callback = function() Library.Notify("TAB ONE", "Another action", "info") end })
	t1:AddButton({ title = "Button 3", callback = function() Library.Notify("TAB ONE", "Third action", "info") end })
	t1:AddPanel({ leftText = "Weapon: AK47", rightText = "Status: Ready" })
	t1:AddDropdown({ title = "Mode", key = "mode", default = "Normal", options = { "Normal", "Aggressive", "Safe" } })
	t1:AddSlider({ title = "Recoil Control", key = "recoil", default = 50, min = 0, max = 100, suffix = "%" })

	local t2 = Library.AddTab("Tab Two")
	TabSection(t2, "RENDER")
	t2:AddToggle({ title = "ESP", key = "esp", default = true })
	t2:AddToggle({ title = "Boxes", key = "boxes", default = true })
	t2:AddToggle({ title = "Health Bar", key = "health" })
	t2:AddToggle({ title = "Tracers", key = "tracers" })
	t2:AddDropdown({ title = "Team Filter", key = "team", default = "All", options = { "All", "Enemies", "Friends" } })
	t2:AddSlider({ title = "Distance", key = "dist", default = 500, min = 100, max = 2000, step = 50, suffix = "m" })
	TabSection(t2, "VISUALS")
	t2:AddDropdown({ title = "Chams", key = "chams", default = "Off", options = { "Off", "Flat", "Shaded" } })
	t2:AddSlider({ title = "Glow Intensity", key = "glow", default = 30, min = 0, max = 100, suffix = "%" })
	t2:AddPanel({ leftText = "Render Mode: Fancy", rightText = "Players: 12" })
	t2:AddButton({ title = "Button 1", callback = function() Library.Notify("TAB TWO", "Button pressed", "info") end })
	t2:AddButton({ title = "Button 2", callback = function() Library.Notify("TAB TWO", "Second action", "info") end })
	t2:AddButton({ title = "Refresh ESP", callback = function() Library.Notify("RENDER", "ESP refreshed", "info") end })
	t2:AddDropdown({ title = "Overlay", key = "overlay", default = "Minimal", options = { "Minimal", "Full", "Off" } })

	local settings = Library.AddTab("SETTINGS")
	settings.RowGap = 8
	TabSection(settings, "THEMES")
	settings:AddDropdown({ title = "Preset Theme", key = "theme", default = DEFAULT_THEME, options = ThemeNames(), callback = ApplyTheme })
	TabSection(settings, "CUSTOM THEME")
	settings:AddButton({ title = "Apply Custom Theme", callback = ApplyCustomTheme })
	settings:AddColorPicker({ title = "Background", target = "Background" })
	settings:AddColorPicker({ title = "Accent",     target = "Accent" })
	settings:AddColorPicker({ title = "Text",       target = "Text" })
	settings:AddColorPicker({ title = "Borders",    target = "Borders" })
	local themeNameField = settings:AddTextbox({ title = "Theme Name", key = "themename", default = "My Theme", maxLength = 24, placeholder = "Theme name" })
	settings:AddButton({ title = "Save Custom Theme", callback = function()
		Library.SaveTheme(themeNameField and themeNameField.Value or "My Theme")
	end })

	TabSection(settings, "INTERFACE")
	settings:AddToggle({ title = "Rainbow Accent", key = "rainbow" })
	settings:AddToggle({ title = "In-Game Watermark", key = "watermark", default = true })
	settings:AddToggle({ title = "Toggle Notifications", key = "notifs", default = true })
	settings:AddToggle({ title = "Block Game Input", key = "blockinput" })
	settings:AddKeybind({ title = "Menu Key", key = "menukey", default = 161, callback = function(value) State.MenuKey = value or State.MenuKey end })
	settings:AddButton({ title = "Refresh Avatar", callback = function() StartAvatarLoad(); Library.Notify("VANTA", "Avatar refreshed", "info") end })
	
	TabSection(settings, "DANGER")
	settings:AddButton({ title = "Unload VANTA", danger = true, callback = function() Library.Unload() end })

	local configs = Library.AddTab("CONFIGS")
	configs.RowGap = 8
	local slotDropdown, nameField
	local function RefreshSlots()
		if not slotDropdown then return end
		local slots = Library.GetConfigSlots()
		slotDropdown.Options = #slots > 0 and slots or { "config" }
		slotDropdown:SetOptions(slotDropdown.Options)
	end
	local function SelectedName()
		return (nameField and nameField.Value ~= "" and nameField.Value) or (slotDropdown and slotDropdown.Value) or "config"
	end
	TabSection(configs, "SLOTS")
	nameField = configs:AddTextbox({ title = "Config Name", key = "name", default = "config", maxLength = 32, placeholder = "Type a unique name" })
	slotDropdown = configs:AddDropdown({ title = "Slot", key = "slot", default = "config", options = { "config" }, onOpen = RefreshSlots, callback = function(value)
		-- Only mirror the dropdown into the name field when the field hasn't been
		-- hand-edited yet (still shows the previous slot value). Never clobber a
		-- name the user typed manually.
		if nameField and (nameField.Value == "" or nameField.Value == slotDropdown.Value) then
			nameField:SetValue(value, true)
		end
	end })
	configs:AddButton({ title = "Save Config", callback = function() Library.SaveConfig(SelectedName()); RefreshSlots() end })
	configs:AddButton({ title = "Load Config", callback = function() Library.LoadConfig(SelectedName()) end })
	configs:AddButton({ title = "Rename Config", callback = function() local old = slotDropdown.Value; local new = SelectedName(); if Library.RenameConfig(old, new) then RefreshSlots() end end })
	configs:AddButton({ title = "Delete Slot", danger = true, callback = function() Library.DeleteConfig(slotDropdown.Value); RefreshSlots() end })
end

local function HookSettings()
	local rainbow   = ByKey["SETTINGS.rainbow"]
	local watermark = ByKey["SETTINGS.watermark"]
	local notifs    = ByKey["SETTINGS.notifs"]
	if rainbow then
		local base = rainbow.SetValue
		rainbow.SetValue = function(self, value, silent)
			base(self, value, silent)
			State.Rainbow = value == true
			if State.Rainbow then
				State.RainbowBase = State.RainbowBase or State.Cur.accent
			else
				
				State.Cur.accent = State.RainbowBase or (State.Tgt and State.Tgt.accent) or State.Cur.accent
				State.Cur.accent2 = Mix(State.Cur.accent, white, 0.18)
				State.RainbowBase = nil
			end
			MarkDirty()
		end
	end
	if watermark then
		local base = watermark.SetValue
		watermark.SetValue = function(self, value, silent) base(self, value, silent); State.Watermark = value == true; MarkDirty() end
	end
	if notifs then
		local base = notifs.SetValue
		notifs.SetValue = function(self, value, silent) base(self, value, silent); State.Notifs = value == true; MarkDirty() end
	end
	
	local blockinput = ByKey["SETTINGS.blockinput"]
	if blockinput then
		local base = blockinput.SetValue
		blockinput.SetValue = function(self, value, silent) base(self, value, silent); State.BlockInput = value == true; MarkDirty() end
	end
	local theme = ByKey["SETTINGS.theme"]
	if theme and theme.Value then ApplyTheme(theme.Value) end
end


local function KeyRising(code)
	if type_(iskeypressed) ~= "function" then return false end
	local ok, now = pcall_(iskeypressed, code)
	local previous = State.KeyStates[code] == true
	State.KeyStates[code] = ok and now == true
	return ok and now == true and not previous
end



local function KeyConsumedRecently(code)
	if code ~= State.KeyConsumeCode then return false end
	return (tick() - State.KeyConsumeStamp) < 0.15
end




local function HandleWheelInput(input)
	if not State.Open or State.ScrollMax <= 0 or not State.ScrollBounds then return end
	if not PointInRect(State.MX, State.MY, State.ScrollBounds) then return end
	local scrollDelta = nil
	if type_(getwheeldelta) == "function" then
		local ok, delta = pcall_(getwheeldelta)
		if ok and type_(delta) == "number" then
			scrollDelta = delta
		end
	end
	if type_(scrollDelta) ~= "number" or scrollDelta == 0 then
		scrollDelta = SafeRead(input, "WheelDelta")
	end
	if type_(scrollDelta) ~= "number" or scrollDelta == 0 then
		local delta = SafeRead(input, "Delta")
		if delta then scrollDelta = SafeRead(delta, "Z") or SafeRead(delta, 3) end
	end
	if type_(scrollDelta) ~= "number" or scrollDelta == 0 then
		local pos = SafeRead(input, "Position")
		if pos then scrollDelta = SafeRead(pos, "Z") or SafeRead(pos, 3) end
	end
	if type_(scrollDelta) == "number" and scrollDelta ~= 0 and scrollDelta == scrollDelta then
		local speed = tonumber_(Library.ScrollSpeed) or 32
		if speed <= 0 then speed = 32 end
		State.Scroll[State.Tab] = math_clamp((State.Scroll[State.Tab] or 0) - (scrollDelta * (speed * State.Scale)), 0, State.ScrollMax)
		State.Dirty = true
		State.LayoutDirty = true
	end
end






local function PollWheelScroll()
	if not State.Open or State.ScrollMax <= 0 or not State.ScrollBounds then return end
	if not PointInRect(State.MX, State.MY, State.ScrollBounds) then return end
	local step = S(96, State.Scale)
	local delta = 0
	if KeyRising(33) then delta = -1 end 
	if KeyRising(34) then delta = 1 end  
	if KeyRising(38) then delta = -1 end 
	if KeyRising(40) then delta = 1 end  
	if delta == 0 then return end
	State.Scroll[State.Tab] = math_clamp((State.Scroll[State.Tab] or 0) + delta * step, 0, State.ScrollMax)
	State.Dirty = true
	State.LayoutDirty = true
end

local function SetupInput()
	State.InputEvents = false
	local began = SafeRead(UserInputService, "InputBegan")
	if began ~= nil then
		local ok, connection = pcall_(function()
			return began:Connect(function(input, gameProcessed)
				State.InputEvents = true
				local inputType = input and SafeRead(input, "UserInputType")
				local inputTypeName = NormalizeKeyName(SafeRead(inputType, "Name") or tostring_(inputType or ""))
				local inputTypeValue = type_(inputType) == "number" and inputType or (inputType and SafeRead(inputType, "Value"))
				local mouseButton1Value = Enum and Enum.UserInputType and SafeRead(Enum.UserInputType.MouseButton1, "Value")
				local mouseWheelValue = Enum and Enum.UserInputType and SafeRead(Enum.UserInputType.MouseWheel, "Value")
				if inputTypeName == "MOUSEBUTTON1" or inputTypeName == "MOUSE1" or inputTypeName == "MOUSELEFT" or inputTypeValue == mouseButton1Value then
					State.MousePressPending = true; MarkDirty(); return
				elseif inputTypeName == "MOUSEWHEEL" or inputTypeName == "WHEEL" or inputTypeName == "SCROLLWHEEL" or inputTypeValue == mouseWheelValue then
					HandleWheelInput(input); return
				end
				local key = GetKeyCode(input)
				if type_(key) ~= "number" or key == 0 then
					local rawKey = input and SafeRead(input, "KeyCode")
					key = type_(rawKey) == "number" and rawKey or (rawKey and SafeRead(rawKey, "Value"))
				end
				if type_(key) == "number" and key > 0 then
					if State.Bind then
						State.Bind:SetValue(key)
						State.Bind = nil
						State.KeyConsumeCode = key; State.KeyConsumeStamp = tick()
						MarkDirty(true)
						return
					end
					if State.TextInput and ProcessTextInput(input) then
						State.KeyConsumeCode = key; State.KeyConsumeStamp = tick()
						return
					end
					if key == State.MenuKey then
						State.Open = not State.Open; MarkDirty(true); return
					end
				end
			end)
		end)
		if ok then AddConnection(connection) end
	end

	local changed = SafeRead(UserInputService, "InputChanged")
	if changed ~= nil then
		local ok, connection = pcall_(function()
			return changed:Connect(function(input)
				State.InputEvents = true
				HandleWheelInput(input)
				if State.Dragging then
					local pos = SafeRead(input, "Position")
					local px, py = SafeRead(pos, "X"), SafeRead(pos, "Y")
					if type_(px) == "number" and type_(py) == "number" then
						local delta = Vector2_new(px, py) - State.DragStart
						State.WinX = Clamp(State.StartPos.X + delta.X, -(State.WindowW - S(60, State.Scale)), ViewportW - S(60, State.Scale))
						State.WinY = Clamp(State.StartPos.Y + delta.Y, 0, ViewportH - S(40, State.Scale))
						MarkDirty(true)
					end
				end
			end)
		end)
		if ok then AddConnection(connection) end
	end

	local ended = SafeRead(UserInputService, "InputEnded")
	if ended ~= nil then
		local ok, connection = pcall_(function()
			return ended:Connect(function(input)
				local inputType = SafeRead(input, "UserInputType")
				local inputTypeName = NormalizeKeyName(SafeRead(inputType, "Name") or tostring_(inputType or ""))
				local inputTypeValue = type_(inputType) == "number" and inputType or SafeRead(inputType, "Value")
				local mouseButton1Value = Enum and Enum.UserInputType and SafeRead(Enum.UserInputType.MouseButton1, "Value")
				if inputTypeName == "MOUSEBUTTON1" or inputTypeName == "MOUSE1" or inputTypeName == "MOUSELEFT"
					or inputTypeValue == mouseButton1Value then
					State.Dragging = false; State.ScrollDrag = false; MarkDirty(true)
				end
			end)
		end)
		if ok then AddConnection(connection) end
	end
end


local function RenderCore(move, wy, metrics)
	local s = metrics.Scale
	Win.Bg.Position = Vector2_new(move, wy); Win.Bg.Size = Vector2_new(metrics.W, metrics.H)
	Win.Bg.Color = State.Cur.bg; Win.Bg.Visible = true
	Win.Border.Position = Vector2_new(move, wy); Win.Border.Size = Vector2_new(metrics.W, metrics.H)
	Win.Border.Color = State.Cur.border; Win.Border.Visible = true
	Win.Topbar.Position = Vector2_new(move, wy); Win.Topbar.Size = Vector2_new(metrics.W, metrics.Topbar)
	Win.Topbar.Color = State.Cur.topbar; Win.Topbar.Visible = true
	Win.TopLine.From = Vector2_new(move, wy + metrics.Topbar); Win.TopLine.To = Vector2_new(move + metrics.W, wy + metrics.Topbar)
	Win.TopLine.Color = State.Cur.border; Win.TopLine.Visible = true
	Win.Logo1.From = Vector2_new(move + S(14, s), wy + S(11, s)); Win.Logo1.To = Vector2_new(move + S(20, s), wy + S(18, s))
	Win.Logo2.From = Vector2_new(move + S(20, s), wy + S(18, s)); Win.Logo2.To = Vector2_new(move + S(26, s), wy + S(11, s))
	Win.Logo1.Color = State.Cur.accent; Win.Logo2.Color = State.Cur.accent
	Win.Logo1.Visible = true; Win.Logo2.Visible = true
	ScaleText(Win.Logo, 15, s); Win.Logo.Text = Library.Name; Win.Logo.Position = Vector2_new(move + S(34, s), wy + S(8, s))
	Win.Logo.Color = State.Cur.text; Win.Logo.Visible = true
	ScaleText(Win.Fps, 11, s); Win.Fps.Text = tostring_(State.FPS) .. " FPS"
	Win.Fps.Position = Vector2_new(move + metrics.W - S(12, s) - TextWidth(Win.Fps, #Win.Fps.Text * Win.Fps.Size * 0.55), wy + S(9, s))
	Win.Fps.Color = State.Cur.textDim; Win.Fps.Visible = true
	Win.Sidebar.Position = Vector2_new(move, wy + metrics.Topbar); Win.Sidebar.Size = Vector2_new(metrics.Sidebar, metrics.H - metrics.Topbar)
	Win.Sidebar.Color = State.Cur.sidebar; Win.Sidebar.Visible = true
	Win.SidebarLine.From = Vector2_new(move + metrics.Sidebar, wy + metrics.Topbar); Win.SidebarLine.To = Vector2_new(move + metrics.Sidebar, wy + metrics.H)
	Win.SidebarLine.Color = State.Cur.border; Win.SidebarLine.Visible = true
	for i = 1, #State.Tabs do
		local tab = State.Tabs[i]
		local y = wy + metrics.Topbar + S(6, s) + (i - 1) * S(32, s)
		local active = i == State.Tab
		tab.Visuals.Hover.Position = Vector2_new(move, y); tab.Visuals.Hover.Size = Vector2_new(metrics.Sidebar, S(32, s))
		tab.Visuals.Hover.Color = active and State.Cur.hover or State.Cur.sidebar; tab.Visuals.Hover.Visible = true
		ScaleText(tab.Visuals.Text, 13, s)
		tab.Visuals.Text.Text = FitText(tab.Name, metrics.Sidebar - S(32, s), tab.Visuals.Text.Size)
		tab.Visuals.Text.Position = Vector2_new(move + S(16, s), y + S(9, s))
		tab.Visuals.Text.Color = active and State.Cur.accent or State.Cur.textDim; tab.Visuals.Text.Visible = true
		tab.Visuals.Bar.Position = Vector2_new(move, y); tab.Visuals.Bar.Size = Vector2_new(S(3, s), S(32, s))
		tab.Visuals.Bar.Color = State.Cur.accent; tab.Visuals.Bar.Visible = active
	end
	local footerY = wy + metrics.H - metrics.Footer
	Win.Footer.Position = Vector2_new(move, footerY); Win.Footer.Size = Vector2_new(metrics.W, metrics.Footer)
	Win.Footer.Color = State.Cur.bottombar; Win.Footer.Visible = true
	Win.FooterLine.From = Vector2_new(move, footerY); Win.FooterLine.To = Vector2_new(move + metrics.W, footerY)
	Win.FooterLine.Color = State.Cur.border; Win.FooterLine.Visible = true
	Win.AvatarBox.Position = Vector2_new(move + S(10, s), footerY + S(4, s)); Win.AvatarBox.Size = Vector2_new(S(32, s), S(32, s))
	Win.AvatarBox.Color = State.Cur.element; Win.AvatarBox.Visible = true
	local avatarLoaded = SafeRead(Win.Avatar, "IsLoaded") == true
	if avatarLoaded then
		Win.Avatar.Position = Vector2_new(move + S(12, s), footerY + S(6, s)); Win.Avatar.Size = Vector2_new(S(28, s), S(28, s))
		Win.Avatar.Visible = true
		
	else
		Win.Avatar.Visible = false
	end
	ScaleText(Win.Name1, 13, s); ScaleText(Win.Name2, 11, s); ScaleText(Win.Foot, 12, s)
	Win.Name1.Text = FitText(tostring_(Win.UserName or (LocalPlayer and SafeRead(LocalPlayer, "Name") or "Player")), S(120, s), Win.Name1.Size)
	Win.Name2.Text = FitText(tostring_(Win.DisplayName or ""), S(120, s), Win.Name2.Size)
	Win.Name1.Position = Vector2_new(move + S(50, s), footerY + S(5, s))
	Win.Name2.Position = Vector2_new(move + S(50, s), footerY + S(22, s))
	Win.Name1.Color = State.Cur.text; Win.Name2.Color = State.Cur.textDim
	Win.Name1.Visible = true; Win.Name2.Visible = true
	Win.Foot.Text = Library.Name .. " v" .. Library.Version
	Win.Foot.Position = Vector2_new(move + metrics.W - S(12, s) - TextWidth(Win.Foot, #Win.Foot.Text * Win.Foot.Size * 0.55), footerY + S(14, s))
	Win.Foot.Color = State.Cur.accent; Win.Foot.Visible = true
	


	Win.WmBg.Visible = false; Win.WmBorder.Visible = false; Win.WmText.Visible = false
end

local function RenderTab(tab, move, wy, metrics)
	local scroll = State.Scroll[State.Tab] or 0
	local contentTop = wy + metrics.ContentY
	local fixedReserve = #tab.FixedItems > 0 and (metrics.Row + S(tab.RowGap, metrics.Scale) + S(8, metrics.Scale)) or 0
	local contentBottom = wy + metrics.Bottom - fixedReserve
	local layout = BuildLayout(move, metrics, contentBottom)
	layout.ContentTop = contentTop
	local cursor = contentTop - scroll
	for i = 1, #tab.Items do
		local item = tab.Items[i]
		item.Rect, item.HitRect = nil, nil
		if not item.FixedBottom then
			local itemHeight = S(item.H, metrics.Scale)
			item.Y = cursor
			if cursor >= contentTop and cursor + itemHeight <= contentBottom then
				item:Draw(layout.LeftX, cursor, layout)
			else
				item.Rect, item.HitRect, item.ListRect = nil, nil, nil
				if State.DDOpen == item then State.DDOpen, item.Open = nil, false end
			end
			cursor = cursor + itemHeight + S(tab.RowGap, metrics.Scale)
		end
	end
	local totalHeight = cursor - contentTop + scroll
	local available = math_max(S(1, metrics.Scale), contentBottom - contentTop)
	State.ScrollMax = math_max(0, totalHeight - available)
	State.ScrollBounds = SetRect(State, "ScrollBounds", layout.ContentX, contentTop, layout.ContentW, available)
	State.ScrollTop = contentTop
	if State.Scroll[State.Tab] > State.ScrollMax then State.Scroll[State.Tab] = State.ScrollMax end
	if State.ScrollMax > 0 then
		local barX = layout.ContentRight + S(8, metrics.Scale)
		local thumbHeight = math_max(S(24, metrics.Scale), available * available / math_max(1, totalHeight))
		local thumbY = contentTop + (State.Scroll[State.Tab] / State.ScrollMax) * (available - thumbHeight)
		ScrollTrack.Position = Vector2_new(barX, contentTop); ScrollTrack.Size = Vector2_new(S(4, metrics.Scale), available)
		ScrollTrack.Color = State.Cur.element; ScrollTrack.Visible = true
		ScrollThumb.Position = Vector2_new(barX, thumbY); ScrollThumb.Size = Vector2_new(S(4, metrics.Scale), thumbHeight)
		ScrollThumb.Color = State.Cur.accent; ScrollThumb.Visible = true
		State.ScrollThumbRect = { barX, thumbY, S(4, metrics.Scale), thumbHeight }
		State.ScrollThumbHeight = thumbHeight
	else
		ScrollTrack.Visible = false; ScrollThumb.Visible = false; State.ScrollThumbRect = nil
	end
	if #tab.FixedItems > 0 then
		local gap = S(8, metrics.Scale)
		local width = math_max(S(80, metrics.Scale), (layout.ControlW - gap * (#tab.FixedItems - 1)) / #tab.FixedItems)
		local y = wy + metrics.Bottom - metrics.Row - S(8, metrics.Scale)
		for i = 1, #tab.FixedItems do
			local item = tab.FixedItems[i]
			local fixed = tab.FixedLayout
			fixed.ContentX, fixed.ContentW, fixed.ContentRight = layout.ContentX, layout.ContentW, layout.ContentRight
			fixed.LeftX, fixed.LeftW = layout.LeftX, layout.LeftW
			fixed.ControlX, fixed.ControlW, fixed.Scale = layout.ControlX + (i - 1) * (width + gap), width, metrics.Scale
			item:Draw(fixed.LeftX, y, fixed)
		end
	end
end

local function RenderUI()
	HidePool()
	local metrics = GetMetrics()
	local move = State.WinX + (1 - State.OpenAnim) * (metrics.W + S(60, metrics.Scale))
	if State.OpenAnim > 0.01 then
		RenderCore(move, State.WinY, metrics)
		local tab = State.Tabs[State.Tab]
		if tab then RenderTab(tab, move, State.WinY, metrics) end
	end
	State.LayoutDirty = false
	State.Dirty = false
end


local function HandleMouseInteraction(pressed, released)
	local metrics = GetMetrics()
	local move = State.WinX + (1 - State.OpenAnim) * (metrics.W + S(60, metrics.Scale))
	local tab = State.Tabs[State.Tab]
	if State.ActiveSlider then
		if State.Down then State.ActiveSlider:UpdateDrag(State.MX) else State.ActiveSlider:Released() end
	end
	if State.ActivePress and not State.Down then State.ActivePress:Released(State.MX, State.MY) end
	if not State.Open or State.OpenAnim < 0.9 then return end
	if pressed and State.TextInput and not PointInRect(State.MX, State.MY, State.TextInput.HitRect) then State.TextInput = nil end
	if State.DDOpen and pressed then
		if PointInRect(State.MX, State.MY, State.DDOpen.ListRect) then State.DDOpen:PickOption(State.MY)
		elseif not PointInRect(State.MX, State.MY, State.DDOpen.BoxRect) then State.DDOpen:Close() end
	end
	if pressed and State.ScrollMax > 0 and State.ScrollThumbRect and PointInRect(State.MX, State.MY, State.ScrollThumbRect) then
		State.ScrollDrag = true; State.ScrollOffset = State.MY - State.ScrollThumbRect[2]; return
	end
	if pressed then
		for i = 1, #State.Tabs do
			local y = State.WinY + metrics.Topbar + S(6, metrics.Scale) + (i - 1) * S(32, metrics.Scale)
			if PointInRect(State.MX, State.MY, { move, y, metrics.Sidebar, S(32, metrics.Scale) }) then
				if State.Tab ~= i and State.DDOpen then State.DDOpen:Close() end
				State.Tab = i; MarkDirty(true); return
			end
		end
	end
	if tab then
		for i = 1, #tab.Items do
			local item = tab.Items[i]
			local hit = item.HitRect or item.Rect
			item.Hover = item.Interactive and hit and PointInRect(State.MX, State.MY, hit) or false
			if pressed and item.Hover then
				if type_(item.Pressed) == "function" then item:Pressed(State.MX, State.MY) end
				if type_(item.Click) == "function" then item:Click(State.MX, State.MY) end
			end
			if released and item.Rect and type_(item.Released) == "function" then item:Released(State.MX, State.MY) end
		end
	end
	if pressed and not State.Dragging then
		local controlPress = false
		if tab then
			for i = 1, #tab.Items do
				if PointInRect(State.MX, State.MY, tab.Items[i].HitRect) then controlPress = true break end
			end
		end
		local inSidebar = State.MX >= move and State.MX <= move + metrics.Sidebar and State.MY >= State.WinY + metrics.Topbar and State.MY <= State.WinY + metrics.H
		local inHeader  = State.MX >= move and State.MX <= move + metrics.W and State.MY >= State.WinY and State.MY <= State.WinY + metrics.Topbar
		if inHeader and not controlPress and not inSidebar then
			State.Dragging = true
			State.DragStart = Vector2_new(State.MX, State.MY)
			State.StartPos  = Vector2_new(State.WinX, State.WinY)
		end
	end
end


local function OnRender(dt)
	if State.Unloaded then return end
	
	
	if type_(dt) ~= "number" or dt ~= dt or dt < 0 then dt = 1 / 60 end
	
	if State.Rainbow then
		State.RainbowHue = (State.RainbowHue or 0) + dt * 0.35
		if State.RainbowHue >= 1 then State.RainbowHue = State.RainbowHue - 1 end
		State.Cur.accent = HSVtoRGB(State.RainbowHue, 1, 1)
		State.Cur.accent2 = Mix(State.Cur.accent, white, 0.18)
		MarkDirty()
	end
	
	
	
	if type_(setrobloxinput) == "function" then
		local shouldBlock = State.Open and State.OpenAnim > 0.9 and State.BlockInput
		if shouldBlock and not State.InputBlocked then
			pcall_(setrobloxinput, false)
			State.InputBlocked = true
		elseif not shouldBlock and State.InputBlocked then
			pcall_(setrobloxinput, true)
			State.InputBlocked = false
		end
	end
	local mx, my = GetMousePosition()
	local moved = mx ~= State.MX or my ~= State.MY
	State.MX, State.MY = mx, my
	State.PrevDown, State.Down = State.Down, IsMouseDown(1)
	local pressed = (State.Down and not State.PrevDown) or State.MousePressPending
	State.MousePressPending = false
	local released = not State.Down and State.PrevDown
	PollWheelScroll()
	if State.Bind then
		for i = 1, #KeyList do
			local code = KeyList[i]
			if not KeyConsumedRecently(code) and KeyRising(code) then
				State.Bind:SetValue(code)
				State.Bind = nil
				MarkDirty()
				break
			end
		end
	elseif State.TextInput then
		for i = 1, #KeyList do
			local code = KeyList[i]
			if not KeyConsumedRecently(code) and KeyRising(code) then
				if ProcessTextCode(code) then break end
			end
		end
	elseif not KeyConsumedRecently(State.MenuKey) and KeyRising(State.MenuKey) then
		State.Open = not State.Open
		MarkDirty(true)
	end
	if moved or pressed or released then MarkDirty() end
	if State.Dragging then
		if State.Down then
			local delta = Vector2_new(State.MX, State.MY) - State.DragStart
			State.WinX = Clamp(State.StartPos.X + delta.X, -(State.WindowW - S(60, State.Scale)), ViewportW - S(60, State.Scale))
			State.WinY = Clamp(State.StartPos.Y + delta.Y, 0, ViewportH - S(40, State.Scale))
			MarkDirty(true)
		else
			State.Dragging = false; MarkDirty(true)
		end
	end
	if State.ScrollDrag then
		if State.Down and State.ScrollBounds then
			local trackLen = math_max(1, State.ScrollBounds[4] - State.ScrollThumbHeight)
			local proportion = Clamp((State.MY - State.ScrollOffset - State.ScrollTop) / trackLen, 0, 1)
			State.Scroll[State.Tab] = Clamp(proportion * State.ScrollMax, 0, State.ScrollMax)
			MarkDirty(true)
		else
			State.ScrollDrag = false
		end
	end
	State.OpenAnim = Lerp(State.OpenAnim, State.Open and 1 or 0, Clamp(dt * 12, 0, 1))
	if math_abs(State.OpenAnim - (State.Open and 1 or 0)) > 0.01 then MarkDirty(true) end
	State.FpsTime = State.FpsTime + dt; State.Frames = State.Frames + 1
	if State.FpsTime >= 0.5 then
		State.FPS = math_floor(State.Frames / State.FpsTime + 0.5)
		State.Frames, State.FpsTime = 0, 0; MarkDirty()
	end
	if State.Bind and KeyRising(27) then State.Bind = nil; MarkDirty() end
	if State.Dirty then RenderUI() end
	HandleMouseInteraction(pressed, released)
	if #Notifications > 0 then RenderNotifications(dt, GetMetrics()) end
end

local function BeginRenderLoop()
	local signal = SafeRead(RunService, "RenderStepped")
	if signal then
		local ok, connection = pcall_(function() return signal:Connect(OnRender) end)
		if ok then AddConnection(connection) return end
	end
	local loopState = { Active = true }
	AddConnection({ Disconnect = function() loopState.Active = false end })
	task.spawn(function()
		while loopState.Active do
			pcall_(OnRender, 1 / 60)
			task.wait(1 / 60)
		end
	end)
end


function Library.Unload()
	if State.Unloaded then return end
	State.Unloaded = true
	
	if State.InputBlocked and type_(setrobloxinput) == "function" then
		pcall_(setrobloxinput, true)
	end
	for i = #Connections, 1, -1 do CloseConnection(Connections[i]); Connections[i] = nil end
	for i = 1, #Pool do
		local object = Pool[i]
		if object and type_(object.Remove) == "function" then pcall_(function() object:Remove() end) end
	end
	_G.VANTA_UI = nil
end


EnsureConfigFolder()
Library.LoadSavedThemes()
State.WinX = math_floor((ViewportW - BASE_W) / 2)
State.WinY = math_floor((ViewportH - BASE_H) / 2)
BuildTabs()
HookSettings()
-- Restore the last session: active theme + config. Runs after BuildTabs so
-- ByKey controls exist for LoadConfig to apply values to.
LoadSessionState()
StartAvatarLoad()

local ImportRun = true
task.spawn(function()
	while ImportRun do
		local config = _G.VANTA_CFG
		if type_(config) == "string" and config ~= State.ImportLast then
			State.ImportLast = config; _G.VANTA_CFG = nil
			task.spawn(function() ApplyConfigString(config) end)
		end
		local query = _G.VANTA_QUERY or _G.MATCHA_QUERY
		if IsGameQuery(query) then
			_G.VANTA_QUERY, _G.MATCHA_QUERY = nil, nil
			local response = Library.HandleDiagnosticQuery(query)
			if response then print(response); Library.Notify("MATCHA", response, "info") end
		end
		task.wait(1.0)
	end
end)

_G.VANTA_UI = Library
Library.Tabs = State.Tabs
SetupInput()
BeginRenderLoop()
task.spawn(function()
	task.wait(1)
	Library.Notify("VANTA", "v" .. Library.Version .. " ready", "success")
end)

return Library

