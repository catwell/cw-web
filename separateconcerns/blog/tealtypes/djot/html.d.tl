local type IRenderer = require("djot").IRenderer

local record M
    record Renderer is IRenderer
        new: function(self): self
    end
end

return M
