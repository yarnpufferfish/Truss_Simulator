local function parse_truss_data(data)

    local truss_data = {}

    ------------------------------------------------------------
    -- DEFAULTS
    ------------------------------------------------------------

    truss_data.time_step = settings.time_step
    truss_data.node_damping = settings.node_damping

    truss_data.dimensions = nil
    truss_data.extrude = nil
    truss_data.pattern = nil
    truss_data.layers = nil
    truss_data.depth = nil

    truss_data.joints = {}
    truss_data.members = {}
    truss_data.constraints = {}
    truss_data.loads = {}

    local section = nil

    ------------------------------------------------------------
    -- VALID VALUES
    ------------------------------------------------------------

    local valid_extrude = {
        X = true,
        Y = true,
        Z = true
    }

    local valid_pattern = {
        FORWARD = true,
        BACKWARD = true,
        CROSS = true
    }

    ------------------------------------------------------------
    -- READ FILE LINE BY LINE
    ------------------------------------------------------------

    for line in data:gmatch("[^\r\n]+") do

        -- Remove leading/trailing whitespace
        line = line:match("^%s*(.-)%s*$")

        -- Ignore empty lines and separators
        if line ~= "" and line ~= "---" then

            --------------------------------------------------------
            -- SETTINGS
            --------------------------------------------------------

            local value

            -- DIM
            value = line:match("^DIM%s+(%d+)$")

            if value then
                truss_data.dimensions = tonumber(value)
                section = nil

            else

                -- EXTRUDE
                value = line:match("^EXTRUDE%s+(%S+)$")

                if value then
                    if valid_extrude[value] then
                        truss_data.extrude = value
                    else
                        truss_data.extrude = nil
                    end

                    section = nil

                else

                    -- PATTERN
                    value = line:match("^PATTERN%s+(%S+)$")

                    if value then
                        if valid_pattern[value] then
                            truss_data.pattern = value
                        else
                            truss_data.pattern = nil
                        end

                        section = nil

                    else

                        -- LAYERS
                        value = line:match("^LAYERS%s+(%d+)$")

                        if value then
                            truss_data.layers = tonumber(value)
                            section = nil

                        else

                            -- DEPTH
                            value = line:match(
                                "^DEPTH%s+([%-%d%.eE]+)$"
                            )

                            if value then
                                truss_data.depth = tonumber(value)
                                section = nil

                            ------------------------------------------------
                            -- SECTION HEADERS
                            ------------------------------------------------

                            elseif line:match("^JOINTS%s+%d+$") then
                                section = "joints"

                            elseif line:match("^MEMBERS%s+%d+$") then
                                section = "members"

                            elseif line:match("^CONSTRAINTS%s+%d+$") then
                                section = "constraints"

                            elseif line:match("^LOADS%s+%d+$") then
                                section = "loads"

                            ------------------------------------------------
                            -- JOINTS
                            ------------------------------------------------

                            elseif section == "joints" then

                                local id, x, y, z =
                                    line:match(
                                        "^(%d+)%s+([%-%d%.eE]+)%s+([%-%d%.eE]+)%s*([%-%d%.eE]*)"
                                    )

                                if id then

                                    id = tonumber(id)
                                    x = tonumber(x)
                                    y = tonumber(y)

                                    if z and z ~= "" then
                                        z = tonumber(z)

                                        table.insert(
                                            truss_data.joints,
                                            {id, x, y, z}
                                        )
                                    else
                                        table.insert(
                                            truss_data.joints,
                                            {id, x, y,0}
                                        )
                                    end
                                end

                            ------------------------------------------------
                            -- MEMBERS
                            ------------------------------------------------

                            elseif section == "members" then

                                local id, n1, n2, area, material =
                                    line:match(
                                        "^(%d+)%s+(%d+)%s+(%d+)%s+([%-%d%.eE]+)%s+(%S+)"
                                    )

                                if id then
                                    table.insert(
                                        truss_data.members,
                                        {
                                            tonumber(id),
                                            tonumber(n1),
                                            tonumber(n2),
                                            tonumber(area),
                                            material
                                        }
                                    )
                                end

                            ------------------------------------------------
                            -- CONSTRAINTS
                            ------------------------------------------------

                            elseif section == "constraints" then

                                local id, node, direction, value =
                                    line:match(
                                        "^(%d+)%s+(%d+)%s+(%S+)%s+([%-%d%.eE]+)"
                                    )

                                if id then
                                    table.insert(
                                        truss_data.constraints,
                                        {
                                            tonumber(id),
                                            tonumber(node),
                                            direction,
                                            tonumber(value)
                                        }
                                    )
                                end

                            ------------------------------------------------
                            -- LOADS
                            ------------------------------------------------

                            elseif section == "loads" then

                                local id, node, direction, force =
                                    line:match(
                                        "^(%d+)%s+(%d+)%s+(%S+)%s+([%-%d%.eE]+)"
                                    )

                                if id then
                                    table.insert(
                                        truss_data.loads,
                                        {
                                            tonumber(id),
                                            tonumber(node),
                                            direction,
                                            tonumber(force)
                                        }
                                    )
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return truss_data
end

return parse_truss_data