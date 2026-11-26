

-- [General variables] --------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

--[[ [Notes]
 - default size: 0.07
 - newline has to contain a space inbetween.
 - If you are going to add another variable such as "voice" make sure to add another table on the file "dialog" in the init function.
]]
local dialogData = {
    name = "<newline=2> </newline><size=1><stroke=nil><color=white><pause=0.1><shake>Invisible Man</shake></pause></color></stroke></size>",
    
    voice = {
        "rbxassetid://927635695",
        "rbxassetid://761473114",
        "rbxassetid://927635476",
        "rbxassetid://927636984",
        "rbxassetid://927634408",
        "rbxassetid://927636725"
    },

    bubble = {},

    font = Enum.Font.Creepster,

    dialogs = {

        ["InvisibleMan1"] = {
            "<typewriterFadeFall><size=0.35><font=PatrickHand><color=grey>shhhhh.....</color></font></size></typewriterFadeFall>",
            "<typewriterFadeFall><size=0.35><color=grey>i am the invisible man, don't blow my cover. hehe.....</color></size></typewriterFadeFall>"
        },

        ["InvisibleMan2"] = {
            "<newline=2> </newline><typewriterEnlarge><shake><size=1.3>WOOOOW</size></shake></typewriterEnlarge>",
            "Hey<newline=2> </newline>this is a newline.",
            "<wave>Wavey text</wave> isn't it cool?"
        }
    }
}

return dialogData