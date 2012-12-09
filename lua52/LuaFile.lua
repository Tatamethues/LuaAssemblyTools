require"bin"
require"Chunk"

LuaFile = {
    -- Default to x86 standard
    new = function(self)
        return setmetatable({
            Identifier = "\027Lua",
            Version = 0x52,
            Format = "Official",
            BigEndian = false,
            IntegerSize = 4,
            SizeT = 4,
            InstructionSize = 4,
            NumberSize = 8,
            IsFloatingPoint = true,
            Main = Chunk:new(),
            Tail = "",
        }, { __index = self, __newindex = function() error"Cannot set new fields on LuaFile" end })
    end,

    Compile = function(self, verify)
        local c = ""
        c = c .. self.Identifier
        c = c .. DumpBinary.Int8(self.Version) -- Should be 0x51 (Q)
        c = c .. DumpBinary.Int8(self.Format == "Official" and 0 or 1)
        c = c .. DumpBinary.Int8(self.BigEndian and 0 or 1)
        c = c .. DumpBinary.Int8(self.IntegerSize)
        c = c .. DumpBinary.Int8(self.SizeT)
        c = c .. DumpBinary.Int8(self.InstructionSize)
        c = c .. DumpBinary.Int8(self.NumberSize)
        c = c .. DumpBinary.Int8(self.IsFloatingPoint and 0 or 1)
        c = c .. self.Tail
        -- Main function
        c = c .. self.Main:Compile(self, verify)
        return c
    end,
    
    CompileToFunction = function(self)
        return loadstring(self:Compile())
    end,
    
    StripDebugInfo = function(self)
        self.Main:StripDebugInfo()
    end,
}