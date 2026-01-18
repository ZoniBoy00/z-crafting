local labels = Config.Locales[Config.Locale] or Config.Locales['en']

function _(key, ...)
    if labels[key] then
        return string.format(labels[key], ...)
    end
    return key
end

function DebugPrint(msg)
    if Config.Debug then
        print('^5[z-crafting] ^7' .. msg)
    end
end
