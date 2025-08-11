local item_GUID_by_frame_pos = {}

local facedir = {}
facedir[0] = {x=0 , y=0, z=1 }
facedir[1] = {x=1 , y=0, z=0 }
facedir[2] = {x=0 , y=0, z=-1}
facedir[3] = {x=-1, y=0, z=0 }

local function remove_item(pos)
	local item_GUID = item_GUID_by_frame_pos[vector.to_string(pos)]

	if item_GUID then
		local objref = core.objects_by_guid[item_GUID]

		if objref then
			objref:remove()
			-- object's GUID will be removed from item_GUID_by_frame_pos
			-- in its on_deactivate callback
		end
	end
end

local function create_item(frame_pos, frame_param2, item_name)
	remove_item(frame_pos)

	local pos = table.copy(frame_pos)
	local posad = facedir[frame_param2]

	pos.x = pos.x + posad.x*6.5/16
	pos.y = pos.y + posad.y*6.5/16
	pos.z = pos.z + posad.z*6.5/16

	local yaw = math.pi*2 - frame_param2 * math.pi/2

	local item = core.add_entity(
		pos, "itemframes:item", vector.to_string(frame_pos)..";"..item_name
	)

	if item then
		item:set_pos(pos)
		item:set_yaw(yaw)
	end
end

local function drop_item(pos, frame_meta)
	local itemstack = frame_meta:get_string("item")

	if itemstack then
		core.add_item(pos, itemstack)

		frame_meta:set_string("item", "")
		remove_item(pos)

		return true
	end

	return false
end

-- removes item at pos and creates new one
-- to be sure that right item is displayed
local function resolve_conflict(pos)
	local pos_str = vector.to_string(pos)
	local item_GUID = item_GUID_by_frame_pos[pos_str]
	local objref = core.objects_by_guid[item_GUID]

	if objref and objref:is_valid() then
		objref:remove()
		-- object's GUID will be removed from item_GUID_by_frame_pos
		-- in its on_deactivate callback
	end

	local frame = core.get_node(pos)
	local frame_meta = core.get_meta(pos)
	local item = frame_meta:get_string("item")

	if item then
		create_item(pos, frame.param2, ItemStack(item):get_name())
	end
end

core.register_entity("itemframes:item", {
	hp_max = 1,
	visual="wielditem",
	visual_size={x=.33, y=.33},
	collisionbox = {0,0,0,0,0,0},
	physical=false,
	textures={"air"},
	on_activate = function(self, staticdata)
		local valid = false

		if staticdata then
			local data = staticdata:split(';')

			if data and data[1] and data[2] then
				self.frame_pos_str = data[1]
				self.texture = data[2]

				local frame_pos_vec = vector.from_string(self.frame_pos_str)

				-- we shouldn't load item if there is no frame position
				-- or there is no itemframe at this position
				-- to avoid having items without frames
				if frame_pos_vec and core.get_node(frame_pos_vec).name == "itemframes:frame" then
					-- only add item if frame contains some item
					-- to be sure that item won't be placed in empty frame
					-- in case frame with this item was replaced with empty one
					if core.get_meta(frame_pos_vec):get_string("item") then
						if not item_GUID_by_frame_pos[self.frame_pos_str] then
							item_GUID_by_frame_pos[self.frame_pos_str] = self.object:get_guid()
							valid = true

							self.object:set_properties({textures={self.texture}})
						else
							resolve_conflict(frame_pos_vec)
						end
					end
				end
			end
		end

		if not valid then
			self.object:remove()
		end
	end,
	on_deactivate = function(self, removal)
		item_GUID_by_frame_pos[self.frame_pos_str] = nil
	end,
	get_staticdata = function(self)
		return self.frame_pos_str..";"..self.texture
	end
})

core.register_node("itemframes:frame", {
	description = "Item frame",
	drawtype = "nodebox",
	node_box = {type = "fixed", fixed = {-0.5, -0.5, 7/16, 0.5, 0.5, 0.5}},
	selection_box = {type = "fixed", fixed = {-0.5, -0.5, 7/16, 0.5, 0.5, 0.5}},
	tiles = {"itemframe_background.png"},
	inventory_image = "itemframes_frame.png",
	wield_image = "itemframes_frame.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {choppy=2, dig_immediate=2},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
	on_construct = function(pos)
		-- restore state if frame was moved by some mod (for example by piston).
		-- delayed because on_construct is called just after core:set_node usage,
		-- and core:set_node sets resets metadata, so given metadata will be
		-- avaible only on next step
		core.after(0, function()
			local meta = core.get_meta(pos)

			if meta:contains("item") then
				local node = core.get_node(pos)
	
				create_item(pos, node.param2, meta:get_string("item"))
			end
		end)
	end,
	on_destruct = function(pos)
		-- remove item object or it will be floating if frame was moved by some mod
		remove_item(pos)
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		if clicker and clicker:is_player() and core.is_protected(pos, clicker:get_player_name()) then
			return itemstack
		end

		if not itemstack then
			return
		end

		local meta = core.get_meta(pos)

		drop_item(pos, meta)

		local item = itemstack:take_item()
		meta:set_string("item", item:to_string())
		create_item(pos, node.param2, item:get_name())
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		if not puncher:is_player() or not core.is_protected(pos, puncher:get_player_name()) then
			-- call regular callbacks if there was no item to drop
			if not drop_item(pos, core.get_meta(pos)) then
				core.node_punch(pos, node, puncher, pointed_thing)
			end
		end
	end,
	-- add item to frame's drop to not lose it if it had been placed
	-- in frame while it was being breaked or if frame is dropped
	-- by some mod
	preserve_metadata = function(pos, oldnode, oldmeta, drops)
		remove_item(pos)

		local item = oldmeta.item

		if item then
			drops[#drops+1] = ItemStack(item)
		end
	end
})

core.register_craft({
	output = 'itemframes:frame',
	recipe = {
		{'default:stick', 'default:stick', 'default:stick'},
		{'default:stick', 'default:paper', 'default:stick'},
		{'default:stick', 'default:stick', 'default:stick'}
	}
})
