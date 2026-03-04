-- NovaUI - Modern UI Library
local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

local CoreGui = cloneref(game:GetService("CoreGui"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TextService = cloneref(game:GetService("TextService"))
local TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function() return shared end
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function() return CoreGui end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

-- Modern Color Scheme
local Scheme = {
    Background = Color3.fromRGB(18, 18, 20),
    Surface = Color3.fromRGB(28, 28, 32),
    SurfaceLight = Color3.fromRGB(38, 38, 42),
    Primary = Color3.fromRGB(88, 101, 242),
    PrimaryLight = Color3.fromRGB(121, 134, 255),
    PrimaryDark = Color3.fromRGB(68, 81, 222),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 170),
    TextMuted = Color3.fromRGB(120, 120, 130),
    Border = Color3.fromRGB(48, 48, 54),
    BorderLight = Color3.fromRGB(58, 58, 64),
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 170, 80),
    Danger = Color3.fromRGB(255, 80, 80),
    Glow = Color3.fromRGB(88, 101, 242),
}

local Library = {
    LocalPlayer = LocalPlayer,
    ScreenGui = nil,
    
    Toggled = false,
    Unloaded = false,
    
    ActiveTab = nil,
    Tabs = {},
    Elements = {},
    
    TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    
    Scheme = Scheme,
    Font = Font.fromEnum(Enum.Font.Gotham),
    CornerRadius = 12,
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
        elseif prop == "TextColor3" and value == "Text" then
            obj[prop] = Scheme.Text
        elseif prop == "TextColor3" and value == "TextSecondary" then
            obj[prop] = Scheme.TextSecondary
        elseif prop == "BackgroundColor3" and value == "Surface" then
            obj[prop] = Scheme.Surface
        elseif prop == "BackgroundColor3" and value == "Primary" then
            obj[prop] = Scheme.Primary
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

-- Main Window Creation
function Library:CreateWindow(config)
    config = config or {}
    
    local title = config.Title or "NOVA"
    local size = config.Size or UDim2.fromOffset(900, 600)
    local position = config.Position or UDim2.new(0.5, -450, 0.5, -300)
    local accentColor = config.AccentColor or Scheme.Primary
    
    -- Update scheme with custom accent
    if accentColor then
        Scheme.Primary = accentColor
        Scheme.PrimaryLight = Color3.new(
            math.min(accentColor.R + 0.15, 1),
            math.min(accentColor.G + 0.15, 1),
            math.min(accentColor.B + 0.15, 1)
        )
        Scheme.PrimaryDark = Color3.new(
            math.max(accentColor.R - 0.15, 0),
            math.max(accentColor.G - 0.15, 0),
            math.max(accentColor.B - 0.15, 0)
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
    
    -- Main window
    local mainFrame = Create("Frame", {
        Name = "MainWindow",
        Size = size,
        Position = position,
        BackgroundColor3 = "Surface",
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    
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
    
    -- Header
    local header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Scheme.SurfaceLight,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius),
        Parent = header,
    })
    
    -- Title
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.fromOffset(20, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = "Text",
        TextSize = 22,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })
    
    -- Close button
    local closeBtn = Create("TextButton", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -50, 0.5, -20),
        BackgroundColor3 = "Surface",
        BackgroundTransparency = 0.5,
        Text = "✕",
        TextColor3 = "TextSecondary",
        TextSize = 20,
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
        AutoButtonColor = false,
        Parent = header,
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = closeBtn,
    })
    
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, Library.TweenInfo, {
            BackgroundColor3 = Scheme.Danger,
            BackgroundTransparency = 0.3,
            TextColor3 = Scheme.Text,
        }):Play()
    end)
    
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, Library.TweenInfo, {
            BackgroundColor3 = Scheme.Surface,
            BackgroundTransparency = 0.5,
            TextColor3 = Scheme.TextSecondary,
        }):Play()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        Library:Toggle()
    end)
    
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
    
    -- Content container (holds tabs)
    local contentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.fromOffset(0, 60),
        BackgroundTransparency = 1,
        Parent = mainFrame,
    })
    
    -- Tab buttons sidebar
    local tabSidebar = Create("Frame", {
        Name = "TabSidebar",
        Size = UDim2.new(0, 200, 1, 0),
        BackgroundColor3 = "Surface",
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = contentContainer,
    })
    
    Create("Frame", {
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Scheme.Border,
        BorderSizePixel = 0,
        Parent = tabSidebar,
    })
    
    local tabList = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = tabSidebar,
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = tabList,
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        Parent = tabList,
    })
    
    -- Main content area (two columns)
    local mainContent = Create("Frame", {
        Name = "MainContent",
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.fromOffset(200, 0),
        BackgroundTransparency = 1,
        Parent = contentContainer,
    })
    
    -- Two column layout
    local leftColumn = Create("ScrollingFrame", {
        Name = "LeftColumn",
        Size = UDim2.new(0.5, -8, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Scheme.Primary,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = mainContent,
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 12),
        Parent = leftColumn,
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        Parent = leftColumn,
    })
    
    local rightColumn = Create("ScrollingFrame", {
        Name = "RightColumn",
        Size = UDim2.new(0.5, -8, 1, 0),
        Position = UDim2.new(0.5, 2, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Scheme.Primary,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = mainContent,
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 12),
        Parent = rightColumn,
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        Parent = rightColumn,
    })
    
    -- Window object
    local window = {
        Tabs = {},
        LeftColumn = leftColumn,
        RightColumn = rightColumn,
    }
    
    -- Add Tab method
    function window:AddTab(name, icon)
        icon = icon or "●"
        
        local tabButton = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 45),
            BackgroundColor3 = "Surface",
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
            Position = UDim2.fromOffset(10, 0),
            BackgroundTransparency = 1,
            Text = icon,
            TextColor3 = "TextSecondary",
            TextSize = 18,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
            Parent = tabButton,
        })
        
        local nameLabel = Create("TextLabel", {
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.fromOffset(40, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = "TextSecondary",
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Parent = tabButton,
        })
        
        local tab = {
            Name = name,
            Button = tabButton,
            IconLabel = iconLabel,
            NameLabel = nameLabel,
            LeftGroups = {},
            RightGroups = {},
        }
        
        -- Tab switching
        tabButton.MouseButton1Click:Connect(function()
            if Library.ActiveTab then
                Library.ActiveTab.Button.BackgroundTransparency = 1
                TweenService:Create(Library.ActiveTab.IconLabel, Library.TweenInfo, {
                    TextColor3 = Scheme.TextSecondary
                }):Play()
                TweenService:Create(Library.ActiveTab.NameLabel, Library.TweenInfo, {
                    TextColor3 = Scheme.TextSecondary
                }):Play()
                
                -- Hide all groups
                for _, group in pairs(Library.ActiveTab.LeftGroups) do
                    if group.Container then
                        group.Container.Visible = false
                    end
                end
                for _, group in pairs(Library.ActiveTab.RightGroups) do
                    if group.Container then
                        group.Container.Visible = false
                    end
                end
            end
            
            Library.ActiveTab = tab
            tabButton.BackgroundTransparency = 0.9
            TweenService:Create(iconLabel, Library.TweenInfo, {TextColor3 = Scheme.Text}):Play()
            TweenService:Create(nameLabel, Library.TweenInfo, {TextColor3 = Scheme.Text}):Play()
            
            -- Show this tab's groups
            for _, group in pairs(tab.LeftGroups) do
                if group.Container then
                    group.Container.Visible = true
                end
            end
            for _, group in pairs(tab.RightGroups) do
                if group.Container then
                    group.Container.Visible = true
                end
            end
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
            end
        end)
        
        -- AddLeftGroupbox method
        function tab:AddLeftGroupbox(title)
            local groupbox = self:CreateGroupbox(title, leftColumn)
            table.insert(self.LeftGroups, groupbox)
            groupbox.Container.Visible = false
            return groupbox
        end
        
        -- AddRightGroupbox method
        function tab:AddRightGroupbox(title)
            local groupbox = self:CreateGroupbox(title, rightColumn)
            table.insert(self.RightGroups, groupbox)
            groupbox.Container.Visible = false
            return groupbox
        end
        
        -- CreateGroupbox helper
        function tab:CreateGroupbox(title, parent)
            local container = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = "Surface",
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = parent,
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 12),
                Parent = container,
            })
            
            Create("UIStroke", {
                Color = Scheme.Border,
                Thickness = 1,
                Transparency = 0.7,
                Parent = container,
            })
            
            -- Title bar
            if title then
                local titleBar = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 45),
                    BackgroundColor3 = "SurfaceLight",
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    Parent = container,
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
                    TextColor3 = "Text",
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
                    Parent = titleBar,
                })
            end
            
            -- Content area
            local content = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = container,
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
            
            local group = {
                Container = container,
                Content = content,
                Layout = layout,
            }
            
            -- AddButton method
            function group:AddButton(text, callback)
                local btn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundColor3 = "Surface",
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
                    TextColor3 = "Text",
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
                    TextColor3 = "TextSecondary",
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
                    TweenService:Create(arrow, Library.TweenInfo, {TextColor3 = "TextSecondary"}):Play()
                end)
                
                btn.MouseButton1Click:Connect(function()
                    SafeCallback(callback)
                    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Scheme.Primary}):Play()
                    task.wait(0.1)
                    TweenService:Create(btn, Library.TweenInfo, {BackgroundColor3 = Scheme.Surface}):Play()
                end)
                
                return btn
            end
            
            -- AddToggle method
            function group:AddToggle(text, default, callback)
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
                    TextColor3 = "Text",
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    Parent = toggle,
                })
                
                local switch = Create("TextButton", {
                    Size = UDim2.new(0, 50, 0, 24),
                    Position = UDim2.new(1, -50, 0.5, -12),
                    BackgroundColor3 = value and "Primary" or "Surface",
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
                    BackgroundColor3 = "Text",
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
            
            -- AddSlider method
            function group:AddSlider(text, min, max, default, callback)
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
                    TextColor3 = "Text",
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
                    TextColor3 = "Primary",
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
                    Parent = slider,
                })
                
                local bar = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 4),
                    Position = UDim2.new(0, 0, 1, -8),
                    BackgroundColor3 = "Surface",
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
                    BackgroundColor3 = "Primary",
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
                    BackgroundColor3 = "Text",
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
            
            -- AddLabel method
            function group:AddLabel(text, isSub)
                local label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, isSub and 20 or 25),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = isSub and "TextSecondary" or "Text",
                    TextSize = isSub and 13 or 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", 
                        isSub and Enum.FontWeight.Regular or Enum.FontWeight.Medium),
                    Parent = content,
                })
                
                return label
            end
            
            -- AddDivider method
            function group:AddDivider()
                local divider = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Scheme.Border,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Parent = content,
                })
                
                return divider
            end
            
            return group
        end
        
        table.insert(self.Tabs, tab)
        table.insert(Library.Tabs, tab)
        
        return tab
    end
    
    -- Select first tab by default
    task.wait()
    if #window.Tabs > 0 then
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
        Size = UDim2.new(0, 320, 0, 0),
        Position = UDim2.new(1, 20, 0, 20),
        BackgroundColor3 = "Surface",
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
        TextColor3 = "Text",
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
        TextColor3 = "TextSecondary",
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
    
    TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -340, 0, 20)
    }):Play()
    
    TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    }):Play()
    
    task.delay(duration, function()
        TweenService:Create(notification, TweenInfo.new(0.3), {
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
