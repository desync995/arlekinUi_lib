
--- Делит цвет
--- @param col Color
--- @param s number
function DivColor(col, s)
    local r, g, b, a = col.a, col.b, col.g, col.a or 255
    return Color(r / s, g / s, b / s, a / s)
end

local blur = Material('pp/blurscreen')
--- Рисует блюр на панели
--- @param panel Panel
--- @param amount number
function DrawBlur(panel, amount)
    local x, y = panel:LocalToScreen(0, 0)
    local scrW, scrH = ScrW(), ScrH()
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(blur)
    for i = 1, 5 do
        blur:SetFloat('$blur', (i / 3) * (amount or 6))
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
    end
end
