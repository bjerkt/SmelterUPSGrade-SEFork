local SMELTER_HR = {}
function SMELTER_HR.make_smelter(entity)
  local new_smelter = table.deepcopy(entity)
  new_smelter.name = "bulk-smelter-hr"
  new_smelter.animation = {
        layers =
        {
          {
            filename = "__aai-industry__/graphics/entity/industrial-furnace/hr/industrial-furnace.png",
            priority = "high",
            width = 350,
            height = 370,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(0, -5),
            animation_speed = 0.75,
            scale = 0.5,
            hr_version = {
              filename = "__SmelterUPSGrade-SEFork__/graphics/entity/industrial-furnace/uhr/industrial-furnace.png",
              priority = "high",
              width = 350*4,
              height = 370*4,
              frame_count = 1,
              line_length = 1,
              shift = util.by_pixel(0, -5),
              animation_speed = 0.75,
              scale = 0.5/4,
            }
          },
          {
            draw_as_shadow = true,
            filename = "__aai-industry__/graphics/entity/industrial-furnace/hr/industrial-furnace-shadow.png",
            priority = "high",
            width = 370,
            height = 268,
            frame_count = 1,
            line_length = 1,
            shift = util.by_pixel(40, 21),
            animation_speed = 0.75,
            scale = 0.5,
            hr_version = {
              draw_as_shadow = true,
              filename = "__SmelterUPSGrade-SEFork__/graphics/entity/industrial-furnace/uhr/industrial-furnace-shadow.png",
              priority = "high",
              width = 370*4,
              height = 268*4,
              frame_count = 1,
              line_length = 1,
              shift = util.by_pixel(40, 21),
              animation_speed = 0.75,
              scale = 0.5/4,
            }
          },
        },
  }
  new_smelter.working_visualisations = {
        {
          animation = {
            layers = { -- these are not lights, they need to cover the static propeller
              {
                animation_speed = 0.5,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/hr/industrial-furnace-propeller.png",
                frame_count = 4,
                height = 25,
                hr_version = {
                  animation_speed = 0.5,
                  filename = "__SmelterUPSGrade-SEFork__/graphics/entity/industrial-furnace/uhr/industrial-furnace-propeller.png",
                  frame_count = 4,
                  height = 25*4,
                  priority = "high",
                  scale = 0.5/4,
                  shift = util.by_pixel(-1, -64-11),
                  width = 38*4
                },
                priority = "high",
                shift = util.by_pixel(-1, -64-11),
                width = 38,
                scale = 0.5
              },
              {
                animation_speed = 0.5,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/hr/industrial-furnace-propeller.png",
                frame_count = 4,
                height = 25,
                hr_version = {
                  animation_speed = 0.5,
                  filename = "__SmelterUPSGrade-SEFork__/graphics/entity/industrial-furnace/uhr/industrial-furnace-propeller.png",
                  frame_count = 4,
                  height = 25*4,
                  priority = "high",
                  scale = 0.5/4,
                  shift = util.by_pixel(-0.5, -32-8),
                  width = 37*4
                },
                priority = "high",
                shift = util.by_pixel(-0.5, -32-8),
                width = 38,
                scale = 0.5
              },
              {
                animation_speed = 0.5,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/Hr/industrial-furnace-propeller.png",
                frame_count = 4,
                height = 25,
                hr_version = {
                  animation_speed = 0.5,
                  filename = "__SmelterUPSGrade-SEFork__/graphics/entity/industrial-furnace/uhr/industrial-furnace-propeller.png",
                  frame_count = 4,
                  height = 25*4,
                  priority = "high",
                  scale = 0.5/4,
                  shift = util.by_pixel(0, -6),
                  width = 37*4
                },
                priority = "high",
                shift = util.by_pixel(0, -6),
                width = 38,
                scale = 0.5
              },
            }
          }
        },
        {
          draw_as_light = true,
          fadeout = true,
          animation = {
            layers = {
              {
                animation_speed = 0.5,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/hr/industrial-furnace-heater.png",
                frame_count = 12,
                height = 56,
                hr_version = {
                  animation_speed = 0.5,
                  filename = "__SmelterUPSGrade-SEFork__/graphics/entity/industrial-furnace/uhr/industrial-furnace-heater.png",
                  frame_count = 12,
                  height = 56*4,
                  priority = "high",
                  scale = 0.5/4,
                  shift = util.by_pixel(0, 65),
                  width = 60*4
                },
                priority = "high",
                shift = util.by_pixel(0, 65),
                width = 60,
                scale = 0.5
              },
            }
          }
        },
        {
          draw_as_light = true,
          fadeout = true,
          animation = {
            layers = {
              {
                filename = "__aai-industry__/graphics/entity/industrial-furnace/Hr/industrial-furnace-light.png",
                priority = "high",
                width = 350,
                height = 370,
                frame_count = 1,
                line_length = 1,
                shift = util.by_pixel(0, -5),
                animation_speed = 0.75,
                blend_mode = "additive",
                hr_version = {
                  filename = "__SmelterUPSGrade-SEFork__/graphics/entity/industrial-furnace/uhr/industrial-furnace-light.png",
                  priority = "high",
                  width = 350*4,
                  height = 370*4,
                  frame_count = 1,
                  line_length = 1,
                  shift = util.by_pixel(0, -5),
                  animation_speed = 0.75,
                  scale = 0.5/4,
                  blend_mode = "additive",
                },
                scale = 0.5
              },
              {
                animation_speed = 0.5,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/hr/industrial-furnace-vents.png",
                frame_count = 1,
                width = 46,
                height = 66,
                hr_version = {
                  animation_speed = 0.5,
                  filename = "__SmelterUPSGrade-SEFork__/graphics/entity/industrial-furnace/uhr/industrial-furnace-vents.png",
                  frame_count = 1,
                  width = 46*4,
                  height = 66*4,
                  priority = "high",
                  scale = 0.5/4,
                  shift = util.by_pixel(-32-16-5, -32-16+4),
                  blend_mode = "additive",
                },
                priority = "high",
                shift = util.by_pixel(-32-16-5, -32-16+4),
                blend_mode = "additive",
                scale = 0.5
              },
            }
          }
        },
        {
          draw_as_light = true,
          fadeout = true,
          animation = {
            layers = {
              {
                animation_speed = 0.5,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/hr/industrial-furnace-propeller.png",
                frame_count = 4,
                height = 25,
                hr_version = {
                  animation_speed = 0.5,
                  filename = "__SmelterUPSGrade-SEFork__/graphics/entity/industrial-furnace/uhr/industrial-furnace-propeller.png",
                  frame_count = 4,
                  height = 25*4,
                  priority = "high",
                  scale = 0.5/4,
                  shift = util.by_pixel(-1, -64-11),
                  width = 38*4
                },
                priority = "high",
                shift = util.by_pixel(-1, -64-11),
                width = 38,
                scale = 0.5
              },
              {
                animation_speed = 0.5,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/hr/industrial-furnace-propeller.png",
                frame_count = 4,
                height = 25,
                hr_version = {
                  animation_speed = 0.5,
                  filename = "__SmelterUPSGrade-SEFork__/graphics/entity/industrial-furnace/uhr/industrial-furnace-propeller.png",
                  frame_count = 4,
                  height = 25*4,
                  priority = "high",
                  scale = 0.5/4,
                  shift = util.by_pixel(-0.5, -32-8),
                  width = 37*4
                },
                priority = "high",
                shift = util.by_pixel(-0.5, -32-8),
                width = 37,
                scale = 0.5
              },
              {
                animation_speed = 0.5,
                filename = "__aai-industry__/graphics/entity/industrial-furnace/hr/industrial-furnace-propeller.png",
                frame_count = 4,
                height = 25,
                hr_version = {
                  animation_speed = 0.5,
                  filename = "__SmelterUPSGrade-SEFork__/graphics/entity/industrial-furnace/uhr/industrial-furnace-propeller.png",
                  frame_count = 4,
                  height = 25*4,
                  priority = "high",
                  scale = 0.5/4,
                  shift = util.by_pixel(0, -6),
                  width = 37*4
                },
                priority = "high",
                shift = util.by_pixel(0, -6),
                width = 37,
                scale = 0.5
              },
            }
          }
        },
        {
          draw_as_light = true,
          draw_as_sprite = false,
          fadeout = true,
          animation =
          {
            filename = "__aai-industry__/graphics/entity/industrial-furnace/hr/industrial-furnace-ground-light.png",
            blend_mode = "additive",
            width = 166,
            height = 124,
            shift = util.by_pixel(3, 69+32),
            hr_version =
            {
              filename = "__SmelterUPSGrade-SEFork__/graphics/entity/industrial-furnace/uhr/industrial-furnace-ground-light.png",
              blend_mode = "additive",
              width = 166*4,
              height = 124*4,
              shift = util.by_pixel(3, 69+32),
              scale = 0.5/4,
            },
            scale = 0.5
          },
        },
        {
          effect = "uranium-glow", -- changes alpha based on energy source light intensity
          light = {intensity = 0.1, size = 18, shift = {0.0, 1}, color = {r = 1, g = 0.4, b = 0.1}}
        },
  }
  return new_smelter
end
return SMELTER_HR