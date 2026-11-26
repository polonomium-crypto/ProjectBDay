

-- [General variables] --------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

--[[ [Notes]
 - default size: 0.4
 - newline has to contain a space inbetween.
 - If you are going to add another variable such as "voice" make sure to add another table on the file "dialog" in the init function.
 - To push a line to a newline u have to put a space inbetween the tag instead of the sentance.
]]
local dialogData = {
    name = "<newline=2> </newline><shake><scaleSize=2><color=white><stroke=nil>Dummy</stroke></size></color></shake>",
    
    voice = {
        "rbxassetid://927635695",
    },

    bubble = {},

    font = Enum.Font.Antique,

    dialogs = {

        ["Dummy1"] = {
            "<size=0.7><shake>Hello</shake></size>",
            "<shake>Welcome to <pause=0><size=0.9>the</size></pause> testing grounds</shake>",
            "<shake>. . .</shake>",
            "<shake>I am cold</shake>"
        },
    }
}

return dialogData