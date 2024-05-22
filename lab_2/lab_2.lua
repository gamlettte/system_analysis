---@package
---@param conditions {["factor_name"]:string, ["factor_prob"]:number}[]
---@return integer[]
---@nodiscard
local function get_shift_array(conditions)

    ---@type integer[]
    local shift_array = {}
    for _, value in pairs(conditions) do

        ---@type string
        local cond_str = string.format("%s(%.6g)", value.factor_name,
                                       value.factor_prob)

        table.insert(shift_array, string.len(cond_str))
    end

    return shift_array
end


---@package
---@param conditions {["factor_name"]:string, ["factor_prob"]:number}[]
---@param initial_shift integer?
---@return nil
local function print_conditions(conditions, initial_shift)

    initial_shift = initial_shift or 0

    -- prepare initial shift
    ---@type string
    local shift_line = string.rep(" ", initial_shift)

    -- prepare line of total width
    ---@type string[]
    local conds_table = {shift_line}
    for _, value in pairs(conditions) do
        table.insert(conds_table, string.format("%s(%.6g)", value.factor_name,
                                                value.factor_prob))
    end

    ---@type string
    local conds_line = table.concat(conds_table, "|")

    ---@type string
    local line = string.rep("-", string.len(conds_line))

    print(line)
    print(conds_line)
    print(line)
end


---@package
---@param data_matrix {["name"]:string, ["data_vector"]:integer[]}[]
---@return integer
---@nodiscard
local function get_initial_shift(data_matrix)

    ---@type integer
    local new_shift = 0

    for _, value in pairs(data_matrix) do
        if string.len(value.name) > new_shift then
            new_shift = string.len(value.name)
        end
    end

    return new_shift
end


---@package
---@param data_matrix {["name"]:string, ["data_vector"]:integer[]}[]
---@param shift_array integer[]
---@return nil
local function print_data(data_matrix, shift_array)

    -- get new initial shift
    ---@type integer
    local new_shift = get_initial_shift(data_matrix)

    for _, row in pairs(data_matrix) do

        ---@type string[]
        local output_line_table = {}

        ---@type string
        local postfix = string.rep(" ", new_shift - string.len(row.name))
        table.insert(output_line_table, row.name .. postfix)

        for i = 1, #row.data_vector do

            ---@type string
            local num_str = tostring(row.data_vector[i])
            postfix = string.rep(" ", shift_array[i] - string.len(num_str))
            table.insert(output_line_table, num_str .. postfix)
        end

        ---@type string
        local output_line = table.concat(output_line_table, "|")
        print(output_line)
        print(string.rep("-", string.len(output_line)))
    end
end


---@package
---@param columns integer
---@return {["factor_name"]:string, ["factor_prob"]:number}[]
---@nodiscard
local function generate_factor_table(columns)

    ---@type {["factor_name"]:string, ["factor_prob"]:number}[]
    local factors_table = {}

    for i = 1, columns do
        print("Input option name")
        ---@type string
        local factor_name = io.read()

        print("input option probability")

        ---@type number
        local factor_prob = tonumber(io.read()) or 0
        factors_table[i] = {
            factor_name = factor_name,
            factor_prob = factor_prob,
        }

        print_conditions(factors_table)
    end
    return factors_table

end


---@package
---@param columns integer
---@param factors_table {["factor_name"]:string, ["factor_prob"]:number}[]
---@return {["name"]:string, ["data_vector"]:integer[]}[]
---@nodiscard
local function generate_data_table(columns, factors_table)

    ---@type {["name"]:string, ["data_vector"]:integer[]}[]
    local return_table = {}

    for i = 1, math.huge do
        print("Input variant name (or press Enter if you end here): ");

        ---@type string 
        local name = io.read()
        if name == "" then
            break
        end

        ---@type integer[]
        local data_vector = {}
        for j = 1, columns do
            print("input ROI coefficient for option " .. name .. " by factor " ..
                      factors_table[j].factor_name .. " in percents : ")
            data_vector[j] = (tonumber(io.read()) or 0) / 100
        end

        return_table[i] = {
            name = name,
            data_vector = data_vector
        }

        ---@type integer
        local initial_shift = get_initial_shift(return_table)

        ---@type integer[]
        local array_shift = get_shift_array(factors_table)

        print_conditions(factors_table, initial_shift)
        print_data(return_table, array_shift)
    end

    return return_table
end


---@package
---@return {["factor_name"]:string, ["factor_prob"]:number}[]
---@return {["name"]:string, ["data_vector"]:integer[]}[]
---@nodiscard
local function generate_table()

    print("Input number of possible situations")

    ---@type integer
    local columns = tonumber(io.read()) or os.exit()
    assert(columns)
    assert(columns > 0)

    ---@type {["factor_name"]:string, ["factor_prob"]:number}[]
    local factors_table = generate_factor_table(columns)
    print_conditions(factors_table)
    print("fine, let us fill now possible strategies")

    ---@type {["name"]:string, ["data_vector"]:integer[]}[]
    local return_table = generate_data_table(columns, factors_table)

    return factors_table, return_table
end


---@package
---@param prob_vector number[]
---@param data_table integer[][]
---@return integer -- index of best strategy
---@return number -- calculated average profit
---@nodiscard
local function calculate_table(prob_vector, data_table)

    ---@type number
    local max_value = -math.huge

    ---@type integer
    local max_index = 0

    for i, data_vector in pairs(data_table) do

        ---@type number
        local sum = 0

        for j = 1, #data_vector do
            sum = sum + data_vector[j] * prob_vector[j]
        end

        if sum > max_value then
            max_value = sum
            max_index = i
        end
    end

    return max_index, max_value
end


local function main()

    print("hello.")

    ---@type {["factor_name"]:string, ["factor_prob"]:number}[]
    local factor_table = {}

    ---@type {["name"]:string, ["data_vector"]:integer[]}[]
    local data_table = {}

    factor_table, data_table = generate_table()

    ---@type number[]
    local prob_vector = {}
    for _, value in pairs(factor_table) do
        assert(type(value.factor_prob) == "number", type(value.factor_prob))
        table.insert(prob_vector, value.factor_prob)
    end

    ---@type integer[][]
    local data_matrix = {}

    ---@type string[]
    local strategy_names = {}

    for _, vector in pairs(data_table) do
        table.insert(data_matrix, vector.data_vector)
        table.insert(strategy_names, vector.name)
    end

    ---@type integer
    local init_shift = get_initial_shift(data_table)

    ---@type integer[]
    local shift_array = get_shift_array(factor_table)

    print_conditions(factor_table, init_shift)
    print_data(data_table, shift_array)

    ---@type integer
    local best_index = nil

    ---@type number
    local best_profit = nil

    best_index, best_profit = calculate_table(prob_vector, data_matrix)
    print("ideal is " .. strategy_names[best_index] .. " with profit of " ..
              best_profit)
end


main()
