function csv_to_table(s)
    local t = T {}
    for v in s:gmatch("[^,]+") do
        t[#t + 1] = v
    end
    return t
    -- return s:split(",")
end

function table_to_csv(t)
    return t:concat(',')
end
