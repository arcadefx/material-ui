local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()
local aspectRatio = display.pixelHeight / display.pixelWidth
local portraitWidth, portraitHeight = 320, 480
if topInset > 0 or leftInset > 0 or bottomInset > 0 or rightInset > 0 then
	if aspectRatio > 2.1 then
		portraitWidth, portraitHeight = 360, 693
	end
end

application =
{

	content =
	{
		width = aspectRatio > 1.5 and portraitWidth or math.ceil( portraitHeight / aspectRatio ),
		height = aspectRatio < 1.5 and portraitHeight or math.ceil( portraitWidth * aspectRatio ),
		scale = "letterbox",
		fps = 60,
		
		--[[

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
