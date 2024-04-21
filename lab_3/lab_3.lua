---@package
---@param experts_table {["weight"]: number, ["price"]: number}[]
---@return number
---@nodiscard
local function calculate_table_price_sum(experts_table)
    ---@type number
    local sum = 0

    for _, v in ipairs(experts_table) do
        sum = sum + v.price
    end

    return sum
end


---@package
---@param experts_table {["weight"]: number, ["price"]: number}[]
---@return number
---@nodiscard
local function calculate_table_weight_sum(experts_table)
    ---@type number
    local sum = 0

    for _, v in ipairs(experts_table) do
        sum = sum + v.weight
    end

    return sum
end


-- Function to generate all possible subsets of size k from a given set
---@package
---@param set any[]
---@param k integer
---@return any[][]
---@nodiscard
local function generate_subsets(set, k)
    local n = #set
    local subsets = {}

    -- Recursive function to generate subsets
    local function generate_subset_util(current, start, size)
        if size == k then
            table.insert(subsets, current)
            return
        end

        for i = start, n do
            local new_subset = {}
            for j = 1, #current do
                table.insert(new_subset, current[j])
            end
            table.insert(new_subset, set[i])
            generate_subset_util(new_subset, i + 1, size + 1)
        end
    end


    generate_subset_util({}, 1, 0)
    return subsets
end


---@package
---@param experts_table {["weight"]: number, ["price"]: number}[]
---@param expert_count integer
---@param budget number
---@return {["weight"]: number, ["price"]: number}[][]
---@nodiscard
local function generate_expert_groups(experts_table,
                                      expert_count,
                                      budget)

    ---@type {["weight"]: number, ["price"]: number}[][]
    local expert_groups = generate_subsets(experts_table, expert_count)

    do
        local i = 1
        while i <= #expert_groups do
            if calculate_table_price_sum(expert_groups[i]) <= budget then
                i = i + 1
            else
                table.remove(expert_groups, i)
            end
        end
    end

    for _, group in ipairs(expert_groups) do
        assert(calculate_table_price_sum(group) <= budget)
    end

    return expert_groups
end


---@package
---@param experts_table {["weight"]: number, ["price"]: number}[]
---@param budget number
---@param min_expert_count integer
---@param max_expert_count integer
---@return {["weight"]: number, ["price"]: number}[]
local function calculate_table(experts_table,
                               budget,
                               min_expert_count,
                               max_expert_count)
    assert(type(experts_table) == "table")
    assert(type(budget) == "number")
    assert(budget > 0)
    assert(type(max_expert_count) == "number")
    assert(max_expert_count > 0)
    assert(type(min_expert_count) == "number")
    assert(min_expert_count > 0)
    assert(max_expert_count >= min_expert_count)

    table.sort(experts_table, function(a, b)
        return a.weight > b.weight
    end
)

    for expert_count = max_expert_count, min_expert_count, -1 do

        ---@type {["weight"]: number, ["price"]: number}[][]
        local expert_groups = generate_expert_groups(experts_table,
                                                     expert_count, budget)
        if #expert_groups == 0 then
            goto continue
        end

        ---@type number
        local max_value = -math.huge
        ---@type integer
        local max_index = 0

        for index, group in ipairs(expert_groups) do

            ---@type number
            local value = calculate_table_weight_sum(group)

            if value > max_value then
                max_value = value
                max_index = index
            end
        end

        do
            return expert_groups[max_index]
        end
        ::continue::
    end
end


---@type {["weight"]: number, ["price"]: number}[]
local experts_table = {
    {weight = 0.9, price = 280},
    {weight = 0.9, price = 210},
    {weight = 0.8, price = 190},
    {weight = 0.8, price = 160},
    {weight = 0.7, price = 150},
    {weight = 0.7, price = 140},
    {weight = 0.7, price = 120},
    {weight = 0.6, price = 110},
    {weight = 0.5, price = 100},
    {weight = 0.5, price = 80},
}

---@type number
local budget = 1100

---@type integer
local min_experts_count = 5

---@type integer
local max_experts_count = 9

---@type {["weight"]: number, ["price"]: number}[]
local result = calculate_table(experts_table, budget, min_experts_count,
                               max_experts_count)

for _, value in ipairs(result) do
    print("weight = " .. value.weight .. " price = " .. value.price)
end

print("total price = " .. calculate_table_price_sum(result))
print("total weight = " .. calculate_table_weight_sum(result))

