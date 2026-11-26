-- Dialog for Gwagwa --

-- [General variables] --------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

--[[ [Notes]
 - default size: 0.07
 - newline has to contain a space inbetween.
]]
dialogData = {
    name = "<newline=2> </newline><scaleSize=2.5><stroke=nil><color=white><pause=0.1><shake>Gwagwa</shake></pause></color></stroke></size>",
    
    voice = {
        "rbxassetid://5665115687"
    },

    bubble = {},

    font = Enum.Font.PatrickHand,

    dialogs = {
        ["Gwagwa1"] = {
            "<typewriterFadeFall><size=0.9>Hello!</size></typewriterFadeFall>",
            "<typewriterFadeFall>My name is </typewriterFadeFall><size=0.8><color=red><shake>Gwagwa</shake></color></size> <typewriterFadeFall>!</typewriterFadeFall>",
            "<wave>OooOOoOoOooOOo<wave>",
            "<typewriterFadeFall><color=red>This text is red</color> isn't it cool?</typewriterFadeFall>"
        },

        ["Gwagwa2"] = {
            "<size=1.8><shake>Rawr!<shake></size>",
            "I am a testing boi :3",
            "So here is a very very very very long text for testing!!!<pause=1><newline=2> </newline></pause><wave>WooooHOOOOOOOO!!!!</wave><pause=1> </pause>fear me <pause=0.4><size=0.9>mortals</size></pause>,<newline=3> </newline>I AM <color=red>GWAGWA</color> <shake>MWAHHAHAHAHAHAHAHAHAA</shake>.</newline>"
        }
    }
}

return dialogData