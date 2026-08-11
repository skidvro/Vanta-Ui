-- Vanta UI - Matcha (Stripped Library Version)
local Library = {}
Library.Name        = "VANTA"
Library.Version     = "1.0.0"
Library.ScrollSpeed = 32

local Vector2_new      = Vector2.new
local Color3_fromRGB   = Color3.fromRGB
local Color3_new       = Color3.new
local math_floor       = math.floor
local math_max         = math.max
local math_min         = math.min
local math_clamp       = math.clamp or function(v, a, b) return v < a and a or (v > b and b or v) end
local math_abs         = math.abs
local string_format    = string.format
local string_sub       = string.sub
local string_lower     = string.lower
local string_match     = string.match
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
	["Vanta Red"]     = { Background = Color3_fromRGB(15, 10, 10),  Accent = Color3_fromRGB(220, 20, 60)  },
	["Vanta Purple"]  = { Background = Color3_fromRGB(15, 10, 20),  Accent = Color3_fromRGB(160, 32, 240) },
	["Vanta Pink"]    = { Background = Color3_fromRGB(28, 10, 22),  Accent = Color3_fromRGB(255, 64, 196) },
}

Library.CustomTheme = {
	Background = Color3_fromRGB(15, 15, 15),
	Accent     = Color3_fromRGB(0, 180, 255),
	Text       = Color3_fromRGB(255, 255, 255),
	Borders    = Color3_fromRGB(35, 35, 35),
}

Library.CustomThemeName = "Custom"
Library.ActiveConfig = nil

local ThemeManager
local ApplyTheme
local ApplyCustomTheme
local ThemeNames
local SaveSessionState

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
	Scale = 1, WindowW = BASE_W, WindowH = BASE_H, WinX = 100, WinY = 100,
	Layout = nil, Metrics = nil, Notifs = true, Watermark = true, Rainbow = false, BlockInput = false,
	RainbowHue = 0, KeyConsumeCode = nil, KeyConsumeStamp = 0,
	FPS = 0, Frames = 0, FpsTime = 0, ThemeName = DEFAULT_THEME,
	Cur = CopyTheme(InitialTheme), Tgt = CopyTheme(InitialTheme),
	ImportLast = nil, Unloaded = false, KeyStates = {}, HeldKeys = {},
}

local ActiveTheme = State.Cur
Library.ActiveTheme = ActiveTheme
Library.Themes      = Themes

local function SetVisible(object, value)
	if object and object.Visible ~= value then object.Visible = value end
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
	WmBg        = NewSquare(160, 24, 15),
	WmBorder    = NewSquare(160, 24, 16, false),
	WmText      = NewText(11, Fonts.Bold, false, 17),
}

local NOTIF_W, NOTIF_H = 280, 52
local NOTIF_GAP, NOTIF_DISPLAY, NOTIF_FADE = 8, 5.0, 0.4
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

function Library.Notify(title, description, style)
	if not State.Notifs then return end
	if #Notifications >= 16 then Notifications[#Notifications] = nil end
	local record = {
		Age = 0, Life = NOTIF_DISPLAY + NOTIF_FADE,
		Title = tostring_(title or "VANTA"), Description = tostring_(description or ""),
		Style = tostring_(style or "info"), Gone = false,
	}
	for i = #Notifications + 1, 2, -1 do Notifications[i] = Notifications[i - 1] end
	Notifications[1] = record
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

