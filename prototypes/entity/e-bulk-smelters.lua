require("prototypes.constants")

function createEntityRadar(smelter_name, side_length)
	local new_entity = util.table.deepcopy(data.raw.radar.radar)
	new_entity.max_distance_of_nearby_sector_revealed = (side_length / 32) + 1
	new_entity.max_distance_of_sector_revealed = 0
	new_entity.energy_source = {type = "void"}
	new_entity.name = smelter_name .. "-bs-radar"
	new_entity.minable = nil
	new_entity.collision_box = nil
	new_entity.damaged_trigger_effect = nil
	new_entity.flags = {"not-blueprintable", "hidden", "hide-alt-info", "placeable-player"}
	new_entity.integration_patch = nil
	new_entity.selection_box = nil
	new_entity.water_reflection = nil
	new_entity.working_sound = nil
	new_entity.collision_mask = {}
	data:extend({new_entity})
end

function create_entity(e_type)
	local entity
	local r_icon
	local ratio
	-- Hopefully sane defaults for when something goes horribly wrong
	local edge_size = 4
	local scale_factor = 1
	if e_type == "smelter" then
		ratio = settings.startup["smelter-ratio"].value
		--[[
		-- Why are we not updating scale_factor if MAX_BLD_SIZE is a thing?
		if MAX_BLD_SIZE ~= 0 then
			edge_size = MAX_BLD_SIZE/2
		else
			--params: bld size, beacons on one side per bld, compression ratio
			edge_size, scale_factor = getScaleFactors(3, 4, ratio)
		end
		--]]
		edge_size, scale_factor = getScaleFactors(3, 4, ratio, MAX_BLD_SIZE)
		entity = create_smelter(edge_size, ratio, scale_factor)
		r_icon = "__aai-industry__/graphics/icons/industrial-furnace.png"
		
		if settings.startup["smelt-alt-map-color"].value then
			entity.map_color = {143, 143, 143, 255}
		end
	elseif e_type == "centrifuge" then
		ratio = settings.startup["centrifuge-ratio"].value
		--[[
		-- See above comment
		if MAX_BLD_SIZE ~= 0 then
			edge_size = MAX_BLD_SIZE/2
		else
			edge_size, scale_factor = getScaleFactors(3, 4, ratio)
		end
		--]]
		edge_size, scale_factor = getScaleFactors(3, 4, ratio, MAX_BLD_SIZE)
		entity = createCentrifuge(edge_size, ratio, scale_factor)
		r_icon = "__base__/graphics/icons/centrifuge.png"
		
		if settings.startup["smelt-alt-map-color"].value then
			entity.map_color = {128, 255, 89, 255}
		end
	end

	entity.allowed_effects = nil
	entity.icon = nil
	entity.icons = {
		{
			icon = r_icon,
			tint = building_tint,
			icon_size = 64
		}
	}
	entity.name = "bulk-" .. e_type
	entity.localised_name = {"entity-name.bulk-"..e_type}
	entity.localised_description = {"entity-description.bulk-"..e_type}
	local half_edge = edge_size
	entity.collision_box = {
		-- half_edge away from origin, then in by 0.2
		{-1*half_edge + 0.2,-1*half_edge + 0.2},
		{ half_edge - 0.2, half_edge - 0.2}
	}
	entity.selection_box = {
		{ -1*half_edge, -1*half_edge },
		{  half_edge,  half_edge }
	}
	entity.drawing_box = {
		{ -1*half_edge, -1*half_edge },
		{  half_edge,  half_edge }
	}
	entity.minable = {
		mining_time = 0.2,
		result = "bulk-" .. e_type
	}
	entity.module_specification = {
		module_slots = 0,
	}
	-- Why are we making radars? Should just be a simple crafting entity
	--createEntityRadar(entity.name, edge_size)
	data:extend({entity})
end

