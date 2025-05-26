print("l = ", l)

function say_hello()
    local l=vim.fn.line('.');
    print("currentxl on line = ", l)
    for i,h in ipairs(require("gitsigns").get_hunks() or {}) do
        --print(string.format("Hunk %d: %s %d-%d → %d-%d", i, h.type, h.removed.start, h.removed.start+h.removed.count-1, h.added.start, h.added.start+h.added.count-1))
        if h.type == "delete" then
            print("type = ", h.type, ", delete at = ", h.removed.start, ", with size = ", h.removed.count)
        else
            print("type = ", h.type, ", add at = ", h.added.start, ", with size = ", h.added.count)
        end
        if l>=h.added.start and l<=h.added.start+h.added.count-1 then
        --    break
            print("in this hunk")
        end 
    end

end

vim.keymap.set("n", "<leader>us", say_hello, { desc = "Say Hello" })

