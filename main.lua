loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Larry = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Larry")
local Animals = workspace:WaitForChild("Animals")
local Barn = workspace:WaitForChild("Buildings"):WaitForChild("AutoWoodenBarn")

-- الحصول على جميع البوابات الـ12
local gates = {}
for i = 1, 12 do
    table.insert(gates, Barn:WaitForChild("AnimalContainer"):WaitForChild("Spots"):WaitForChild(tostring(i)):WaitForChild("Gate"))
end

-- جدول لتخزين الأبقار التي تم إدخالها
local enteredCows = {}

-- دالة لتحلب الأبقار اللي إنتاجها 300 دفعة واحدة
local function milkCows()
    -- نقوم بمسح الجدول في كل دورة جديدة
    enteredCows = {}

    local cowsToEnter = {} -- قائمة الأبقار التي سيتم إدخالها

    -- فحص الأبقار المتوافقة
    for _, cow in pairs(Animals:GetChildren()) do
        if cow.Name == "Cow" then
            local config = cow:FindFirstChild("Configurations")
            if config and config:FindFirstChild("Production") and config.Production.Value == 300 then
                -- إضافة الأبقار التي تستوفي الشرط
                table.insert(cowsToEnter, cow)
            end
        end
    end

    -- إدخال الـ12 بقرة دفعة واحدة
    for i = 1, 12 do
        if cowsToEnter[i] then
            local enterArgs = {
                [1] = {
                    [1] = cowsToEnter[i]
                },
                [2] = Barn
            }
            Larry:WaitForChild("EVTHerdRequest"):FireServer(unpack(enterArgs))
            table.insert(enteredCows, cowsToEnter[i])  -- إضافتها للجدول بعد الدخول
        end
    end

    -- حلب الأبقار كلها دفعة واحدة
    for _, cow in pairs(enteredCows) do
        local milkArgs = {
            [1] = "Milk",
            [2] = cow
        }
        Larry:WaitForChild("EVTCollectAnimalProduction"):FireServer(unpack(milkArgs))
    end

    wait(1) -- الانتظار قليلاً بعد الحلب

    -- الآن نفتح البوابات الـ12 لإخراج الأبقار
    for i = 1, 12 do
        local gateArgs = {
            [1] = gates[i]  -- فتح البوابة المقابلة لكل بقرة
        }
        Larry:WaitForChild("EVTOpenBarnGate"):FireServer(unpack(gateArgs))
    end

    wait(2) -- الانتظار قليلاً بعد إخراج الأبقار

    -- الآن ندخل الـ8 الأبقار المتبقية
    local enteredSecondBatch = {}
    for i = 13, 20 do
        if cowsToEnter[i] then
            local enterArgs = {
                [1] = {
                    [1] = cowsToEnter[i]
                },
                [2] = Barn
            }
            Larry:WaitForChild("EVTHerdRequest"):FireServer(unpack(enterArgs))
            table.insert(enteredSecondBatch, cowsToEnter[i])  -- إضافتها للجدول بعد الدخول
        end
    end

    wait(2) -- الانتظار قبل بدء حلب الأبقار الـ8 المتبقية

    -- حلب الأبقار الـ8 المتبقية دفعة واحدة
    for _, cow in pairs(enteredSecondBatch) do
        local milkArgs = {
            [1] = "Milk",
            [2] = cow
        }
        Larry:WaitForChild("EVTCollectAnimalProduction"):FireServer(unpack(milkArgs))
    end

    wait(1) -- الانتظار قليلاً بعد الحلب

    -- الآن نفتح البوابات الـ8 لإخراج الأبقار المتبقية
    for i = 1, #enteredSecondBatch do
        local gateArgs = {
            [1] = gates[i]  -- فتح البوابة المقابلة لكل بقرة
        }
        Larry:WaitForChild("EVTOpenBarnGate"):FireServer(unpack(gateArgs))
    end
end

-- متغيرات للتحكم في حالة السكربت
local isScriptRunning = false
local loopConnection

-- دالة لتشغيل أو إيقاف السكربت بناءً على الحالة
local function toggleScript()
    if isScriptRunning then
        -- إيقاف السكربت
        if loopConnection then
            loopConnection:Disconnect()
        end
        isScriptRunning = false
    else
        -- تشغيل السكربت
        loopConnection = game:GetService("RunService").Heartbeat:Connect(function()
            milkCows()
        end)
        isScriptRunning = true
    end
end

-- إضافة واجهة مستخدم مع زر لتشغيل وإيقاف السكربت
Rayfield:CreateWindow({
    Title = "Control Panel",
    Center = true,
    AutoSize = true,
    Icon = "rbxassetid://123456789"  -- يمكنك تغيير الآيكون هنا إذا أردت
})

local page = Rayfield:CreatePage({
    Name = "Milk Cows Control"
})

page:CreateButton({
    Name = "Toggle Script",
    Callback = function()
        toggleScript()
    end
})