function getScaleFactors(base_building_side_len, beacons_on_side, bld_count, building_side_len_max)
	-- base_building_side_len is hardcoded to 3 (smelter/centrifuge is 3x3 building)
	-- beacons_on_side is hardcoded to 4 (can fit 4 beacons on each side of building?)
	-- bld_count is our chosen ratio (how many buildings do we want to roll up into this one)
	-- building_side_len_max is our max side length, chosen in settings
	--There is a more efficient way to lay out beacons for non-oil processing recipes,
	-- but I can't be bothered to do the math on it, and it only saves a little bit of space.
	local new_side_length = 3 * (beacons_on_side-1) * math.sqrt(bld_count) + 3
	
	-- Round to integer
	new_side_length = round(new_side_length)
	--if math.floor(new_side_length) + 0.5 > new_side_length then
	--	new_side_length = math.ceil(new_side_length)
	--else
	--	new_side_length = math.floor(new_side_length)
	--end
	
	-- Cap side length at building_side_len_max, from settings
	if building_side_len_max > 0 then
		if new_side_length > building_side_len_max then
			new_side_length = building_side_len_max
		end
	end

	--This is done to ensure we always have a slot in the middle for a pipe.
	if new_side_length % 2 == 0
	then
		new_side_length = new_side_length + 1
	end

	-- Why are we cutting our side in half?
	local result_side_len = new_side_length/2
	
	--you'd think this would use the whole side length to scale, but for whatever reason, Factorio doesn't.
	-- scale = (new length)/(old length)
	local scale_factor = result_side_len / base_building_side_len
	-- Round scale factor to integer
	--scale_factor = round(scale_factor)

	return result_side_len, scale_factor
end

function do_dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. do_dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
function scale_animation(anim, scale_factor, shift_offset_factor)
	-- Scaled sprites still don't expand to the edges like we want, need additional tweaking
	local SCALE_TWEAK = 1.18
	-- Lua's pass by value/ref is confusing, so just make a whole new table to modify and return that
	local animation = table.deepcopy(anim)
	-- Scale standard resolution animation
	if animation.scale then
		animation.scale = animation.scale * scale_factor * SCALE_TWEAK
	else
		animation.scale = scale_factor * SCALE_TWEAK
	end
	-- Don't need an else here, shift defaults to {0,0} and we're multiplying
	if animation.shift then
		animation.shift[1] = animation.shift[1] * scale_factor * SCALE_TWEAK * shift_offset_factor
		animation.shift[2] = animation.shift[2] * scale_factor * SCALE_TWEAK * shift_offset_factor
	end
	animation.animation_speed = 1
	-- High resolution animation exists, scale it
	if animation.hr_version then
		animation.hr_version.scale = animation.hr_version.scale * scale_factor * SCALE_TWEAK
		animation.hr_version.shift[1] = animation.hr_version.shift[1] * scale_factor * SCALE_TWEAK * shift_offset_factor
		animation.hr_version.shift[2] = animation.hr_version.shift[2] * scale_factor * SCALE_TWEAK * shift_offset_factor
		animation.hr_version.animation_speed = 1
	end
	return animation
end

