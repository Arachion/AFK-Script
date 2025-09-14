# a couple things to note about this AFK Script

## **IMPORTANT**

- these scripts requires AutoHotKey v2, it will not function on v1

- despite the GUI and the backend implying it supports multi account functionality, the stripped ahk was edited to suit the needs of those with only 1 account. if you wish to have multi account functionality, instead refer to the non stripped version

- the script needs an account name to function, it can be whatever you like as long as its not the same as another account/blank. This is because the script uses the name of the client (which it renames to the account name) to send commands to. email and password are safely stored in a local file on your computer called settings.ini, theyre not required for the stripped iteration of the script to run (but was a major hassle to remove them and didnt have the time to)

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

- for M1 and M2 to properly function you need to rebind them in adventure mode, __M1 => 3__ and __M2 => 4__.

- if you wish to change auto loot, R, and T hold down times, youll find them marked at the top of the script (within a comment block of equal signs).

- FXDisable will start counting down the moment the script detects trove launches, so it needs ample delay. Generally 15000 milliseconds is more than enough, however if your pc is under strain or just generally slow, you may have to increase it accordingly.

- auto PVP requires an Auto Queue Mod, you can find them on trovesaurus, in the Steam Workshop, or in the "Renewed Trove Tools" app.

-

## **Closing Remarks**

- this script is merely a passion project, if you wish to build on it feel free to do so, no credit required.

-I am by no means a good coder, so feel free to improve upon the script if you'd like.


```


