---@package
---@param evaluation_grids number[][][]
---@return number[]
local function evaluate_table(evaluation_grids)

    ---@type number
    local max_value = -math.huge

    ---@type number[][]
    local accumulated_grid = {}

    for _, grid in ipairs(evaluation_grids) do

        for i, row in ipairs(grid) do

            accumulated_grid[i] = accumulated_grid[i] or {}
            for j, value in ipairs(row) do

                accumulated_grid[i][j] = (accumulated_grid[i][j] or 0) + value

                if value > max_value then
                    max_value = value
                end
            end
        end
    end


    ---@type number
    local norm_coef = max_value * #(accumulated_grid[1])
    for i, row in ipairs(accumulated_grid) do
        for j, value in ipairs(row) do
            accumulated_grid[i][j] = value / norm_coef
        end
    end

	---@type number[]
	local result = {}
	for i = 1, #accumulated_grid do
		result[i] = 1
	end

	while true do

		---@type number[]
		local new_vector = {}
		for _, row in ipairs(accumulated_grid) do
			---@type number
			local sum = 0
			for i = 1, #row do
				sum = sum + row[i] * result[i]
			end
			table.insert(new_vector, sum)
		end

		---@type number
		local lambda = 0
		for _, value in ipairs(new_vector) do
			lambda = lambda + value
		end

		---@type number[]
		local new_result = {}
		for _, value in ipairs(new_vector) do
			table.insert(new_result, value / lambda)
		end

		---@type number
		local max_change = -math.huge
		for i = 1, #new_result do
			if math.abs(result[i] - new_result[i]) > max_change then
				max_change = math.abs(result[i] - new_result[i])
			end
		end

		if max_change < 0.001 then
			return new_result
		else
			result = new_result
		end
	end
end


print("my variant (10)")
---@type number[][][]
local experts_grids = {
    {
		{0.5, 1.0, 0.0},
		{0.0, 0.5, 1.0},
		{1.0, 0.0, 0.5}
	},
    {
		{0.5, 1.0, 0.0},
		{0.0, 0.5, 0.5},
		{1.0, 0.5, 0.5}
	},
    {
		{0.5, 1.0, 0.5},
		{0.0, 0.5, 0.5},
		{0.5, 0.5, 0.5}
	},
}

---@type number[]
local result = evaluate_table(experts_grids)

for i, value in ipairs(result) do
    print("coef of " .. i .. " = " .. value)
end

print("Julia variant (4)")

---@type number[][][]
local _4_th_variant_grid = {
	{
		{0.5, 0.5, 0.0},
		{0.5, 0.5, 0.0},
		{1.0, 1.0, 0.5}
	},
	{
		{0.5, 0.0, 0.5},
		{1.0, 0.5, 0.0},
		{0.5, 1.0, 0.5}
	},
	{
		{0.5, 0.0, 1.0},
		{1.0, 0.5, 1.0},
		{0.0, 0.0, 0.5}
	}
}

result = evaluate_table(_4_th_variant_grid)
for i, value in ipairs(result) do
    print("coef of " .. i .. " = " .. value)
end

