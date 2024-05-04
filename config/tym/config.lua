-- At first, you need to require tym module
local tym = require("tym")

tym.set("font", "JetBrains Mono NF")

-- set by table
tym.set_config({
	autohide = true,
	cell_height = 120,
	bold_is_bright = true,
})
