local Step = require("ObscuraLua.step")
local Ast = require("ObscuraLua.ast")
local visitast = require("ObscuraLua.visitast")
local util = require("ObscuraLua.util")
local random = math.random
local AstKind = Ast.AstKind

local StringsToExpressions = Step:extend()
StringsToExpressions.Description = "This Step Converts string Literals to Expressions"
StringsToExpressions.Name = "Strings To Expressions"

StringsToExpressions.SettingsDescriptor = {
    Treshold = {
        type = "number",
        default = 1,
        min = 0,
        max = 1,
    },
    InternalTreshold = {
        type = "number",
        default = 0.2,
        min = 0,
        max = 0.8,
    },
    MaxDepth = {
        type = "number",
        default = 50,
        min = 0,
        max = 100,
    },
}

function StringsToExpressions:init(settings)
    settings = settings or {}
    self.InternalTreshold = settings.InternalTreshold or 0.2
    self.MaxDepth = settings.MaxDepth or 50
    self.Treshold = settings.Treshold or 1
    self.ExpressionGenerators = {
        function(val, depth)
            local len = string.len(val)
            if len <= 1 then return false end
            local splitIndex = math.random(1, len - 1)
            local str1 = string.sub(val, 1, splitIndex)
            local str2 = string.sub(val, splitIndex + 1)
            return Ast.ConcatExpression(self:CreateStringExpression(str1, depth), self:CreateStringExpression(str2, depth))
        end,
        function(val, depth)
            local reversed = string.reverse(val)
            return Ast.StringExpression(reversed)
        end,
        function(val, depth)
            local upper = string.upper(val)
            return Ast.StringExpression(upper)
        end,
        function(val, depth)
            if string.len(val) < 1 then return false end
            local randomChar = string.char(math.random(32, 126))
            local randomPos = math.random(1, string.len(val) + 1)
            local modifiedVal = string.sub(val, 1, randomPos - 1) .. randomChar .. string.sub(val, randomPos)
            local removeFunc = function(str) return string.sub(str, 1, randomPos - 1) .. string.sub(str, randomPos + 1) end
            return Ast.ModifyExpression(Ast.StringExpression(modifiedVal), removeFunc)
        end,
        function(val, depth)
            local shift = math.random(1, 5)
            local shiftedVal = ""
            for i = 1, #val do
                local char = string.byte(val, i)
                shiftedVal = shiftedVal .. string.char((char + shift) % 256)
            end
            local unshiftFunc = function(str)
                local unshiftedVal = ""
                for i = 1, #str do
                    local char = string.byte(str, i)
                    unshiftedVal = unshiftedVal .. string.char((char - shift) % 256)
                end
                return unshiftedVal
            end
            return Ast.ModifyExpression(Ast.StringExpression(shiftedVal), unshiftFunc)
        end,
        function(val, depth)
            if string.len(val) < 2 then return false end
            local splitIndex = math.random(1, string.len(val) - 1)
            local duplicatePart = string.sub(val, 1, splitIndex)
            local modifiedVal = duplicatePart .. val
            local trimFunc = function(str) return string.sub(str, splitIndex + 1) end
            return Ast.ModifyExpression(Ast.StringExpression(modifiedVal), trimFunc)
        end,
        function(val, depth)
            local lowercase = string.lower(val)
            return Ast.StringExpression(lowercase)
        end,
        function(val, depth)
            local doubleVal = val .. val
            return Ast.StringExpression(doubleVal)
        end,
        function(val, depth)
            local scrambledVal = string.gsub(val, ".", function(c) return string.char(string.byte(c) + math.random(-2, 2)) end)
            return Ast.StringExpression(scrambledVal)
        end,
        function(val, depth)
            local randomSplit = math.random(1, string.len(val))
            local part1 = string.sub(val, 1, randomSplit)
            local part2 = string.sub(val, randomSplit + 1)
            return Ast.ConcatExpression(Ast.StringExpression(part1), Ast.StringExpression(part2))
        end,
        function(val, depth)
            local obfuscated = string.reverse(string.gsub(val, ".", function(c) return string.char(string.byte(c) + math.random(-3, 3)) end))
            return Ast.StringExpression(obfuscated)
        end,
    }

    self.ExpressionGenerators = util.shuffle(self.ExpressionGenerators)
    self.cachedExpressionGenerators = self.ExpressionGenerators
end

function StringsToExpressions:CreateStringExpression(val, depth)
    if val == nil then
        return
    end
    if depth > 0 and math.random() >= self.InternalTreshold * 0.1 or depth > self.MaxDepth then
        return Ast.StringExpression(val)
    end

    local cachedGenerators = self.cachedExpressionGenerators
    for i = 1, #cachedGenerators do
        local node = cachedGenerators[i](val, depth + 1)
        if node then
            return node
        end
    end

    return Ast.StringExpression(val)
end

function StringsToExpressions:apply(ast)
    local function isStringExpression(node)
        return node.kind == AstKind.StringExpression
    end

    visitast(ast, function(node)
        if isStringExpression(node) then
            while random(0, 10) <= self.Treshold do
                local newNode = self:CreateStringExpression(node.value, 0)
                if newNode then
                    node = newNode
                else
                    break
                end
            end
        end
    end)
end

return StringsToExpressions
