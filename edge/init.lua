edge = {}
-- These values can be overridden by other plugins.
edge.negative = -30896
edge.positive = 30911
edge.node = "edge:node"
edge.correction = "edge:cave_correction"

function edge:is(pos)
	if pos.x < self.negative or
	pos.y < self.negative or
	pos.z < self.negative or
	pos.x > self.positive or
	pos.y > self.positive or
	pos.z > self.positive then
		return true
	end
end

function edge:build(minp, maxp, cave_correction)
	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.z, maxp.z do
				local action_pos = {x=x,y=y,z=z}
				local action_node = minetest.get_node(action_pos).name
				if self:is(action_pos) then
					if cave_correction and action_node == "air" then
						minetest.set_node(action_pos, {name=edge.correction})
					elseif not cave_correction and action_node ~= edge.node then
						minetest.set_node(action_pos, {name=edge.node})
					end
				elseif action_node == edge.node or action_node == edge.correction then
					minetest.set_node(action_pos, {name="air"})
				end
			end
		end
	end
end

minetest.register_node("edge:node", {
	description = "Edge Node",
	tiles = {"edge_node.png"},
	groups = {edge=1},
	paramtype = "light",
	drawtype = "glasslike",
	digable = false,
	sunlight_propagates = true,
	pointable = false,
})

minetest.register_node("edge:cave_correction", {
	description = "Edge Node",
	tiles = {"edge_correction.png"},
	groups = {edge=1},
	paramtype = "light",
	drawtype = "glasslike",
	digable = false,
	sunlight_propagates = true,
	pointable = false,
})

-- This ABM repairs the wall after the cave generator rips holes in it.
minetest.register_abm({
	nodenames = {"group:edge"},
	neighbors = {"air"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		edge:build(
			{x=pos.x-1, y=pos.y-1, z=pos.z-1},
			{x=pos.x+1, y=pos.y+1, z=pos.z+1},
		true)
	end,
})

minetest.register_on_generated(function(minp, maxp, blockseed)
	if edge:is(minp) or edge:is(maxp) then
		edge:build(minp, maxp)
	end
end)


