-- This Script is Part of the ObscuraLua Obfuscator by User319183
--
-- FreeAntiTamper.lua
--
-- This script adds AntiTamper code to the script to prevent tampering. When tampering is detected, the script will stop executing.
local Step = require("ObscuraLua.step");
local Parser = require("ObscuraLua.parser");
local Enums = require("ObscuraLua.enums");
local EncryptStrings = require("ObscuraLua.steps.EncryptStrings");
local WrapInFunction = require("ObscuraLua.steps.WrapInFunction");

-- Initialize the steps
local wrapInFunctionStep = WrapInFunction:new()

local FreeAntiTamper = Step:extend();
FreeAntiTamper.Description =
"This step adds AntiTamper code to the script to prevent tampering. When tampering is detected, the script will stop executing.";
FreeAntiTamper.Name = "Anti Tamper";

function FreeAntiTamper:init(settings) end

function FreeAntiTamper:apply(ast, pipeline)
    local code = "do local valid = true;";
        code = code .. [[
        while true do end

    end

        ]]




    local parsed = Parser:new({ LuaVersion = Enums.LuaVersion.Lua51 }):parse(code);
    local doStat = parsed.body.statements[1];
    doStat.body.scope:setParent(ast.body.scope);
    table.insert(ast.body.statements, 2, doStat); -- Insert after the first statement

    -- Encrypt the AntiTamper code
    local encryptStringsStep = EncryptStrings:new()
    ast = encryptStringsStep:apply(ast, pipeline)

    -- Apply the WrapInFunction step
    ast = wrapInFunctionStep:apply(ast, pipeline)

    return ast
end

return FreeAntiTamper;