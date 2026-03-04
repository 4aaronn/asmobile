local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

local CoreGui = cloneref(game:GetService("CoreGui"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local SoundService = cloneref(game:GetService("SoundService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TextService = cloneref(game:GetService("TextService"))
local Teams = cloneref(game:GetService("Teams"))
local TweenService = cloneref(game:GetService("TweenService"))
local HttpService = cloneref(game:GetService("HttpService"))

local getgenv = getgenv or function() return shared end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function() return CoreGui end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

-- Modern Color Scheme
local Scheme = {
    -- Dark theme with accent colors
    Background = Color3.fromRGB(18, 18, 20),      -- Deep dark background
    Surface = Color3.fromRGB(28, 28, 32),         -- Slightly lighter surface
    Primary = Color3.fromRGB(88, 101, 242),       -- Modern purple/blue
    PrimaryLight = Color3.fromRGB(121, 134, 255), -- Lighter primary
    Text = Color3.fromRGB(255, 255, 255),         -- Pure white text
    TextSecondary = Color3.fromRGB(160, 160, 170), -- Muted text
    Border = Color3.fromRGB(48, 48, 54),          -- Subtle borders
    Success = Color3.fromRGB(80, 200, 120),       -- Green
    Warning = Color3.fromRGB(255, 170, 80),       -- Orange
    Danger = Color3.fromRGB(255, 80, 80),         -- Red
    Glow = Color3.fromRGB(88, 101, 242),          -- Glow effect color
}

local Library = {
    LocalPlayer = LocalPlayer,
    ScreenGui = nil,
    
    Toggled = false,
    Unloaded = false,
    
    ActiveTab = nil,
    Tabs = {},
    Elements = {},
    
    Notifications = {},
    Tooltips = {},
    
    TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    NotifyTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    
    Scheme = Scheme,
    Font = Font.fromEnum(Enum.Font.Gotham),
    CornerRadius = 10,
    DPIScale = 1,
}

-- Helper Functions
local function ApplyDPI(value)
    if typeof(value) == "number" then
        return value * Library.DPIScale
    elseif typeof(value) == "UDim2" then
        return UDim2.new(value.X.Scale, value.X.Offset * Library.DPIScale, 
                        value.Y.Scale, value.Y.Offset * Library.DPIScale)
    end
    return value
end

local function Create(className, properties)
    local obj = Instance.new(className)
    
    for prop, value in pairs(properties) do
        if typeof(value) == "function" then
            obj[prop] = value()
        elseif prop == "Position" or prop == "Size" or prop == "TextSize" then
            obj[prop] = ApplyDPI(value)
        else
            obj[prop] = value
        end
    end
    
    return obj
end

local function SafeCallback(callback, ...)
    if callback and typeof(callback) == "function" then
        local success, result = pcall(callback, ...)
        if not success then
            warn("Callback error:", result)
        end
        return result
    end
end

-- Modern Window Creation
function Library:CreateWindow(config)
    config = config or {}
    
    -- Window configuration
    local title = config.Title or "NOVA"
    local size = config.Size or UDim2.fromOffset(800, 500)
    local position = config.Position or UDim2.new(0.5, -400, 0.5, -250)
    local accentColor = config.AccentColor or Scheme.Primary
    
    -- Update scheme with custom accent
    if accentColor then
        Scheme.Primary = accentColor
        Scheme.PrimaryLight = Color3.new(
            math.min(accentColor.R + 0.15, 1),
            math.min(accentColor.G + 0.15, 1),
            math.min(accentColor.B + 0.15, 1)
        )
        Scheme.Glow = accentColor
    end
    
    -- Create main GUI
    local screenGui = Create("ScreenGui", {
        Name = "NovaUI",
        DisplayOrder = 999,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
    })
    
    pcall(protectgui, screenGui)
    screenGui.Parent = gethui()
    Library.ScreenGui = screenGui
    
    -- Main window frame with modern glass effect
    local mainFrame = Create("Frame", {
        Name = "MainWindow",
        Size = size,
        Position = position,
        BackgroundColor3 = Scheme.Background,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    
    -- Glass morphism effect
    Create("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius),
        Parent = mainFrame,
    })
    
    Create("UIStroke", {
        Color = Scheme.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = mainFrame,
    })
    
    -- Inner glow
    Create("Frame", {
        Name = "Glow",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Scheme.Glow,
        BackgroundTransparency = 0.95,
        BorderSizePixel = 0,
        ZIndex = -1,
        Parent = mainFrame,
    })
    
    -- Header
    local header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Scheme.Surface,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius),
        Parent = header,
    })
    
    Create("Frame", {
        Name = "HeaderLine",
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Scheme.Primary,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Parent = header,
    })
    
    -- Title
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.fromOffset(20, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Scheme.Text,
        TextSize = 18,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })
    
    -- Window controls
    local controls = Create("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -110, 0, 0),
        BackgroundTransparency = 1,
        Parent = header,
    })
    
    local function createControlButton(icon, callback)
        local btn = Create("TextButton", {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, 0, 0.5, -15),
            BackgroundColor3 = Scheme.Surface,
            BackgroundTransparency = 0.5,
            Text = "",
            AutoButtonColor = false,
            Parent = controls,
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = btn,
        })
        
        local lbl = Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = icon,
            TextColor3 = Scheme.TextSecondary,
            TextSize = 16,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
            Parent = btn,
        })
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, Library.TweenInfo, {BackgroundTransparency = 0.2}):Play()
            TweenService:Create(lbl, Library.TweenInfo, {TextColor3 = Scheme.Text}):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, Library.TweenInfo, {BackgroundTransparency = 0.5}):Play()
            TweenService:Create(lbl, Library.TweenInfo, {TextColor3 = Scheme.TextSecondary}):Play()
        end)
        
        btn.MouseButton1Click:Connect(callback)
        
        return btn
    end
    
    -- Reposition controls
    local closeBtn = createControlButton("✕", function()
        Library:Toggle()
    end)
    closeBtn.Position = UDim2.new(0, 0, 0.5, -15)
    
    local minimizeBtn = createControlButton("−", function()
        mainFrame.Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 50)
    end)
    minimizeBtn.Position = UDim2.new(0, 35, 0.5, -15)
    
    -- Sidebar
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 180, 1, -50),
        Position = UDim2.fromOffset(0, 50),
        BackgroundColor3 = Scheme.Surface,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    
    Create("Frame", {
        Name = "SidebarLine",
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Scheme.Primary,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    
    -- Tab container
    local tabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -190, 1, -50),
        Position = UDim2.fromOffset(190, 50),
        BackgroundTransparency = 1,
        Parent = mainFrame,
    })
    
    -- Tab buttons list
    local tabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -20),
        Position = UDim2.fromOffset(0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    
    local tabListLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = tabList,
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = tabList,
    })
    
    -- Make window draggable
    local dragging = false
    local dragStart, startPos
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Window object
    local window = {
        Tabs = {},
        Container = tabContainer,
    }
    
    -- Tab creation
    function window:AddTab(name, icon)
        icon = icon or "●"
        
        local tabButton = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Scheme.Surface,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = tabList,
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = tabButton,
        })
        
        local iconLabel = Create("TextLabel", {
            Size = UDim2.new(0, 30, 1, 0),
            Position = UDim2.fromOffset(8, 0),
            BackgroundTransparency = 1,
            Text = icon,
            TextColor3 = Scheme.TextSecondary,
            TextSize = 18,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
            Parent = tabButton,
        })
        
        local nameLabel = Create("TextLabel", {
            Size = UDim2.new(1, -46, 1, 0),
            Position = UDim2.fromOffset(38, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Scheme.TextSecondary,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Parent = tabButton,
        })
        
        local tabContent = Create("ScrollingFrame", {
            Name = name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Scheme.Primary,
            ScrollBarImageTransparency = 0.5,
            Visible = false,
            Parent = tabContainer,
        })
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 12),
            Parent = tabContent,
        })
        
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
            PaddingTop = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 16),
            Parent = tabContent,
        })
        
        local tab = {
            Name = name,
            Button = tabButton,
            Container = tabContent,
            Elements = {},
        }
        
        -- Tab switching
        tabButton.MouseButton1Click:Connect(function()
            if Library.ActiveTab then
                Library.ActiveTab.Button.BackgroundTransparency = 1
                Library.ActiveTab.Container.Visible = false
                TweenService:Create(Library.ActiveTab.Button, Library.TweenInfo, {BackgroundTransparency = 1}):Play()
            end
            
            Library.ActiveTab = tab
            tabButton.BackgroundTransparency = 0.8
            tabContent.Visible = true
            
            TweenService:Create(tabButton, Library.TweenInfo, {BackgroundTransparency = 0.8}):Play()
            TweenService:Create(iconLabel, Library.TweenInfo, {TextColor3 = Scheme.Text}):Play()
            TweenService:Create(nameLabel, Library.TweenInfo, {TextColor3 = Scheme.Text}):Play()
        end)
        
        -- Hover effects
        tabButton.MouseEnter:Connect(function()
            if Library.ActiveTab ~= tab then
                TweenService:Create(tabButton, Library.TweenInfo, {BackgroundTransparency = 0.95}):Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if Library.ActiveTab ~= tab then
                TweenService:Create(tabButton, Library.TweenInfo, {BackgroundTransparency = 1}):Play()
                TweenService:Create(iconLabel, Library.TweenInfo, {TextColor3 = Scheme.TextSecondary}):Play()
                TweenService:Create(nameLabel, Library.TweenInfo, {TextColor3 = Scheme.TextSecondary}):Play()
            end
        end)
        
        -- Section creation
        function tab:AddSection(title)
            local section = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Scheme.Surface,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = tab.Container,
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 12),
                Parent = section,
            })
            
            Create("UIStroke", {
                Color = Scheme.Border,
                Thickness = 1,
                Transparency = 0.7,
                Parent = section,
            })
            
            if title then
                local titleBar = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundColor3 = Scheme.Surface,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Parent = section,
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                    Parent = titleBar,
                })
                
                Create("Frame", {
                    Position = UDim2.new(0, 12, 1, -1),
                    Size = UDim2.new(1, -24, 0, 1),
                    BackgroundColor3 = Scheme.Primary,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Parent = titleBar,
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.fromOffset(12, 0),
                    BackgroundTransparency = 1,
                    Text = title,
                    TextColor3 = Scheme.Text,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
                    Parent = titleBar,
                })
            end
            
            local content = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = section,
            })
            
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 16),
                PaddingRight = UDim.new(0, 16),
                PaddingTop = UDim.new(0, title and 12 or 16),
                PaddingBottom = UDim.new(0, 16),
                Parent = content,
            })
            
            local layout = Create("UIListLayout", {
                Padding = UDim.new(0, 12),
                Parent = content,
            })
            
            local sectionObj = {
                Container = content,
                Layout = layout,
            }
            
            -- Element creation methods
            function sectionObj:AddButton(text, callback)
                local btn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundColor3 = Scheme.Surface,
                    BackgroundTransparency = 0.2,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = content,
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = btn,
                })
                
                Create("UIStroke", {
                    Color = Scheme.Border,
                    Thickness = 1,
                    Transparency = 0.7,
                    Parent = btn,
                })
                
                local label = Create("TextLabel", {
                    Size = UDim2.new(1, -32, 1, 0),
                    Position = UDim2.fromOffset(16, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Scheme.Text,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    Parent = btn,
                })
                
                local arrow = Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -36, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "→",
                    TextColor3 = Scheme.TextSecondary,
                    TextSize = 18,
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                    Parent = btn,
                })
                
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, Library.TweenInfo, {BackgroundTransparency = 0}):Play()
                    TweenService:Create(arrow, Library.TweenInfo, {TextColor3 = Scheme.Primary}):Play()
                end)
                
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, Library.TweenInfo, {BackgroundTransparency = 0.2}):Play()
                    TweenService:Create(arrow, Library.TweenInfo, {TextColor3 = Scheme.TextSecondary}):Play()
                end)
                
                btn.MouseButton1Click:Connect(function()
                    SafeCallback(callback)
                    
                    -- Click animation
                    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Scheme.Primary}):Play()
                    task.wait(0.1)
                    TweenService:Create(btn, Library.TweenInfo, {BackgroundColor3 = Scheme.Surface}):Play()
                end)
                
                return btn
            end
            
            function sectionObj:AddToggle(text, default, callback)
                local value = default or false
                
                local toggle = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundTransparency = 1,
                    Parent = content,
                })
                
                local label = Create("TextLabel", {
                    Size = UDim2.new(1, -70, 1, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Scheme.Text,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    Parent = toggle,
                })
                
                local switch = Create("TextButton", {
                    Size = UDim2.new(0, 50, 0, 24),
                    Position = UDim2.new(1, -50, 0.5, -12),
                    BackgroundColor3 = value and Scheme.Primary or Scheme.Surface,
                    BackgroundTransparency = value and 0.2 or 0.4,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = toggle,
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                    Parent = switch,
                })
                
                Create("UIStroke", {
                    Color = Scheme.Border,
                    Thickness = 1,
                    Transparency = 0.7,
                    Parent = switch,
                })
                
                local knob = Create("Frame", {
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(value and 1 or 0, value and -22 or 2, 0.5, -10),
                    BackgroundColor3 = Scheme.Text,
                    BorderSizePixel = 0,
                    Parent = switch,
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = knob,
                })
                
                local function setState(newValue)
                    value = newValue
                    TweenService:Create(switch, Library.TweenInfo, {
                        BackgroundColor3 = value and Scheme.Primary or Scheme.Surface,
                        BackgroundTransparency = value and 0.2 or 0.4,
                    }):Play()
                    TweenService:Create(knob, Library.TweenInfo, {
                        Position = UDim2.new(value and 1 or 0, value and -22 or 2, 0.5, -10)
                    }):Play()
                    SafeCallback(callback, value)
                end
                
                switch.MouseButton1Click:Connect(function()
                    setState(not value)
                end)
                
                return {
                    SetValue = setState,
                    GetValue = function() return value end,
                }
            end
            
            function sectionObj:AddSlider(text, min, max, default, callback)
                local value = default or min
                
                local slider = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = content,
                })
                
                local label = Create("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 20),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Scheme.Text,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    Parent = slider,
                })
                
                local valueLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -50, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    TextColor3 = Scheme.Primary,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
                    Parent = slider,
                })
                
                local bar = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 4),
                    Position = UDim2.new(0, 0, 1, -8),
                    BackgroundColor3 = Scheme.Surface,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Parent = slider,
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = bar,
                })
                
                local fill = Create("Frame", {
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Scheme.Primary,
                    BorderSizePixel = 0,
                    Parent = bar,
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = fill,
                })
                
                local knob = Create("Frame", {
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6),
                    BackgroundColor3 = Scheme.Text,
                    BorderSizePixel = 0,
                    Parent = bar,
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = knob,
                })
                
                local dragging = false
                
                knob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                knob.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pos = Mouse.X - bar.AbsolutePosition.X
                        local percent = math.clamp(pos / bar.AbsoluteSize.X, 0, 1)
                        value = min + (max - min) * percent
                        value = math.floor(value * 100) / 100
                        
                        fill.Size = UDim2.new(percent, 0, 1, 0)
                        knob.Position = UDim2.new(percent, -6, 0.5, -6)
                        valueLabel.Text = tostring(value)
                        
                        SafeCallback(callback, value)
                    end
                end)
                
                return {
                    SetValue = function(newValue)
                        value = math.clamp(newValue, min, max)
                        local percent = (value - min) / (max - min)
                        fill.Size = UDim2.new(percent, 0, 1, 0)
                        knob.Position = UDim2.new(percent, -6, 0.5, -6)
                        valueLabel.Text = tostring(value)
                        SafeCallback(callback, value)
                    end,
                    GetValue = function() return value end,
                }
            end
            
            function sectionObj:AddDropdown(text, options, default, callback)
                local selected = default or options[1]
                local open = false
                
                local dropdown = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundTransparency = 1,
                    Parent = content,
                })
                
                local label = Create("TextLabel", {
                    Size = UDim2.new(1, -100, 1, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Scheme.Text,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    Parent = dropdown,
                })
                
                local selectBtn = Create("TextButton", {
                    Size = UDim2.new(0, 90, 0, 30),
                    Position = UDim2.new(1, -90, 0.5, -15),
                    BackgroundColor3 = Scheme.Surface,
                    BackgroundTransparency = 0.2,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = dropdown,
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = selectBtn,
                })
                
                Create("UIStroke", {
                    Color = Scheme.Border,
                    Thickness = 1,
                    Transparency = 0.7,
                    Parent = selectBtn,
                })
                
                local selectedLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.fromOffset(10, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(selected),
                    TextColor3 = Scheme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    Parent = selectBtn,
                })
                
                local arrow = Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -25, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Scheme.TextSecondary,
                    TextSize = 12,
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
                    Parent = selectBtn,
                })
                
                local dropdownMenu = Create("ScrollingFrame", {
                    Size = UDim2.new(0, 150, 0, 120),
                    Position = UDim2.new(1, -150, 1, 5),
                    BackgroundColor3 = Scheme.Surface,
                    BackgroundTransparency = 0.1,
                    BorderSizePixel = 0,
                    Visible = false,
                    ScrollBarThickness = 4,
                    ScrollBarImageColor3 = Scheme.Primary,
                    CanvasSize = UDim2.new(0, 0, 0, #options * 30),
                    Parent = selectBtn,
                })
                
                Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = dropdownMenu,
                })
                
                Create("UIStroke", {
                    Color = Scheme.Border,
                    Thickness = 1,
                    Parent = dropdownMenu,
                })
                
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    Parent = dropdownMenu,
                })
                
                local menuLayout = Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = dropdownMenu,
                })
                
                for _, option in ipairs(options) do
                    local optionBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 25),
                        BackgroundColor3 = option == selected and Scheme.Primary or Scheme.Surface,
                        BackgroundTransparency = option == selected and 0.2 or 1,
                        Text = "",
                        AutoButtonColor = false,
                        Parent = dropdownMenu,
                    })
                    
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                        Parent = optionBtn,
                    })
                    
                    local optionLabel = Create("TextLabel", {
                        Size = UDim2.new(1, -16, 1, 0),
                        Position = UDim2.fromOffset(8, 0),
                        BackgroundTransparency = 1,
                        Text = tostring(option),
                        TextColor3 = option == selected and Scheme.Text or Scheme.TextSecondary,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                        Parent = optionBtn,
                    })
                    
                    optionBtn.MouseEnter:Connect(function()
                        if option ~= selected then
                            TweenService:Create(optionBtn, Library.TweenInfo, {BackgroundTransparency = 0.95}):Play()
                        end
                    end)
                    
                    optionBtn.MouseLeave:Connect(function()
                        if option ~= selected then
                            TweenService:Create(optionBtn, Library.TweenInfo, {BackgroundTransparency = 1}):Play()
                        end
                    end)
                    
                    optionBtn.MouseButton1Click:Connect(function()
                        selected = option
                        selectedLabel.Text = tostring(selected)
                        open = false
                        dropdownMenu.Visible = false
                        arrow.Rotation = 0
                        
                        SafeCallback(callback, selected)
                    end)
                end
                
                selectBtn.MouseButton1Click:Connect(function()
                    open = not open
                    dropdownMenu.Visible = open
                    arrow.Rotation = open and 180 or 0
                end)
                
                return {
                    SetValue = function(newValue)
                        if table.find(options, newValue) then
                            selected = newValue
                            selectedLabel.Text = tostring(selected)
                            SafeCallback(callback, selected)
                        end
                    end,
                    GetValue = function() return selected end,
                }
            end
            
            return sectionObj
        end
        
        table.insert(self.Tabs, tab)
        table.insert(Library.Tabs, tab)
        
        return tab
    end
    
    -- Select first tab by default
    if #window.Tabs > 0 then
        task.wait()
        window.Tabs[1].Button.MouseButton1Click:Fire()
    end
    
    return window
