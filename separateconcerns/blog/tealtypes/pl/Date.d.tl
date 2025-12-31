local record Date
    record Format
        metamethod __call: function(Format, string): Format
        parse: function(Format, string): Date
        tostring: function(Format, Date): string
    end

    toUTC: function(Date): Date
end

return Date
