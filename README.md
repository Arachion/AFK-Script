# a couple things to note about this AFK Script

## **IMPORTANT**

- this script requires AutoHotKey v2, it will not function on v1

- despite the GUI, and the backend implying it supports multi account functionality, this script was edited to suit the needs of those with only 1 account. if you wish to add multi account functionality, the code will be at the bottom, ready to be pasted.

- the script needs an account name to function, it can be whatever you like as long as its not the same as another account/blank. This is because the script uses the name of the client (which it renames to the account name) to send commands to. email and password can safely be left blank, theyre not required for this iteration of the script to run (but was a major hassle to remove them and didnt have the time to)

-the script does not currently support AZERTY keyboards but i might work on it if theres a demand for it.

-ive purposefully left this script open sourced as Windows Defender is becoming more aggressive with scripts, especially compiled ones. you should never run a script you dont trust.

- if the script is struggling to click the play button, it could either be sleep timings or coordinates. if its sleep timings its pretty straight forward to edit, look for the "LoopWindows" module and find this snippet;
```AHK
                if (value[11]) {
                    if WinExist("Trove - Error Handler") {
                        WinActivate "Trove - Error Handler"
                        Sleep 200
                        ControlClick "Button2", "Trove - Error Handler"
                    } else {
                        WinActivate "Glyph"
                        if !AwaitActiveWindow("Glyph") {
                            return
                        }
                        Sleep 500  ; <=====**edit this sleep time**, its in milliseconds
                        
                        Click 918, 101 ; <====**coordinates found here** X then Y
                        
                        WinwaitActive("Trove")
                        if !AwaitActiveWindow("Trove") {
                            return
```
to find the correct coordinates, go into your system tray (the arrow in the bottom right of your task bar), right click any running autohotkey program and open "Window Spy", click on the glyph client and note down the coordinates labelled "Client" under the "Mouse Position". Replace them in the script (as seen above). if your glyph client keeps flickering its most likely the sleep timing, if the click is missing its the coordinates.
both of the the places will be marked with ";<========================" in the code.                       
                    
                

## **keybinds and timings**

- for M1 and M2 to properly function you need to rebind them in adventure, __M1 => 3__ and __M2 => 4__.

- if you wish to change auto loot, R, and T hold down times, youll find them marked at the top of the script (within a comment block of equal signs).

- FXDisable will start counting down the moment the script detects trove launches, so it needs ample delay. Generally 15000 milliseconds is more than enough, however if your pc is under strain or just generally slow, you may have to increase it accordingly.

- auto PVP requires an Auto Queue Mod, you can find them on trovesaurus, in the Steam Workshop, or in the "Renewed Trove Tools" app.

-

## **Closing Remarks**

- this script is merely a passion project, if you wish to build on it feel free to do so, no credit required.

-I am by no means a good coder, so feel free to improve upon the script if you'd like.

- if you happen to stumble upon my script and wish for multi account functionality, for those of you who are confident, just paste this block in over the current "LoopWindows" module. if youre not comfortable or dont know how to, feel free to reach out to me on Discord at "Arachion"
```AHK
LoopWindows() {
    try {
        global Settings, windowFirstStartStates, isWaited

        for value in Settings {
            if (value[13])
                continue
                
            if (!WinExist(value[1])) {
                try {
                    PreviouslyActiveWindowTitle := WinGetTitle("A")
                    if !PreviouslyActiveWindowTitle
                        PreviouslyActiveWindowTitle := ""
                } catch {
                    PreviouslyActiveWindowTitle := ""
                }
                
                if windowFirstStartStates.Has(value[1])
                    windowFirstStartStates.Delete(value[1])
                    
                isWaited := 0
                if (value[11]) {
                    if WinExist("Trove - Error Handler") {
                        WinActivate "Trove - Error Handler"
                        Sleep 200
                        ControlClick "Button2", "Trove - Error Handler"
                    } else {
                        WinActivate "Glyph"
                        if !AwaitActiveWindow("Glyph") {
                        }

                        Sleep 100
                        
                        Click 978, 30
                        Sleep 200  
                        Click 962, 148
                        Sleep 1000  
                        
                        WinActivate "Glyph Login"
                        if !AwaitActiveWindow("Glyph Login") {
                            return
                        }
                        Sleep 500  
                        
                        SendText value[2]
                        Sleep 200  
                        ControlSend "{tab}", , "Glyph"
                        Sleep 200  
                        SendText value[3]
                        Sleep 500  
                        Click 331, 425
                        Sleep 1000  
                        
                        WinActivate "Glyph"
                        if !AwaitActiveWindow("Glyph") {
                            return
                        }
                        Sleep 100  
                        
                        Click 918, 101
                        
                        WinwaitActive("Trove")
                        if !AwaitActiveWindow("Trove") {
                            return
                        }
                        
                        try {
                            if WinExist("Trove") {
                                WinSetTitle(value[1])
                                Sleep 1000
                                
                                pid := GetWindowPID(value[1])
                                if pid
                                    ProcessMap[value[1]] := pid
                                
                                if (value[16] != 0) {
                                    x := Integer(value[14])
                                    y := Integer(value[15])
                                    w := Integer(value[16])
                                    h := Integer(value[17])
                                    WinMove(x, y, w, h, value[1])
                                } else {
                                    WinMove(0, 0, 0, 0, value[1])
                                }
                            }
                        }

                        WinActivate(PreviouslyActiveWindowTitle)
                    }
                }
            }
        }
    } catch Error as e {
        if DEBUG_MODE {
            throw Error(e.Message, e.What, e.Extra) 
        }
    }
}
```