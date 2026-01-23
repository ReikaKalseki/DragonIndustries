function createBasicLight(name, params)
	return createDerivative(data.raw.lamp["small-lamp"],
	{
		name = name,
		icon = "__core__/graphics/empty.png",
		flags = {"placeable-off-grid", "not-on-map"},
		destructible = false,
		selectable_in_game = false,
		collision_mask = {layers = {}},
		energy_source =
		{
		  type = "void",
		  usage_priority = "lamp"
		},
		darkness_for_all_lamps_on = 0.0001,
		darkness_for_all_lamps_off = 0,
		light = {intensity = params.brightness, size = params.size, color = params.color},
		light_when_colored = {intensity = params.brightness, size = params.size, color = params.color},
		glow_size = 6,
		glow_color_intensity = 0.135,
		picture_off =
		{
		  layers =
		  {
			{
			  filename = "__core__/graphics/empty.png",
			  priority = "high",
			  width = 1,
			  height = 1,
			  frame_count = 1,
			  axially_symmetrical = false,
			  direction_count = 1,
			},
		  }
		},
		picture_on =
		{
			  filename = "__core__/graphics/empty.png",
			  priority = "high",
			  width = 1,
			  height = 1,
			  frame_count = 1,
			  axially_symmetrical = false,
			  direction_count = 1,
		},
		circuit_wire_connection_point = "nil",
		circuit_wire_max_distance = 0
	}
	)
end