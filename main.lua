-- تحميل مكتبة Rayfield بشكل آمن
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
end)

if not success then
    warn("فشل تحميل مكتبة Rayfield")
    return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Larry = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Larry")
local Animals = workspace:WaitForChild("Animals")
local Barn = workspace:WaitForChild("Buildings"):WaitForChild("AutoWoodenBarn")

-- الحصول على جميع البوابات الـ12
local gates = {}
for i = 1, 12 do
    local gate = Barn:WaitForChild("AnimalContainer"):WaitForChild("Spots"):WaitForChild(tostring(i)):WaitForChild("Gate")
    table.insert(gates, gate)
end

-- جدول لتخزين الأبقار التي تم إدخالها
local enteredCows = {}

-- دالة لتحلب الأبقار اللي إنتاجها 300 دفعة واحدة
local function milkCows()
    enteredCows = {}
    local cowsToEnter = {}

    -- فحص الأبقار المتوافقة
    for _, cow in pairs(Animals:GetChildren()) do
        if cow.Name == "Cow" then
            local config = cow:FindFirstChild("Configurations")
            if config and config:FindFirstChild("Production") and config.Production.Value == 300 then
                table.insert(cowsToEnter, cow)
            end
        end
    end

    -- التأكد من وجود أبقار كافية
    if #cowsToEnter == 0 then
        warn("لا توجد أبقار متاحة للإنتاج 300")
        return
    end

    -- إدخال الأبقار (بحد أقصى 12)
    local batch1 = math.min(12, #cowsToEnter)
    for i = 1, batch1 do
        local enterArgs = {
            [1] = { [1] = cowsToEnter[i] },
            [2] = Barn
        }
        Larry:WaitForChild("EVTHerdRequest"):FireServer(unpack(enterArgs))
        table.insert(enteredCows, cowsToEnter[i])
    end

    -- حلب الأبقار
    for _, cow in pairs(enteredCows) do
        local milkArgs = {
            [1] = "Milk",
            [2] = cow
        }
        Larry:WaitForChild("EVTCollectAnimalProduction"):FireServer(unpack(milkArgs))
    end

    wait(1)

    -- إخراج الأبقار
    for i = 1, #enteredCows do
        if gates[i] then
            local gateArgs = { [1] = gates[i] }
            Larry:WaitForChild("EVTOpenBarnGate"):FireServer(unpack(gateArgs))
        end
    end

    wait(2)

    -- معالجة الدفعة الثانية (إن وجدت)
    if #cowsToEnter > 12 then
        local enteredSecondBatch = {}
        local batch2 = math.min(20, #cowsToEnter)
        for i = 13, batch2 do
            local enterArgs = {
                [1] = { [1] = cowsToEnter[i] },
                [2] = Barn
            }
            Larry:WaitForChild("EVTHerdRequest"):FireServer(unpack(enterArgs))
            table.insert(enteredSecondBatch, cowsToEnter[i])
        end

        wait(2)

        -- حلب الدفعة الثانية
        for _, cow in pairs(enteredSecondBatch) do
            local milkArgs = {
                [1] = "Milk",
                [2] = cow
            }
            Larry:WaitForChild("EVTCollectAnimalProduction"):FireServer(unpack(milkArgs))
        end

        wait(1)

        -- إخراج الدفعة الثانية
        for i = 1, #enteredSecondBatch do
            if gates[i] then
                local gateArgs = { [1] = gates[i] }
                Larry:WaitForChild("EVTOpenBarnGate"):FireServer(unpack(gateArgs))
            end
        end
    end
end

-- متغيرات للتحكم في حالة السكربت
local isScriptRunning = false
local loopConnection

-- دالة لتشغيل أو إيقاف السكربت بناءً على الحالة
local function toggleScript()
    if isScriptRunning then
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
        isScriptRunning = false
    else
        loopConnection = game:GetService("RunService").Heartbeat:Connect(function()
            milkCows()
        end)
        isScriptRunning = true
    end
end

-- إنشاء واجهة المستخدم
local Window = Rayfield:CreateWindow({
    Name = "Control Panel",
    LoadingTitle = "Milk Farm Automation",
    LoadingSubtitle = "by Your Name",
    ConfigurationSaving = {
        Enabled = false,
    }
})

local MainTab = Window:CreateTab("Main", 4483362458) -- يمكنك تغيير الأيقونة

MainTab:CreateToggle({
    Name = "تشغيل/إيقاف السكربت",
    CurrentValue = false,
    Flag = "ScriptToggle",
    Callback = function(Value)
        toggleScript()
    end,
})ge:CreateButton({
    Name = "Toggle Script",
    Callback = function()
        toggleScript()
    end
})

