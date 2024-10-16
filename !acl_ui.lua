ARLEKINUI_VER = 0.1
--- Алиас для создания хука
--- @param eventName string
--- @param uid string
--- @param func function
--- @return nil
function Hook(eventName, uid, func)
    return hook.Add(eventName, uid, func)
end

--- Алиас для создания конкомманды
--- @param name string
--- @param callback function
--- @return nil
function Concommand(name, callback)
    return concommand.Add(name, callback)
end

--- Алиас для нета
--- @param name string
--- @param callback function
function Net(name, callback)
    return net.Receive(name, callback)
end

if CLIENT then
    local base_h = ScrH() / 1080
    local math_Round = math.Round
    local cache_h = {}
    local cachedColors = {}
    local oldColor = Color

    --- Создает кешированный цвет (TEST)
    --- @param r number
    --- @param g number
    --- @param b number
    --- @param a number
    --- @return Color
    function Color(r, g, b, a)
        local mixed = string.format('%d%d%d%d', r, g, b, a or 255)
        if cachedColors[mixed] then
            return cachedColors[mixed]
        end

        local toMix = string.format('%d%d%d%d', r, g, b, a or 255)
        cachedColors[toMix] = oldColor(r, g, b, a)
        return oldColor(r, g, b, a)
    end

    --- Создает шрифт
    --- usage - CreateFont('usagename@family@size')
    --- @param data string
    --- @return nil
    function CreateFont(data)
        data = string.Explode('@', data)
        local ret = surface.CreateFont(data[1], {
            size = scl(tonumber(data[3])),
            font = data[2],
            extended = true,
        })
        print('Succesfully registred font with name: ' .. data[1] .. ' size: ' .. data[3])
        return ret
    end

    --- Создает материал (Упрощение) & Кеширование
    --- @param material string
    --- @return IMaterial
    function SmoothMaterial(material)
        if cacheMats[material] then return cacheMats[material] end
        local mat = Material(material, 'smooth mips')
        cacheMats[material] = mat
        return mat
    end

    --- Лерпует цвет
    --- @param t number
    --- @param from Color
    --- @param to Color
    --- @return Color
    function LerpColor(t, from, to)
        return Color((1 - t) * from.r + t * to.r, (1 - t) * from.g + t * to.g, (1 - t) * from.b + t * to.b,
            (1 - t) * from.a + t * to.a)
    end

    --- Создает панель с последующим callback
    --- @param panel string
    --- @param callback function(panel)
    --- @return Panel
    function ui(panel, callback, parent)
        local v = vgui.Create(panel, parent)
        callback(v)
        return v
    end

    --- Обратная совместимость
    CreateUi = ui

    --- Переводит абсолютные значения в относительные экрана
    --- @param px number
    --- @return number
    function scl(px)
        if cache_h[px] then
            return cache_h[px]
        else
            local result = math_Round(px * base_h)
            cache_h[px] = result
            return result
        end
    end

    Hook('OnScreenSizeChanged', 'rp.validatescreen', function()
        base_h = ScrH() / 1080
        cache_h = {}
    end)

    -- ty to sincopa <3
    local cachedParsedText = setmetatable({}, {
        __mode = 'v'
    })

    local cachedProcessedText = setmetatable({}, {
        __mode = 'v'
    })

    local function colorToString(color)
        return string.format('%d,%d,%d,%d', color.r or 255, color.g or 255, color.b or 255, color.a or 255)
    end

    local function textSegments(segments)
        local result = ''
        for _, segment in ipairs(segments) do
            local text = segment.text or ''
            if segment.font then text = string.format('<font=%s>%s</font>', segment.font, text) end
            if segment.color then text = string.format('<color=%s>%s</color>', colorToString(segment.color), text) end
            result = result .. text
        end
        return result
    end
    --- Создает markUp с простой структурой
    --- @param options table
    --- @return nil
    function draw.markupText(options)
        local text
        if type(options.text) == 'table' then
            text = cachedProcessedText[options.text]
            if not text then
                text = textSegments(options.text)
                cachedProcessedText[options.text] = text
            end
        else
            text = options.text or ''
            if options.font then text = string.format('<font=%s>%s</font>', options.font, text) end
            if options.color then text = string.format('<color=%s>%s</color>', colorToString(options.color), text) end
        end

        local parsed = cachedParsedText[text]
        if not parsed then
            parsed = markup.Parse(text)
            cachedParsedText[text] = parsed
        end

        parsed:Draw(options.x or 0, options.y or 0, options.alignX or TEXT_ALIGN_LEFT, options.alignY or TEXT_ALIGN_TOP,
            options.alpha or 255)
    end
end
