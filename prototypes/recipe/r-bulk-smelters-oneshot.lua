require("prototypes.constants")

local intermediate_beacon_cnt = math.ceil(BEACON_COUNT * .5)
local scaling_factor = r_ore_in

data:extend{
	{type = "recipe-category", name = "bulksmelting"},
	{type = "recipe-category", name = "bulkcentrifuging"},
	{
		name = "smelter-block",
		localised_name = {"recipe-name.smelter-block"},
        energy_required = 10,
        ingredients = {
			{"beacon", intermediate_beacon_cnt},
			{"speed-module-3", intermediate_beacon_cnt * 2},
			{"productivity-module-3", 2},
			{"electric-furnace", 1},
			{"fast-inserter", 1},
			{"stack-inserter", 1}
        },
        result = "smelter-block",
		enabled = false,
        type = "recipe"
    },
	{
		name = "centrifuge-block",
		localised_name = {"recipe-name.centrifuge-block"},
        energy_required = 10,
        ingredients = {
			{"beacon", intermediate_beacon_cnt},
			{"speed-module-3", intermediate_beacon_cnt * 2},
			{"productivity-module-3", 2},
			{"centrifuge", 1},
			{"stack-inserter",2}
        },
        result = "centrifuge-block",
		enabled = false,
        type = "recipe"
    },
}

function create_entity_recipe(e_type)
	local recipe = {}
	local r_icon
	local ratio
	local block_type
	
	if e_type == "smelter" then
		recipe = table.deepcopy(data.raw.recipe["electric-furnace"])
		r_icon = "__aai-industry__/graphics/icons/industrial-furnace.png"
		ratio = settings.startup["smelter-ratio"].value
		block_type = "smelter-block"
	elseif e_type == "centrifuge" then
		recipe = table.deepcopy(data.raw.recipe["centrifuge"])
		r_icon = "__base__/graphics/icons/centrifuge.png"
		ratio = settings.startup["centrifuge-ratio"].value
		block_type = "centrifuge-block"
	end
	
	--Recipe definitions
	recipe.icon = nil
	recipe.icons = {
		{
			icon = r_icon,
			tint = building_tint,
			icon_mipmaps = 4,
			icon_size = 64,
		}
	}
	-- Remove the normal/expensive bits, just have the one recipe
	if recipe.normal then recipe.normal = nil end
	if recipe.expensive then recipe.expensive = nil end
	recipe.ingredients =
	{
		{block_type, ratio},
		{"beacon", BEACON_COUNT},
		{"speed-module-3", BEACON_COUNT * 2},
		{"logistic-chest-buffer", ratio},
		{"substation", math.ceil(ratio / 6)},
	}
	
	recipe.result = "bulk-" .. e_type
	recipe.name = "bulk-" .. e_type
	recipe.localised_name = {"recipe-name.bulk-"..e_type}
	data:extend({recipe})
end
function scale_recipe(struct)
	local new_recipe = table.deepcopy(struct)
	-- Scale ingredients
	for _,ingredient in pairs(new_recipe.ingredients) do
		-- ingredient is in {name="xxx", amount=00, type="xxx"} format
		if ingredient.name then
			ingredient.amount = ingredient.amount * scaling_factor
		-- ingredient is in {"xxx", 00} format
		else
			ingredient[2] = ingredient[2] * scaling_factor
		end
	end
	-- Scale results
	-- single result in "xxx" format
	if new_recipe.result then
		new_recipe.results = {{name = new_recipe.result, amount = scaling_factor}}
		new_recipe.result = nil
	-- table of results in {name="xxx", amount=00, type="xxx"} format
	elseif new_recipe.results then
		for _,res in pairs(new_recipe.results) do
			res.amount = res.amount * scaling_factor
		end
	end
	return new_recipe
