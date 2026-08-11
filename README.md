# Vanta UI — Matcha

> A lightweight, Drawing-API-powered Luau interface library for Roblox script development. Created by **@43xe** on Discord.

---

## 🌟 Overview

**Vanta UI (Matcha)** is a high-performance, sleek Roblox UI library built entirely using Roblox's `Drawing` API. Designed for responsiveness, smooth scaling, customizable themes, and robust persistence, Vanta UI offers a cheat-provider style aesthetic (inspired by Neverlose, Skeet, OneTap) while remaining minimal and memory-efficient.

---

## 🚀 Quick Start

```lua
-- Load Vanta UI Library
local Library = loadstring(game:HttpGet("YOUR_SCRIPT_URL_HERE"))()

-- Create Tabs
local MainTab    = Library.AddTab("Main")
local VisualsTab = Library.AddTab("Visuals")
local SettingsTab = Library.AddTab("Settings")

-- Add a Section & Controls to Main Tab
MainTab:AddSection("Combat Features")

MainTab:AddToggle({
    title = "Aimbot",
    default = true,
    key = "AimbotToggle",
    callback = function(state)
        print("Aimbot:", state)
    end
})

MainTab:AddSlider({
    title = "Smoothness",
    min = 1,
    max = 20,
    default = 5,
    step = 1,
    suffix = "x",
    key = "AimbotSmoothness",
    callback = function(val)
        print("Smoothness set to:", val)
    end
})

-- Send a Toast Notification
Library.Notify("VANTA UI", "Script loaded successfully!", "success")

```

---

## 📖 API Documentation

### 1. Main Library Properties & Methods

| Method / Property | Type | Description |
| --- | --- | --- |
| `Library.Name` | `string` | Returns `"VANTA"`. |
| `Library.Version` | `string` | Returns `"1.0.0"`. |
| `Library.ScrollSpeed` | `number` | Controls menu scroll speed (Default: `32`). |
| `Library.AddTab(title)` | `function` | Creates a new tab and returns the Tab object. |
| `Library.Notify(title, description, style)` | `function` | Triggers a toast notification. Styles: `"info"`, `"success"`, `"warn"`, `"error"`. |
| `Library.SetTheme(themeName)` | `function` | Sets the menu theme (e.g. `"Neverlose"`, `"Skeet"`). |
| `Library.GetValue(key)` | `function` | Fetches the value of a registered control by its key name. |
| `Library.SetValue(key, value, silent)` | `function` | Programmatically updates a control value. |

---

### 2. Tab Components

Once a tab is created (`local tab = Library.AddTab("Tab Name")`), you can populate it with components:

#### 🔹 Section & Labels

```lua
tab:AddSection("Section Title")
tab:AddLabel("Informational Label")

```

#### 🔹 Toggle

```lua
tab:AddToggle({
    title = "Enable Feature",
    default = false,
    key = "FeatureKey", -- Optional key used for config saving/retrieval
    notify = true,      -- Whether to trigger a notification on toggle
    callback = function(enabled)
        print("Toggle value:", enabled)
    end
})

```

#### 🔹 Slider

```lua
tab:AddSlider({
    title = "FOV Radius",
    min = 10,
    max = 500,
    default = 90,
    step = 5,
    precision = 0,      -- Decimal places to display
    suffix = "px",      -- Suffix appended to value text
    key = "FovRadius",
    callback = function(value)
        print("Slider value:", value)
    end
})

```

#### 🔹 Dropdown

```lua
tab:AddDropdown({
    title = "Target Priority",
    options = { "Distance", "Health", "FOV" },
    default = "Distance",
    key = "TargetPriority",
    callback = function(selected)
        print("Selected option:", selected)
    end
})

```

#### 🔹 Keybind

```lua
tab:AddKeybind({
    title = "Menu Keybind",
    default = 161, -- KeyCode number (e.g., 161 = Right Shift)
    key = "MenuToggleKey",
    callback = function(keyCode)
        print("Keybind changed to:", keyCode)
    end
})

```

#### 🔹 Textbox

```lua
tab:AddTextbox({
    title = "Target Name",
    placeholder = "Enter username...",
    default = "",
    maxLength = 32,
    key = "TargetUsername",
    callback = function(text)
        print("Input text:", text)
    end
})

```

#### 🔹 Button

```lua
tab:AddButton({
    title = "Reset Settings",
    danger = true,  -- Renders button with red warning theme
    bottom = false, -- Pin to bottom of tab list
    callback = function()
        print("Button clicked!")
    end
})

```

#### 🔹 Panel

```lua
tab:AddPanel({
    title = "User Details",
    height = 56,
    leftText = "Status: Active",
    rightText = "Rank: VIP",
    onLeft = function() print("Clicked left panel") end,
    onRight = function() print("Clicked right panel") end
})

```

#### 🔹 Color Picker

```lua
tab:AddColorPicker({
    title = "Accent Color",
    target = "Accent", -- Target custom theme property: "Background", "Accent", "Text", or "Borders"
    key = "CustomAccentColor"
})

```

---

### 3. Theme Manager & Custom Themes

Vanta UI comes with a complete theme engine. Colors can be overridden programmatically or through the built-in preset theme names.

#### Available Preset Themes:

* `"Neverlose"` *(Default)*
* `"Skeet"`
* `"OneTap"`
* `"Vanta Red"`
* `"Vanta Purple"`
* `"Vanta Pink"`

#### Managing Themes Programmatically:

```lua
-- Apply a preset theme
Library.SetTheme("Skeet")

-- Modify Custom Theme elements directly
Library.CustomTheme.Background = Color3.fromRGB(15, 15, 15)
Library.CustomTheme.Accent     = Color3.fromRGB(0, 180, 255)
Library.CustomTheme.Text       = Color3.fromRGB(255, 255, 255)
Library.CustomTheme.Borders    = Color3.fromRGB(35, 35, 35)

-- Apply modified custom colors
Library.ApplyCustomTheme()

```
---

## 🎨 Example Full Script Structure

```lua
local Library = loadstring(game:HttpGet("YOUR_SCRIPT_URL_HERE"))()

-- 1. Create Tabs
local CombatTab   = Library.AddTab("Combat")
local VisualsTab  = Library.AddTab("Visuals")
local SettingsTab = Library.AddTab("Settings")

-- 2. Combat Setup
CombatTab:AddSection("Aimbot")
CombatTab:AddToggle({ title = "Enabled", key = "AimbotEnabled" })
CombatTab:AddSlider({ title = "FOV", min = 30, max = 300, default = 100, key = "AimbotFOV" })
CombatTab:AddDropdown({ title = "Hitbox", options = { "Head", "Torso", "HumanoidRootPart" }, key = "AimbotHitbox" })

-- 3. Settings & Config Setup
SettingsTab:AddSection("Theme & Color Options")
SettingsTab:AddColorPicker({ title = "Accent Color", target = "Accent" })
SettingsTab:AddColorPicker({ title = "Background Color", target = "Background" })

SettingsTab:AddSection("Configurations")
SettingsTab:AddButton({
    title = "Save Config",
    callback = function()
        Library.SaveConfig("my_config")
    end
})
SettingsTab:AddButton({
    title = "Load Config",
    callback = function()
        Library.LoadConfig("my_config")
    end
})

-- 4. Notify
Library.Notify("VANTA", "UI Initialization Complete", "success")

```

---

## 👤 Credits

* **Developer**: `@43xe` on Discord
* **Library Name**: Vanta UI — Matcha
* **Version**: `1.0.0`
