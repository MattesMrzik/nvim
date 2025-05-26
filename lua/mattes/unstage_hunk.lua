function say_hello()
    local l=vim.fn.line('.');
    print("currentxl on line = ", l)
    local added = 0
    local removed = 0
    for i,h in ipairs(require("gitsigns").get_hunks() or {}) do
        -- print(string.format("Hunk %d: %s %d-%d → %d-%d", i, h.type, h.removed.start, h.removed.start+h.removed.count-1, h.added.start, h.added.start+h.added.count-1))
        -- print(string.format("%d %s: %d, %d, %d, %d", i, h.type, h.removed.start, h.removed.count, h.added.start, h.added.count))
        --if h.type == "delete" then
        --print("delete at = ", h.removed.start + added, ", with size = ", h.removed.count)
        --removed = removed + h.removed.count
        --elseif h.type == "add" then
        --print("add at = ", h.added.start + added - removed, ", with size = ", h.added.count)
        --else
        --print("else ", h.added.start + added, ", with size = ", h.added.count)
        --added = added + h.added.count
        --end
        local minus_one_if_not_delete = 1
        if h.type == "delete" then
            minus_one_if_not_delete = 0 
        end
        if l>=h.added.start and l<=h.added.start+h.added.count - minus_one_if_not_delete then
            print(h.type)
            break
        else
            print("no hunk")
        end 
    end
end

vim.keymap.set("n", "<leader>us", say_hello, { desc = "Say Hello" })