function Library.Section(tab, title)
	local item = NewItem(tab, 28)
	item.Interactive = false
	item.Title = tostring_(title or "")
	item.Text  = NewText(11, Fonts.Bold, false, 4)
	item.Line  = NewLine(3)
	function item.Draw(self, x, y, layout)
		local s = layout.Scale
		ScaleText(self.Text, 11, s)
		self.Text.Text = FitText(SafeUpper(self.Title), layout.LeftW - S(8, s), self.Text.Size)
		self.Text.Position = Vector2_new(x, y + S(9, s))
		self.Text.Color = State.Cur.textDim
		self.Text.Visible = true
		local tw = TextWidth(self.Text, #self.Text.Text * self.Text.Size * 0.55)
		self.Line.From = Vector2_new(x + math_min(tw + S(12, s), layout.LeftW - S(4, s)), y + S(16, s))
		self.Line.To = Vector2_new(layout.ContentRight, y + S(16, s))
		self.Line.Color = State.Cur.border
		self.Line.Visible = true
		SetRect(self, "Rect", x, y, layout.LeftW, S(self.H, s))
	end
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
		ScaleText(self.ValueText, 11, s)
		self.ValueText.Text = FitText(string_format("%." .. self.Precision .. "f", self.Value) .. self.Suffix, bw - S(12, s), self.ValueText.Size)
		local valueWidth = TextWidth(self.ValueText, #self.ValueText.Text * self.ValueText.Size * 0.55)
		local valueRight = bx + bw - S(7, s)
		self.ValueText.Position = Vector2_new(valueRight - valueWidth, by + S(3.5, s))
		self.ValueText.Color = State.Cur.text
		self.ValueText.Visible = true
		local trackLeft = bx + S(2, s)
		local trackRight = valueRight - valueWidth - S(8, s)
		local trackWidth = math_max(S(1, s), trackRight - trackLeft)
		local pct = self.Max > self.Min and Clamp((self.Value - self.Min) / (self.Max - self.Min), 0, 1) or 0
		local thumbX = trackLeft + trackWidth * pct
		self.Track.Position = Vector2_new(trackLeft, by + S(8, s))
		self.Track.Size = Vector2_new(trackWidth, S(3, s))
		self.Track.Color = State.Cur.elementAlt
		self.Track.Visible = true
		self.Thumb.Position = Vector2_new(thumbX - S(1.5, s), by + S(2, s))
		self.Thumb.Size = Vector2_new(S(3, s), S(14, s))
		self.Thumb.Color = State.Cur.accent
		self.Thumb.Visible = true
		SetRect(self, "ControlRect", bx, by, bw, S(18, s))
		SetRect(self, "Rect", layout.ContentX, y, layout.ContentW, S(self.H, s))
		self.HitRect = self.Rect
		SetRect(self, "TrackRect", trackLeft, by, trackWidth, S(18, s))
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
	item.Open = false
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
	function item.SetValue(self, value, silent)
		self.Value = value
		if type_(self.Callback) == "function" and not silent then pcall_(self.Callback, value) end
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
		SetRect(self, "Rect", layout.ContentX, y, layout.ContentW, S(self.H, s))
	end
	return item
end

function Library.Button(tab, options)
	options = options or {}
	local item = NewItem(tab, BASE_ROW)
	item.Title = tostring_(options.title or "")
	item.Callback = options.callback
	item.Danger = options.danger == true
	item.Box = NewSquare(BASE_CONTROL_W, 18, 4)
	item.Text = NewText(11, Fonts.Bold, true, 5)
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
	tab.AddButton   = function(_, v) return Library.Button(tab, v) end
	State.Tabs[#State.Tabs + 1] = tab
	State.Scroll[#State.Scroll + 1] = 0
	return tab
end

-- Cleanup / Unload Method
function Library.Unload()
	State.Unloaded = true
	for i = 1, #Pool do
		if Pool[i] and type_(Pool[i].Remove) == "function" then
			pcall_(function() Pool[i]:Remove() end)
		end
	end
	for i = 1, #Connections do
		if Connections[i] and type_(Connections[i].Disconnect) == "function" then
			pcall_(function() Connections[i]:Disconnect() end)
		end
	end
	_G.VANTA_UI = nil
end

-- Key Input State Handler
local function KeyRising(code)
	if type_(iskeypressed) ~= "function" then return false end
	local ok, now = pcall_(iskeypressed, code)
	local previous = State.KeyStates[code] == true
	State.KeyStates[code] = ok and now == true
	return ok and now and not previous
end

-- Main Render/Update Loop
if RunService then
	local renderConn = RunService.RenderStepped:Connect(function(dt)
		if State.Unloaded then return end
		if KeyRising(State.MenuKey) then
			State.Open = not State.Open
		end
	end)
	Connections[#Connections + 1] = renderConn
end

_G.VANTA_UI = Library
return Library