end

-- Notification system
function Library:Notify(config)
    config = config or {}
    
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 3
    local type = config.Type or "info"
    
    local colors = {
        info = Scheme.Primary,
        success = Scheme.Success,
        warning = Scheme.Warning,
        error = Scheme.Danger,
    }
    
    local notification = Create("Frame", {
        Size = UDim2.new(0, 300, 0, 0),
        Position = UDim2.new(1, 20, 0, 20),
        BackgroundColor3 = Scheme.Surface,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = Library.ScreenGui,
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = notification,
    })
    
    Create("UIStroke", {
        Color = colors[type] or Scheme.Primary,
        Thickness = 1,
        Transparency = 0.5,
        Parent = notification,
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        Parent = notification,
    })
    
    local titleLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Scheme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        Parent = notification,
    })
    
    local messageLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.fromOffset(0, 20),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Scheme.TextSecondary,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.Y,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        Parent = notification,
    })
    
    local progress = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = colors[type] or Scheme.Primary,
        BorderSizePixel = 0,
        Parent = notification,
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = progress,
    })
    
    notification.Position = UDim2.new(1, 20, 0, 20)
    
    TweenService:Create(notification, Library.NotifyTweenInfo, {
        Position = UDim2.new(1, -310, 0, 20)
    }):Play()
    
    TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    }):Play()
    
    task.delay(duration, function()
        TweenService:Create(notification, Library.NotifyTweenInfo, {
            Position = UDim2.new(1, 20, 0, 20)
        }):Play()
        
        task.wait(0.3)
        notification:Destroy()
    end)
    
    return notification
end

-- Toggle function
function Library:Toggle()
    self.Toggled = not self.Toggled
    
    if self.ScreenGui then
        for _, v in ipairs(self.ScreenGui:GetChildren()) do
            if v.Name == "MainWindow" then
                v.Visible = self.Toggled
            end
        end
    end
end

-- Cleanup
function Library:Unload()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    self.Unloaded = true
end

getgenv().NovaUI = Library
return Library