end
function create_smelter_recipe(recipe)
	local bulk_recipe = table.deepcopy(recipe)
	
	if recipe.ingredients then
		bulk_recipe = scale_recipe(recipe)
	end
	if recipe.normal then
		bulk_recipe.normal = scale_recipe(recipe.normal)
	end
	if recipe.expensive then
		bulk_recipe.expensive = scale_recipe(recipe.expensive)
	end
	--bulk_recipe.result_count = total_outputs_ore * MAX_OUTPUT_STACK_SIZE
	bulk_recipe.category = "bulksmelting"
	bulk_recipe.enabled = false
	bulk_recipe.name = "bulk-" .. recipe.name
	
	data:extend({bulk_recipe})
end

function create_steel_recipe(name)
	local recipe = table.deepcopy(data.raw.recipe[name])
	
	recipe.category = "bulksmelting"
	
	recipe.normal.energy_required = recipe.normal.energy_required * ore_batching_factor
	recipe.normal.ingredients = { {"iron-plate", r_ore_in * 5} }
	recipe.normal.result_count = total_outputs_ore * MAX_OUTPUT_STACK_SIZE
	
	recipe.expensive.energy_required = recipe.expensive.energy_required * ore_batching_factor
	recipe.expensive.ingredients = { {"iron-plate", r_ore_in * 5 * 2} }
	recipe.expensive.result_count = total_outputs_ore * MAX_OUTPUT_STACK_SIZE

	recipe.enabled = false
	recipe.name = "bulk-" .. name
	
	data:extend({recipe})
end

function create_uranium_recipe(name)
	local recipe = table.deepcopy(data.raw.recipe[name])

	recipe.category = "bulkcentrifuging"
	if name == "uranium-processing" then
		recipe.energy_required = recipe.energy_required * uranium_batching_factor
		recipe.ingredients = { {"uranium-ore",r_uranium_in} }
		recipe.results = {
			{ amount = r_total_uranium_output, name = "uranium-235", probability = 0.0070000000000000009 },
			{ amount = r_total_uranium_output, name = "uranium-238", probability = 0.99299999999999997	}
		}
	else
		recipe.energy_required = recipe.energy_required * kovarex_batching_factor
		recipe.ingredients = {
			{"uranium-235",r_u235_in},
			{"uranium-238",r_u238_in}
		}
		recipe.results = {
			--simple version, but it blocks output flow
			{amount = r_u235_total_output * MAX_OUTPUT_STACK_SIZE,name = "uranium-235"},
			{amount = r_u238_total_output * MAX_OUTPUT_STACK_SIZE,name = "uranium-238"}
			--Non-blocking version, requires 35 output slots.
		}
	end

	recipe.enabled = false
	recipe.name = "bulk-" .. name
	
	data:extend({recipe})
end

--Add above recipes to whitelist for productivity modules.
for _,recipe in pairs(data.raw["recipe"]) do
--for recipe,ore in pairs({["iron-plate"]="iron-ore",["copper-plate"]="copper-ore",["stone-brick"]="stone"}) do
	if recipe.category and recipe.category == "smelting" then
		table.insert(data.raw.module["productivity-module"].limitation,"bulk-"..recipe.name)
		table.insert(data.raw.module["productivity-module-2"].limitation,"bulk-"..recipe.name)
		table.insert(data.raw.module["productivity-module-3"].limitation,"bulk-"..recipe.name)
		create_smelter_recipe(recipe)
	end
end
--[[
table.insert(data.raw.module["productivity-module"].limitation,"bulk-steel-plate")
table.insert(data.raw.module["productivity-module-2"].limitation,"bulk-steel-plate")
table.insert(data.raw.module["productivity-module-3"].limitation,"bulk-steel-plate")
create_steel_recipe("steel-plate")
--]]
for _,recipe in pairs({"uranium-processing","kovarex-enrichment-process"}) do
	table.insert(data.raw.module["productivity-module"].limitation,"bulk-"..recipe)
	table.insert(data.raw.module["productivity-module-2"].limitation,"bulk-"..recipe)
	table.insert(data.raw.module["productivity-module-3"].limitation,"bulk-"..recipe)
	create_uranium_recipe(recipe, "centrifuging")
end