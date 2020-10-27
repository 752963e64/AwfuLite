local syntax = require "core.syntax"

syntax.add {
  files = { "%.js$", "%.json$", "%.cson$" },
  comment = "//",
  patterns = {
    { pattern = "//.-\n",               type = "comment"  },
    { pattern = { "/%*", "%*/" },       type = "comment"  },
    { pattern = { '"', '"', '\\' },     type = "string"   },
    { pattern = { "'", "'", '\\' },     type = "string"   },
    { pattern = "0x[%da-fA-F]+",        type = "number"   },
    { pattern = "-?%d+[%d%.eE]*",       type = "number"   },
    { pattern = "-?%.?%d+",             type = "number"   },
    { pattern = "[%+%-=/%*%^%%<>!~|&]", type = "operator" },
    { pattern = "[%a_][%w_]*%f[(]",     type = "function" },
    { pattern = "[%a_][%w_]*",          type = "symbol"   },
  },
  symbols = {
    ["arguments"]  = "keyword2",
    ["async"]      = "keyword",
    ["await"]      = "keyword",
    ["break"]      = "keyword",
    ["case"]       = "keyword",
    ["catch"]      = "keyword",
    ["class"]      = "keyword",
    ["const"]      = "keyword",
    ["continue"]   = "keyword",
    ["debugger"]   = "keyword",
    ["default"]    = "keyword",
    ["delete"]     = "keyword",
    ["do"]         = "keyword",
    ["else"]       = "keyword",
    ["export"]     = "keyword",
    ["extends"]    = "keyword",
    ["false"]      = "literal",
    ["finally"]    = "keyword",
    ["for"]        = "keyword",
    ["function"]   = "keyword",
    ["get"]        = "keyword",
    ["if"]         = "keyword",
    ["import"]     = "keyword",
    ["in"]         = "keyword",
    ["Infinity"]   = "keyword2",
    ["instanceof"] = "keyword",
    ["let"]        = "keyword",
    ["NaN"]        = "keyword2",
    ["new"]        = "keyword",
    ["null"]       = "literal",
    ["return"]     = "keyword",
    ["set"]        = "keyword",
    ["super"]      = "keyword",
    ["switch"]     = "keyword",
    ["this"]       = "keyword2",
    ["throw"]      = "keyword",
    ["true"]       = "literal",
    ["try"]        = "keyword",
    ["typeof"]     = "keyword",
    ["undefined"]  = "literal",
    ["var"]        = "keyword",
    ["void"]       = "keyword",
    ["while"]      = "keyword",
    ["with"]       = "keyword",
    ["yield"]      = "keyword",
  },
}