local function uuid()
    return string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function(c)
        return string.format('%x', (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb))
    end)
end

return {
    main = {
        LuaVersion = "LuaU",
        VarNamePrefix = "",
        NameGenerator = "MangledShuffled",
        PrettyPrint = false,
        Seed = 0,
        Steps = {
            { Name = "Vmify", Settings = { VM = "random" } },
            { Name = "AddVararg" },
            { Name = "EncryptStrings" },
            { Name = "SplitStrings" },
            { Name = "PaidAntiTamper" },
            { Name = "StringsToExpressions" },
            { Name = "NumbersToExpressions" },
            { Name = "WrapInFunction" }
        }
    }
}
