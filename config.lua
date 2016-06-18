application =
{

	content =
	{
		--[[--
		width = 750,
		height = 1334,
		--]]-- 

		--[[-- iphone 4s
		width = 640,
		height = 960, 
		--]]--

		--[[-- ipad 2
		width = 768,
		height = 1024, 
		--]]--

		--[[-- iphone 6s
		width = 750,
		height = 1334, 
		--]]--

		--[[-- nvidia shield k1
		width = 1200,
		height = 1920, 
		--]]--

		scale = "letterBox",
		fps = 30,
		
		--[[
		width = 320,
		height = 480, 

		imageSuffix =
		{
			    ["@2x"] = 2,
		},
		--]]
	},

	--[[
	-- Push notifications
	notification =
	{
		iphone =
		{
			types =
			{
				"badge", "sound", "alert", "newsstand"
			}
		}
	},
	--]]    
}