function create_smelter(edge_size, ratio, scale_factor)
	local entity
	
	entity = table.deepcopy(data.raw["assembling-machine"]["industrial-furnace"])
	entity.base_productivity = smelter_productivity_factor
	entity.crafting_speed = smelter_total_speed_bonus
	entity.energy_usage = smelter_total_pwr_draw * ratio .. "kW"
	entity.energy_source.drain = (beacon_pwr_drain * ratio) + (smelter_total_pwr_draw * ratio) / 30 .. "kW"
	entity.energy_source.emissions_per_minute = smelter_base_pollution * (smelter_per_unit_pwr_drain_penalty * (prod_mod_pollution_penalty * smelter_base_modules + 1)) * ratio
	entity.crafting_categories = { "bulksmelting" }
	entity.result_inventory_size = r_output_windows_needed
	-- Delete the fluid_boxes instead of messing around with scaling them. Problem for later.
	entity.fluid_boxes = nil
	--[[
	for _,box in pairs(entity.fluid_boxes) do
		if type(box) == "table" then
		end
	end
	--]]
	--For reasons I don't understand, the offsets need additional padding to scale correctly on top of the building scale itself.
	-- This seems to have resolved on its own or in a base game update
	local OFFSET_SCALING_FACTOR = 1--.95
	entity.scale_entity_info_icon = true
	entity.alert_icon_scale = scale_factor
	-- Animation is table of layers
	-- Use indexes, generic for loop doesn't seem to work
	if entity.animation and entity.animation.layers then
		for i,_ in pairs(entity.animation.layers) do
			entity.animation.layers[i] = scale_animation(entity.animation.layers[i], scale_factor, OFFSET_SCALING_FACTOR)
		end
	-- Animation is single entry
	elseif entity.animation then
		entity.animation = scale_animation(entity.animation, scale_factor, OFFSET_SCALING_FACTOR)
	end
	-- working_visualisations is always a table
	if entity.working_visualisations then
		for i,_ in pairs(entity.working_visualisations) do
			-- Animation is table of layers
			if entity.working_visualisations[i].animation and entity.working_visualisations[i].animation.layers then
				for j,_ in pairs(entity.working_visualisations[i].animation.layers) do
					entity.working_visualisations[i].animation.layers[j] = scale_animation(entity.working_visualisations[i].animation.layers[j], scale_factor, OFFSET_SCALING_FACTOR)
				end
			-- Animation is single entry
			elseif entity.working_visualisations[i].animation then
				entity.working_visualisations[i].animation = scale_animation(entity.working_visualisations[i].animation, scale_factor, OFFSET_SCALING_FACTOR)
			end
		end
	end
	
	local edge_art = {
		filename = "__SmelterUPSGrade-SEFork__/graphics/smelter_border.png",
		frame_count = 1,
		height = 256,
		priority = "high",
		scale = scale_factor * 0.749,
		width = 256,
	}
	
	table.insert(entity.animation.layers, edge_art)
	return entity
end

function createCentrifuge(edge_size, ratio, scale_factor)	
	entity = table.deepcopy(data.raw["assembling-machine"]["centrifuge"])
	entity.base_productivity = centrifuge_productivity_factor
	entity.crafting_speed = centrifuge_total_speed_bonus
	entity.energy_usage = centrifuge_total_pwr_draw * ratio .. "kW"
	entity.energy_source.drain = (beacon_pwr_drain * ratio) + (centrifuge_total_pwr_draw * ratio) / 30 .. "kW"
	entity.energy_source.emissions_per_minute = centrifuge_base_pollution * (centrifuge_per_unit_pwr_drain_penalty * (prod_mod_pollution_penalty * centrifuge_base_modules + 1)) * ratio
	entity.crafting_categories = { "bulkcentrifuging" }
	entity.result_inventory_size = uranium_output_windows_needed
	
	entity.fluid_boxes = nil
	entity.scale_entity_info_icon = true
	entity.alert_icon_scale = scale_factor
	
	for z, _ in pairs(entity.working_visualisations) do
		if entity.working_visualisations[z].animation and entity.working_visualisations[z].animation.layers then
			for i, _ in pairs(entity.working_visualisations[z].animation.layers) do
				entity.working_visualisations[z].animation.layers[i].hr_version.scale = scale_factor
			end
		else
			entity.working_visualisations[z].scale = scale_factor
		end
	end

	for i, _ in pairs(entity.idle_animation.layers) do
		entity.idle_animation.layers[i].hr_version.scale = scale_factor
	end

	local edge_art = {
		filename = "__SmelterUPSGrade-SEFork__/graphics/centrifuge-border.png",
		frame_count = 64,
		line_length = 8,
		height = 256,
		priority = "high",
		scale = scale_factor * 0.749,
		width = 256,
	}
	
	table.insert(entity.working_visualisations[2].animation.layers, edge_art)
	table.insert(entity.idle_animation.layers, edge_art)
	
	return entity
end

function round(num)
	return num + (2^52 + 2^51) - (2^52 + 2^51)
end