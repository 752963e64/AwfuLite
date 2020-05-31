pcall(require, "plugins.language_c")

local syntax = require "core.syntax"

syntax.add {
  files = {
    "%.h$", "%.inl$", "%.cpp$", "%.cc$", "%.C$", "%.cxx$",
    "%.c++$", "%.hh$", "%.H$", "%.hxx$", "%.hpp$", "%.h++$"
  },
  comment = "//",
  patterns = {
    { pattern = "//.-\n",               type = "comment"  },
    { pattern = { "/%*", "%*/" },       type = "comment"  },
    { pattern = { "#", "[^\\]\n" },     type = "comment"  },
    { pattern = { '"', '"', '\\' },     type = "string"   },
    { pattern = { "'", "'", '\\' },     type = "string"   },
    { pattern = "-?0x%x+",              type = "number"   },
    { pattern = "-?%d+[%d%.eE]*f?",     type = "number"   },
    { pattern = "-?%.?%d+f?",           type = "number"   },
    { pattern = "[%+%-=/%*%^%%<>!~|&]", type = "operator" },
    { pattern = "[%a_][%w_]*%f[(]",     type = "function" },
    { pattern = "[%a_][%w_]*",          type = "symbol"   },
  },
  symbols = {
    ["alignof"]  = "keyword",
    ["alignas"]  = "keyword",
    ["and"]      = "keyword",
    ["and_eq"]   = "keyword",
    ["not"]      = "keyword",
    ["not_eq"]   = "keyword",
    ["or"]       = "keyword",
    ["or_eq"]    = "keyword",
    ["xor"]      = "keyword",
    ["xor_eq"]   = "keyword",
    ["private"]  = "keyword",
    ["protected"] = "keyword",
    ["public"]   = "keyword",
    ["register"] = "keyword",
    ["nullptr"]  = "keyword",
    ["operator"] = "keyword",
    ["asm"]      = "keyword",
    ["bitand"]   = "keyword",
    ["bitor"]    = "keyword",
    ["catch"]    = "keyword",
    ["throw"]    = "keyword",
    ["try"]      = "keyword",
    ["class"]    = "keyword",
    ["compl"]    = "keyword",
    ["explicit"] = "keyword",
    ["export"]   = "keyword",
    ["concept"]  = "keyword",
    ["consteval"] = "keyword",
    ["constexpr"] = "keyword",
    ["constinit"] = "keyword",
    ["const_cast"] = "keyword",
    ["dynamic_cast"] = "keyword",
    ["reinterpret_cast"]   = "keyword",
    ["static_cast"]   = "keyword",
    ["static_assert"] = "keyword",
    ["template"]  = "keyword",
    ["this"]      = "keyword",
    ["thread_local"] = "keyword",
    ["requires"]  = "keyword",
    ["co_wait"]   = "keyword",
    ["co_return"] = "keyword",
    ["co_yield"]  = "keyword",
    ["decltype"] = "keyword",
    ["delete"]   = "keyword",
    ["export"]   = "keyword",
    ["friend"]   = "keyword",
    ["typeid"]   = "keyword",
    ["typename"] = "keyword",
    ["mutable"]  = "keyword",
    ["virtual"]  = "keyword",
    ["using"]    = "keyword",
    ["namespace"] = "keyword",
    ["new"]      = "keyword",
    ["noexcept"] = "keyword",
    ["if"]       = "keyword",
    ["then"]     = "keyword",
    ["else"]     = "keyword",
    ["elseif"]   = "keyword",
    ["do"]       = "keyword",
    ["while"]    = "keyword",
    ["for"]      = "keyword",
    ["break"]    = "keyword",
    ["continue"] = "keyword",
    ["return"]   = "keyword",
    ["goto"]     = "keyword",
    ["struct"]   = "keyword",
    ["union"]    = "keyword",
    ["typedef"]  = "keyword",
    ["enum"]     = "keyword",
    ["extern"]   = "keyword",
    ["static"]   = "keyword",
    ["volatile"] = "keyword",
    ["const"]    = "keyword",
    ["inline"]   = "keyword",
    ["switch"]   = "keyword",
    ["case"]     = "keyword",
    ["default"]  = "keyword",
    ["auto"]     = "keyword",
    ["const"]    = "keyword",
    ["void"]     = "keyword",
    ["int"]      = "keyword2",
    ["short"]    = "keyword2",
    ["long"]     = "keyword2",
    ["float"]    = "keyword2",
    ["double"]   = "keyword2",
    ["char"]     = "keyword2",
    ["unsigned"] = "keyword2",
    ["bool"]     = "keyword2",
    ["true"]     = "keyword2",
    ["false"]    = "keyword2",
    ["wchar_t"]  = "keyword2",
    ["char8_t"]  = "keyword2",
    ["char16_t"] = "keyword2",
    ["char32_t"] = "keyword2",
    ["NULL"]     = "literal",
  },
}
