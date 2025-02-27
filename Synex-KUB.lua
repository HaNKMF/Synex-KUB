local httpService = game:GetService("HttpService")

local SaveManager = {}
SaveManager.Folder = "FluentSettings"
SaveManager.Ignore = {}
SaveManager.Options = {}
SaveManager.Parser = {}
SaveManager.Assets = {}  -- รองรับ Asset เช่น GUI หรือ Model

-- ฟังก์ชันสำหรับเพิ่มประเภท Object ใหม่ในการเซฟ
function SaveManager:RegisterParser(Type, SaveFunc, LoadFunc)
    self.Parser[Type] = { Save = SaveFunc, Load = LoadFunc }
end

-- ตั้งค่าที่ต้องการ Ignore
function SaveManager:SetIgnoreIndexes(list)
    for _, key in pairs(list) do
        self.Ignore[key] = true
    end
end

-- ตั้งค่าโฟลเดอร์
function SaveManager:SetFolder(folder)
    self.Folder = folder
    self:BuildFolderTree()
end

-- สร้างโฟลเดอร์ตามโครงสร้าง
function SaveManager:BuildFolderTree()
    local paths = { self.Folder, self.Folder .. "/settings", self.Folder .. "/assets" }
    for _, path in ipairs(paths) do
        if not isfolder(path) then makefolder(path) end
    end
end

-- ฟังก์ชันบันทึกค่า
function SaveManager:Save(name)
    if not name or name == "" then return false, "Invalid file name" end
    local filePath = string.format("%s/settings/%s.json", self.Folder, name)
    local data = { objects = {} }
    
    for idx, option in pairs(self.Options) do
        if self.Ignore[idx] or not self.Parser[option.Type] then continue end
        table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
    end
    
    local success, encoded = pcall(httpService.JSONEncode, httpService, data)
    if not success then return false, "Encoding error" end
    writefile(filePath, encoded)
    return true
end

-- ฟังก์ชันโหลดค่า
function SaveManager:Load(name)
    if not name or name == "" then return false, "Invalid file name" end
    local filePath = string.format("%s/settings/%s.json", self.Folder, name)
    if not isfile(filePath) then return false, "File not found" end
    
    local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(filePath))
    if not success then return false, "Decoding error" end
    
    for _, obj in ipairs(decoded.objects) do
        if self.Parser[obj.type] then
            task.spawn(function() self.Parser[obj.type].Load(obj.idx, obj) end)
        end
    end
    return true
end

-- ฟังก์ชันจัดการ Asset
function SaveManager:SaveAsset(name, data)
    local filePath = string.format("%s/assets/%s.json", self.Folder, name)
    writefile(filePath, httpService:JSONEncode(data))
end

function SaveManager:LoadAsset(name)
    local filePath = string.format("%s/assets/%s.json", self.Folder, name)
    if isfile(filePath) then
        local success, data = pcall(httpService.JSONDecode, httpService, readfile(filePath))
        if success then return data end
    end
    return nil
end

-- ฟังก์ชันรีเฟรชรายการ Config
function SaveManager:RefreshConfigList()
    local files = listfiles(self.Folder .. "/settings")
    local configs = {}
    for _, file in ipairs(files) do
        if file:match(".json$") then
            table.insert(configs, file:match("([^/]+).json$"))
        end
    end
    return configs
end

-- ฟังก์ชันโหลด Auto Load Config
function SaveManager:LoadAutoloadConfig()
    local autoPath = string.format("%s/settings/autoload.txt", self.Folder)
    if isfile(autoPath) then
        local name = readfile(autoPath)
        return self:Load(name)
    end
    return false
end

return SaveManager
