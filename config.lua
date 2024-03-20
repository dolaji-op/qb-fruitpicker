Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DEL'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

Config = {}

Config.Object = {
    usingexport = true, --- disable this if you are not using latest qbcore version. Note: Set to false for non qbcore versions.
    CoreName = 'qb-core', --- your core name for export.
    event = "QBCore:GetObject",  -- fill this if you disable usingexport.
}

Config.UseXp = false ---- enabe/disable xp system here
Config.PedModel = 'a_m_m_farmer_01'
Config.UseDrawText = false ---- set to false if you want to use eye target.
Config.RequireJob = false --- enable this if you want to use job only.
Config.JobName = "fruitpicker" --- job name Note: make sure you add job in your server accordingly your framework.
Config.EyeTarget = "ox_target"  --- you can use ox_target or qb-target
Config.Input = "ox-lib" --- ("ox-lib", "qb-input") input script will be used for menus (uncomment line in fxmanifest.lua if you using ox-lib)


Config.MinPay = 200 -- min payment on per orange sell.
Config.MaxPay = 500 -- max payment on per orange sell.

Config.UseTimeout = true ---- set to true if you want to use timeout
Config.Timeout = 60000 --- time in mili seconds

Config.Xp = {
    [1] = {
        xp = 10, ----- if player has 10 xp then
        enabletree = 10, --- enable 10 tree
    },
    [2] = {
        xp = 20,
        enabletree = 20,
    },
    [3] = {
        xp = 30,
        enabletree = 30,
    },
    [4] = {
        xp = 40,
        enabletree = 40,
    },
    [5] = {
        xp = 50,
        enabletree = 52, ----we have total 52 tree
    },

}

Config.Blip = {
    ['main_blip'] = {
        enable = true,
        coords = vector3(286.53317, 6517.6704, 29.973867),
        Sprite = 88,
        Scale = 0.8,
        Color = 25,
        Label = 'Fruit Farm'
    },
    ['selling'] = {
        enable = true,
        coords = vector3(1792.27, 4594.9, 37.68),
        heading = 188.28,
        Sprite = 88,
        Scale = 0.8,
        Color = 25,
        Label = 'Fruit Market'
    }
}

Config.ShopItems = { -- Food Shop
    [1] = {
        name = "fruit_basket", -- Item name
        price = 20, -- Price per item
        amount = 50, -- Stock amount
        info = {},
        type = "item",
        slot = 1, -- Inventory slot item will be displayed
    },
}

InsertValue = function(title, text, name)
    if Config.Input == 'ox-lib' then
		local dialog = lib.inputDialog(title, {
			{type = 'number', label = "How Much?", required = true, min = 1},
		})
		if not dialog then return end
		if tonumber(dialog[1]) > 0 then
			return tonumber(dialog[1])
		end

	else
		local dialog = exports['qb-input']:ShowInput({
            header = title,
            submitText = Language['submit'],
            inputs = {
                {
                    text = text, -- text you want to be displayed as a place holder
                    name = "f", -- name of the input should be unique otherwise it might override
                    type = "number", -- type of the input
                    isRequired = true -- Optional [accepted values: true | false] but will not submit the form if no value is inputted
                },
            },
        })

        if dialog ~= nil then
            for k,v in pairs(dialog) do
                return v
            end
        end
	end
end


AddTargets = function(targettype, v)
    if Config.EyeTarget == 'qb-target' then
        if targettype == 'fruittree' then
            exports['qb-target']:AddCircleZone(v.name, v.coords, 0.50, {
                name = v.name,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = "client",
                        targeticon = 'fas fa-eye',
                        event = "ds-fruitpicker:stealorange",
                        icon = "fas fa-eye",
                        label = "Pluck Orange",
                        coords = v.coords,
                    },
                },
                distance = 1.5,
            })
        elseif targettype == "orange" then
            local props = {
                `orange`,
                `prop_fruit_basket`
            }
            exports['qb-target']:AddTargetModel(props, {
                options = {
                    {
                        type = "client",
                        targeticon = 'fas fa-eye', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
                        event = "ds-fruitpicker:pickupfruit",
                        icon = "fas fa-eye",
                        label = "Pickup Fruit",
                    },
                },
                distance = 2.5,
            })
        elseif targettype == 'store' then
            exports['qb-target']:AddBoxZone('store', v.coords, 0.70, 0.70, {
                name = 'store',
                heading = v.heading,
                debugPoly = false,
                minZ = v.coords.z-0.9,
                maxZ = v.coords.z+0.9,
            }, {
                options = {
                    {
                        type = 'client',
                        event = 'ds-fruitpicker:buystuff',
                        icon = "fas fa-eye",
                        label = "Buy Items",
                    },
                    {
                        type = 'client',
                        event = 'ds-fruitpicker:sellorange',
                        icon = "fas fa-eye",
                        label = "Sell Fruits",
                    },
                },
                distance = 2.5
            })
        end
    elseif Config.EyeTarget == 'ox_target' then
        if targettype == 'fruittree' then
            exports.ox_target:addSphereZone({
                coords = v.coords,
                radius =  0.50,
                debug = false,
                options = {
                    {
                        name = v.name,
                        icon = "fas fa-eye",
						label = "Pluck Orange",
                        items =  false,
                        distance = 2,
                        event = "ds-fruitpicker:stealorange",
                        coords = v.coords,
                    }
                }
            })
        elseif targettype == "orange" then
            local props = {
                `orange`,
                `prop_fruit_basket`
            }
            local options = {
                label = "Pickup Fruit",
                name = "Pickup Fruit",
                icon = "fas fa-eye",
                distance = 2.5,
                event = "ds-fruitpicker:pickupfruit",
            }
            exports.ox_target:addModel(props, options)

        elseif targettype == 'store' then
            exports.ox_target:addBoxZone({
                coords = v.coords,
                size = vec3(0.70, 0.70, 2),
                rotation = v.heading,
                debug = false,
                options = {
                    {
                        name = "Buy Items",
                        event = 'ds-fruitpicker:buystuff',
                        distance = 2,
                        items =  false,
                        icon = "fas fa-eye",
                        label = "Buy Items",
                    },
                    {
                        name = "Sell Fruits",
                        event = 'ds-fruitpicker:sellorange',
                        items =  false,
                        distance = 2,
                        icon = "fas fa-eye",
                        label = "Sell Fruits",
                    },
                }
            })
        end
    end
