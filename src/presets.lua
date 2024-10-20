-- function that generates a unique uuid
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

return {
    ["main"] = {
        LuaVersion = "LuaU",
        VarNamePrefix = "",
        NameGenerator = "MangledShuffled",
        PrettyPrint = false,
        Seed = 0,
        Steps = {
            {
                Name = "Vmify",
                Settings = {
                    VM = "random",
                },
            },
            {
                Name = "AddVararg",
                Settings = {},
            },
            {
                Name = "EncryptStrings",
                Settings = {},
            },
            {
                Name = "SplitStrings",
                Settings = {},
            },
            {
                Name = "PaidAntiTamper",
                Settings = {},
            },
            {
                Name = "Vmify",
                Settings = {
                    VM = "random",
                },
            },
            {
                Name = "StringsToExpressions",
                Settings = {},
            },
            {
                Name = "NumbersToExpressions",
                Settings = {},
            },
            {
                Name = "WrapInFunction",
                Settings = {},
            },
            {
                Name = "ProxifyLocals",
                Settings = {},
            },
        }
    }
}
