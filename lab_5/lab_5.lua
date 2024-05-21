---@alias criterion fun(grid: number[][][], weights: number[]?): number[][]


---@package
---@param grid integer[][][]
---@param weights_array number[]
---@param criterion criterion
---@return integer[][] minimums_matrix matrix of minimums
---@nodiscard
local function get_processed_matrix(grid, weights_array, criterion)

    return criterion(grid, weights_array)
end

---@package
---@param minimums_matrix integer[][]
---@return integer[][] advantage_matrix matrix of advantages
---@nodiscard
local function get_advantage_matrix(minimums_matrix)

    ---@type integer[][]
    local advantage_matrix = {}
    for i, row in ipairs(minimums_matrix) do

        ---@type integer[]
        local advantage_row = row or {}
        for j, value in ipairs(row) do
            advantage_row[j] = math.max(0, value - minimums_matrix[j][i])
        end
        advantage_matrix[i] = advantage_row
    end

    return advantage_matrix
end


---@package
---@param advantage_matrix integer[][]
---@return integer[] non_advantage_vector
---@nodiscard
local function get_non_advantage_vector(advantage_matrix)

    ---@type integer[]
    local non_advantage_vector = {}
    for _, row in ipairs(advantage_matrix) do

        for j, value in ipairs(row) do

            ---@type number
            local temp = non_advantage_vector[j] or -math.huge
            non_advantage_vector[j] = (temp > value) and temp or value
        end
    end

    for i, value in ipairs(non_advantage_vector) do
        non_advantage_vector[i] = 1 - value
    end

    return non_advantage_vector
end

---@package
---@param evaluation_grid integer[][][]
---@param weights_array number[]
---@param criteria_array (criterion)[]
---@return number[][] result_vectors final vectors for each criterion
---@nodiscard
local function process_table(evaluation_grid, weights_array, criteria_array)

    ---@type number[][]
    local result_vectors = {}

    for _, criterion in ipairs(criteria_array) do

        ---@type number[][]
        local minimums_matrix = get_processed_matrix(evaluation_grid, weights_array, criterion)

        ---@type number[][]
        local advantage_matrix = get_advantage_matrix(minimums_matrix)

        ---@type number[]
        local non_advantage_vector = get_non_advantage_vector(advantage_matrix)

        table.insert(result_vectors, non_advantage_vector)
    end

    return result_vectors
end



---@type criterion
local function criterion_1(grid)

    ---@type number[][][]
    local new_grid = {}
    for _, matrix in ipairs(grid) do

        ---@type number[][]
        local new_matrix = {}
        for _, row in ipairs(matrix) do

            ---@type number[]
            local new_row = {}
            for _, value in ipairs(row) do

                table.insert(new_row, value)
            end

            table.insert(new_matrix, new_row)
        end

        table.insert(new_grid, new_matrix)
    end

    ---@type integer[][]
    local minimums_matrix = {}

    for _, matrix in ipairs(grid) do
        for i, row in ipairs(matrix) do

            ---@type integer[]
            local minimal_row = minimums_matrix[i] or {}

            for j, cell in ipairs(row) do

                ---@type integer
                local minimal_value = minimal_row[j] or 2

                if cell < minimal_value then
                    minimal_row[j] = cell
                end
            end

            minimums_matrix[i] = minimal_row
        end
    end

    return minimums_matrix
end

---@type criterion
local function criterion_2(grid, weights_array)

    ---@type number[][][]
    local new_grid = {}
    for matrix_index, matrix in ipairs(grid) do

        ---@type number
        local weight = weights_array[matrix_index]

        ---@type number[][]
        local new_matrix = {}
        for _, row in ipairs(matrix) do

            ---@type number[]
            local new_row = {}
            for _, value in ipairs(row) do

                table.insert(new_row, value * weight)
            end

            table.insert(new_matrix, new_row)
        end

        table.insert(new_grid, new_matrix)
    end


    ---@type number[][]
    local sum_matrix = {}

    for _, matrix in ipairs(new_grid) do
        for i, row in ipairs(matrix) do

            ---@type number[]
            local new_row = sum_matrix[i] or {}

            for j, value in ipairs(row) do
                new_row[j] = (new_row[j] or 0) + value
            end

            sum_matrix[i] = new_row
        end
    end
    return sum_matrix
end

---@package
---@param filter_vector number[]
---@param filtered_vector number[]
---@return integer index final result index
---@nodiscard
local function filter_result(filter_vector, filtered_vector)

    ---@type integer
    local max_filtered_index = 0

    ---@type number
    local max_filtered_value = -math.huge

    for i = 1, #(filter_vector) do
        if filter_vector[i] == 1
            and filtered_vector[i] > max_filtered_value then

            max_filtered_index = i
            max_filtered_value = filtered_vector[i]
        end
    end

    return max_filtered_index
end

print("\nmy task:")
---@type integer[][][]
local my_evaluation_grid =
{
    { -- R1
        {1, 1, 0},
        {0, 1, 0},
        {0, 1, 1}
    },
    { -- R2
        {1, 1, 1},
        {0, 1, 0},
        {0, 1, 1}
    },
    { -- R3
        {1, 0, 0},
        {0, 1, 0},
        {1, 1, 1}
    }
}

---@type number[]
local my_weights_array =
{
    0.4,
    0.35,
    0.25
}

---@type number[][]
local my_result_vectors = process_table(my_evaluation_grid,
                                        my_weights_array,
                                        {criterion_1, criterion_2})

for i, result_vector in ipairs(my_result_vectors) do
    print("final result for criterion " .. i .. ": "
          .. table.concat(result_vector, ", "))
end

---@type integer
local max_filtered_index = filter_result(my_result_vectors[1], my_result_vectors[2])

print("final filtered index is " .. max_filtered_index)


print("\nbook example:")

---@type integer[][][]
local book_example_evaluation_grid =
{
    { -- R1
        {1, 0, 0},
        {1, 1, 0},
        {1, 1, 1}
    },
    { -- R2
        {1, 1, 1},
        {1, 1, 1},
        {0, 0, 1}
    },
    { --R3
        {1, 0, 1},
        {1, 1, 1},
        {0, 0, 1}
    }
}

---@type number[]
local book_example_weight_array =
{
    0.3,
    0.1,
    0.6
}


local book_example_result_vectors = process_table(book_example_evaluation_grid,
                                                  book_example_weight_array,
                                                  {criterion_1, criterion_2})

for i, result_vector in ipairs(book_example_result_vectors) do
    print("final result for criterion " .. i .. ": " .. table.concat(result_vector, ", "))
end

---@type integer
local max_filtered_index = filter_result(book_example_result_vectors[1],
                                         book_example_result_vectors[2])

print("final filtered index is " .. max_filtered_index)