end


Config.FruitLoc = {
    [1] = vector3(0.14, -0.1, -0.2),
    [2] = vector3(0.05, -0.1, -0.2),
    [3] = vector3(-0.05, -0.1, -0.2),
    [4] = vector3(-0.14, -0.1, -0.2),
    [5] = vector3(0.14, 0.0, -0.2),
    [6] = vector3(0.05, 0.0, -0.2),
    [7] = vector3(-0.05, 0.0, -0.2),
    [8] = vector3(-0.14, 0.0, -0.2),
    [9] = vector3(0.14, 0.1, -0.2),
    [10] = vector3(0.05, 0.1, -0.2),
    [11] = vector3(-0.05, 0.1, -0.2),
    [12] = vector3(-0.14, 0.1, -0.2),
    [13] = vector3(0.11, -0.05, -0.1),
    [14] = vector3(0.0, -0.05, -0.1),
    [15] = vector3(-0.11, -0.05, -0.1),
    [16] = vector3(0.11, 0.05, -0.1),
    [17] = vector3(0.0, 0.05, -0.1),
    [18] = vector3(-0.11, 0.05, -0.1),
    [19] = vector3(0.05, 0.0, -0.02),
    [20] = vector3(-0.05, 0.0, -0.02),
}

Config.Orange = {
    [1] = vector3(185.13238, 6497.99, 31.539455),
    [2] = vector3(194.0624, 6497.30, 31.524589),
    [3] = vector3(201.52914, 6497.20, 31.466943),
    [4] = vector3(210.05311, 6498.20, 31.44882),
    [5] = vector3(220.15812, 6499.40, 31.382362),
    [6] = vector3(227.90, 6501.50, 31.309387),
    [7] = vector3(236.80, 6501.99, 31.199548),
    [8] = vector3(246.75677, 6502.90, 31.050739),
    [9] = vector3(256.13415, 6503.90, 30.866821),
    [10] = vector3(263.88079, 6506.10, 30.679285),
    [11] = vector3(273.42254, 6507.40, 30.415632),
    [12] = vector3(281.97747, 6506.60, 30.132825),
    [13] = vector3(281.30221, 6518.79, 30.161262),
    [14] = vector3(272.4764, 6519.20, 30.441238),
    [15] = vector3(262.33282, 6516.50, 30.713565),
    [16] = vector3(253.57427, 6514.20, 30.922798),
    [17] = vector3(244.71505, 6515.20, 31.088735),
    [18] = vector3(234.40859, 6512.70, 31.236833),
    [19] = vector3(225.80, 6511.70, 31.330038),
    [20] = vector3(218.0, 6510.20, 31.398559),
    [21] = vector3(208.42726, 6509.90, 31.471546),
    [22] = vector3(199.63227, 6508.80, 31.507812),
    [23] = vector3(223.79365, 6523.70, 31.352607),
    [24] = vector3(233.20, 6524.75, 31.251405),
    [25] = vector3(242.91239, 6526.30, 31.111141),
    [26] = vector3(251.8511, 6527.50, 30.959983),
    [27] = vector3(261.48165, 6527.70, 30.739828),
    [28] = vector3(270.42776, 6530.60, 30.502403),
    [29] = vector3(280.35, 6530.90, 30.19606),
    [30] = vector3(321.66946, 6505.50, 29.227972),
    [31] = vector3(330.75, 6505.60, 28.588743),
    [32] = vector3(339.76123, 6505.50, 28.679695),
    [33] = vector3(347.76318, 6505.40, 28.807691),
    [34] = vector3(355.23455, 6504.99, 28.470376),
    [35] = vector3(363.13555, 6505.90, 28.541128),
    [36] = vector3(370.18417, 6505.92, 28.416957),
    [37] = vector3(377.94528, 6505.90, 27.940717),
    [38] = vector3(378.13726, 6517.60, 28.361904),
    [39] = vector3(370.03729, 6517.70, 28.369966),
    [40] = vector3(362.72619, 6517.82, 28.269577),
    [41] = vector3(355.27859, 6517.32, 28.197504),
    [42] = vector3(347.43417, 6517.60, 28.791639),
    [43] = vector3(338.87274, 6517.20, 28.948371),
    [44] = vector3(330.39947, 6517.60, 28.973327),
    [45] = vector3(321.83251, 6517.50, 29.128499),
    [46] = vector3(321.75396, 6531.20, 29.174436),
    [47] = vector3(329.46734, 6530.99, 28.623098),
    [48] = vector3(338.38433, 6531.30, 28.556344),
    [49] = vector3(345.78799, 6531.30, 28.734458),
    [50] = vector3(353.69296, 6530.80, 28.410688),
    [51] = vector3(361.42901, 6531.50, 28.358325),
    [52] = vector3(369.24191, 6531.70, 28.405588),
}
