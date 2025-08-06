compatibility = {}

-- should work like drop_attached_node(p) in minetest 0.4.14 builtin falling.lua
function compatibility.drop_attached_node(pos)
    local node_name = core.get_node(pos).name

    core.remove_node(pos)

    for _, item in ipairs(core.get_node_drops(node_name)) do
        core.add_item(pos, item)
    end
end

-- should work like check_attached_node(p, n) in minetest 0.4.14 builtin falling.lua
function compatibility.check_attached_node(pos, node)
    local dir = vector.zero()

    if core.registered_nodes[node.name].paramtype2 == "wallmounted" then
        dir = core.wallmounted_to_dir(node.param2)
    else
        dir.y = -1
    end

    return core.registered_nodes[core.get_node(vector.add(pos, dir)).name].walkable
end