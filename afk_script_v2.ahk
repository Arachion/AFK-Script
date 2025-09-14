#Requires AutoHotkey v2.0

DEBUG_MODE := false ; set to true for debugging
OnError(DEBUG_MODE ? "" : (*) => False)  
SetWorkingDir A_ScriptDir
;==========These are flexible timings, changing them here will change them throughout the script.==========
Global AutoLootHoldTime := 2000 
Global AutoRHoldTime := 5000     
Global AutoTHoldTime := 300 
global sleeptime := 1000 ; time between each loop, minimum 500ms recommended
;==========================================================================================================
Settings := LoadSettings()
FailSafe := true
Global AccountPIDs := Map() 
Global AccountName := "can be anything except blank"
Global AccountEmail := ""
Global AccountPassword := ""
Global AutoM1 := 0
Global AutoM2 := 0
Global AutoSpecial1 := 0
Global AutoSpecial2 := 0
Global AutoRButton := 0
Global AutoTButton := 0
Global AutoLoot := 0
Global AutoReconnect := 0
Global OneTimeActDelayed := 15000
Global AutoPvP := 0
Global FXDisable := 0
Global DisableAccount := 0
Global winX := 0
Global winY := 0
Global winW := 0
Global winH := 0
Global maxAccounts := 10
Global UserTableRowBeingEdited := 0
Global LV := "" 
Global MainGui := ""
Global keyMap := Map(
    "1", 0x31, "2", 0x32, "3", 0x33, "4", 0x34,
    "r", 0x52, "t", 0x54, "e", 0x45, "b", 0x42,
    "Enter", 0x0D, "LCtrl", 0x11,
    "BomberRoyale", ["LCtrl", "b"]
)

windowFirstStartStates := Map()
ProcessMap := Map() 
isWaited := 0

SetTimer MainLoop, 2000
Return

MainLoop() {
    try {
        if(!FailSafe) {
            LoopSettings()
            LoopWindows()
        }
    } catch Error as e {
        if DEBUG_MODE {
            throw Error(e.Message, e.What, e.Extra)  
        }
    }
}

LoopSettings() {
    global Settings, windowFirstStartStates, isWaited
    global minSleepTime, AutoRHoldTime, AutoTHoldTime, AutoLootHoldTime

    ; 1) Mark loop start
    startTime := A_TickCount

    activeWindows := []
    for value in Settings {
        if (value[13])
            continue
        if (WinExist(value[1]))
            activeWindows.Push(value)
    }

    if (activeWindows.Length > 0) {
        maxEnabledCount := 0
        accountWithMostActions := 0

        for index, value in activeWindows {
            enabledCount := value[4] + value[5] + value[6] + value[7] + value[8] + value[9] + value[10]
            if (enabledCount > maxEnabledCount) {
                maxEnabledCount := enabledCount
                accountWithMostActions := index
            }
        }

        if (accountWithMostActions > 0) {
            mainAccount := activeWindows[accountWithMostActions]
            totalTime := 0

            if (mainAccount[4])  totalTime := Max(totalTime, 200)
            if (mainAccount[5])  totalTime := Max(totalTime, 200)
            if (mainAccount[6])  totalTime := Max(totalTime, 200)
            if (mainAccount[7])  totalTime := Max(totalTime, 300)
            if (mainAccount[8])  totalTime := Max(totalTime, AutoRHoldTime)
            if (mainAccount[9])  totalTime := Max(totalTime, AutoTHoldTime)
            if (mainAccount[10]) totalTime := Max(totalTime, AutoLootHoldTime)

            minsleeptime := 3000
            ; Auto M1
            if(mainAccount[4]) {
                for value in activeWindows {
                    if(value[4])
                        SendKeyToWindowReverse("3", value[1])
                }
            }
            
            ; Auto M2
            if(mainAccount[5]) {
                for value in activeWindows {
                    if(value[5])
                        SendKeyToWindow("4", value[1])
                }
            }
            
            ; Auto Special 1
            if(mainAccount[6]) {
                for value in activeWindows {
                    if(value[6])
                        SendKeyToWindow("1", value[1])
                }
            }
            
            ; Auto Special 2
            if(mainAccount[7]) {
                for value in activeWindows {
                    if(value[7])
                        SendKeyToWindow("2", value[1])
                }
            }
            
            ; Auto press R
            if(mainAccount[8]) {
                for value in activeWindows {
                    if(value[8])
                        SendKeyToWindow("r", value[1], AutoRHoldTime)
                }
            }
            
            ; Auto press T
            if(mainAccount[9]) {
                for value in activeWindows {
                    if(value[9])
                        SendKeyToWindow("t", value[1], AutoTHoldTime)
                }
            }
            
            ; Auto Loot
            if(mainAccount[10]) {
                for value in activeWindows {
                    if(value[10])
                        SendKeyToWindow("e", value[1], AutoLootHoldTime)
                }
            }

            
            for value in activeWindows {
                if (!windowFirstStartStates.Has(value[1])) {
                    if (value[18]) {
                        if (!isWaited) {
                            Sleep Integer(value[19])
                            isWaited := 1
                        }
                        SendCompoundKeys(keyMap["BomberRoyale"], value[1], 300)
                    }
                    if (value[12]) {
                        if (!isWaited) {
                            Sleep Integer(value[19])
                            isWaited := 1

                        }
                        Sleep 100
                        SendKeyToWindow("Enter", value[1])
                        Sleep 200
                        ControlSendText "/drawdistance 0",, value[1]
                        Sleep 200
                        SendKeyToWindow("Enter", value[1])
                        Sleep 600
                        SendKeyToWindow("Enter", value[1])
                        Sleep 100
                        ControlSendText "/fxenable 0",, value[1]
                        Sleep 200
                        SendKeyToWindow("Enter", value[1])
                        Sleep 600
                        SendKeyToWindow("Enter", value[1])
                        Sleep 200
                        ControlSendText "/objdistance 0",, value[1]
                        Sleep 200
                        SendKeyToWindow("Enter", value[1])
                        Sleep 200
                    }
                    windowFirstStartStates[value[1]] := 1
                }
            }
            
            
            
        }
    }

elapsed   := A_TickCount - startTime
remaining := minSleepTime - elapsed

if (remaining > 0) {
    Sleep(remaining)
} else {
    sleep(sleeptime) 
}
}

GetWindowPID(windowTitle) {
    if WinExist(windowTitle)
        return WinGetPID(windowTitle)
    return 0
}

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

StopTask(thisButton, *) {
    global FailSafe
    FailSafe := !FailSafe
    thisButton.Text := FailSafe ? "Start" : "Stop"
}

F1:: {  ; Toggle the main GUI window
    static mainGuiInstance := ""  
    
    if WinExist("Main window") {
        if mainGuiInstance {  
            mainGuiInstance.Show()  
            WinActivate "Main window"
        }
        return
    }
    
    global Settings, LV
    mainGuiInstance := Gui(, "Main window")
    mainGuiInstance.OnEvent("Close", (*) => (mainGuiInstance := "", MainGui := ""))  
    
    mainGuiInstance.Add("Button", "x10 y10 w100 h30", "Add account")
        .OnEvent("Click", AddToAccountList)
    
    stopButton := mainGuiInstance.Add("Button", "x120 y10 w100 h30", FailSafe ? "Start" : "Stop")
    stopButton.OnEvent("Click", StopTask)
    
    LV := mainGuiInstance.Add("ListView", "x10 y50 w1200 h300 NoSort R8", [
        "Name", "Email", "Password",
        "AutoM1", "AutoM2", 
        "AutoSpecial1", "AutoSpecial2",
        "UsesFlaskR", "UsesFlaskT",
        "AutoLoot", "AutoLogin",
        "FXDisable", "Disabled",
        "winX", "winY", "winW", "winH",
        "AutoPvP", "OneTimeActDelayed"
    ])
    LV.OnEvent("DoubleClick", ListViewInteract)
    
    if Settings && Settings.Length > 0 {
        for i, value in Settings {
            if value.Length >= 19
                LV.Add(, value*)
        }
    }
    
    LV.ModifyCol(1, "AutoHdr")
    LV.ModifyCol(2, "AutoHdr")
    LV.ModifyCol(3, "AutoHdr")
    
    mainGuiInstance.Show()
    MainGui := mainGuiInstance 
}

AddToAccountList(*) {
    UserEditor := Gui(, "User Editor")
    
    ; Left Column 
    UserEditor.Add("GroupBox", "x10 y10 w220 h320", "Account Settings")
    UserEditor.Add("Text", "x20 y30", "Account Name:")
    UserEditor.Add("Edit", "x20 y50 w200 h20 vAccountName -VScroll")
    UserEditor.Add("Text", "x20 y80", "Email:")
    UserEditor.Add("Edit", "x20 y100 w200 h20 vAccountEmail -VScroll")
    UserEditor.Add("Text", "x20 y130", "Password:")
    UserEditor.Add("Edit", "x20 y150 w200 h20 vAccountPassword -VScroll")
    UserEditor.Add("Text", "x20 y180", "Window Position")
    UserEditor.Add("Text", "x20 y200", "X:")
    UserEditor.Add("Edit", "x35 y200 w40 h20 vwinX -VScroll", "0")
    UserEditor.Add("Text", "x85 y200", "Y:")
    UserEditor.Add("Edit", "x100 y200 w40 h20 vwinY -VScroll", "0")
    UserEditor.Add("Text", "x150 y200", "W:")
    UserEditor.Add("Edit", "x165 y200 w40 h20 vwinW -VScroll", "800")
    UserEditor.Add("Text", "x20 y230", "H:")
    UserEditor.Add("Edit", "x35 y230 w40 h20 vwinH -VScroll", "600")
    usereditor.Add("Text", "x20 y255", "M1 needs to be rebound to 3, and M2 to 4")
    usereditor.Add("Text", "x20 y270", "FXDisable recommended delay 15000ms+")
    usereditor.Add("Text", "x20 y285", "auto PVP requires an auto queue mod")
    usereditor.Add("Text", "x20 y300", "leave email and password blank (name req)")
    ; Right Column - Auto Actions section
    UserEditor.Add("GroupBox", "x240 y10 w220 h320", "Automation Settings")
    UserEditor.Add("GroupBox", "x250 y30 w200 h200", "Auto Actions")  
    UserEditor.Add("CheckBox", "x260 y50 vAutoM1", "Auto M1")
    UserEditor.Add("CheckBox", "x260 y70 vAutoM2", "Auto M2")
    UserEditor.Add("CheckBox", "x260 y90 vAutoSpecial1", "Auto Special 1")
    UserEditor.Add("CheckBox", "x260 y110 vAutoSpecial2", "Auto Special 2")
    UserEditor.Add("CheckBox", "x260 y130 vAutoRButton", "Auto press R")
    UserEditor.Add("CheckBox", "x260 y150 vAutoTButton", "Auto press T")
    UserEditor.Add("CheckBox", "x260 y170 vAutoLoot", "Auto Loot")
    UserEditor.Add("CheckBox", "x260 y190 vAutoReconnect", "Auto Reconnect")
    UserEditor.Add("CheckBox", "x260 y210 vDisableAccount", "Disable Account")
    
    ; Right Column - One Time Actions section
    UserEditor.Add("GroupBox", "x250 y240 w200 h80", "One Time Actions")  
    UserEditor.Add("CheckBox", "x260 y260 vAutoPvP", "Auto start PvP")
    UserEditor.Add("CheckBox", "x260 y280 vFXDisable", "FX Disable")
    UserEditor.Add("Text", "x260 y300", "Delay:")
    UserEditor.Add("Edit", "x300 y298 w60 h20 vOneTimeActDelayed Number", "15000")
    UserEditor.Add("Text", "x365 y300", "ms")
    
    ; Bottom Buttons 
    button := UserEditor.Add("Button", "x45 y320 w150 h30", "Add")
    button.OnEvent("Click", (*) => HandleAddUser(UserEditor))
    
    UserEditor.Show()
}

HandleAddUser(UserEditor) {  
    global Settings, LV
    savedValues := UserEditor.Submit()  
    
    newEntry := [
        savedValues.AccountName,
        savedValues.AccountEmail,
        savedValues.AccountPassword,
        savedValues.AutoM1 ? 1 : 0,
        savedValues.AutoM2 ? 1 : 0,
        savedValues.AutoSpecial1 ? 1 : 0,
        savedValues.AutoSpecial2 ? 1 : 0,
        savedValues.AutoRButton ? 1 : 0,
        savedValues.AutoTButton ? 1 : 0,
        savedValues.AutoLoot ? 1 : 0,
        savedValues.AutoReconnect ? 1 : 0,
        savedValues.FXDisable ? 1 : 0,
        savedValues.DisableAccount ? 1 : 0,
        savedValues.winX,
        savedValues.winY,
        savedValues.winW,
        savedValues.winH,
        savedValues.AutoPvP ? 1 : 0,
        savedValues.OneTimeActDelayed = "" ? 15000 : savedValues.OneTimeActDelayed
    ]

    LV.Add(, newEntry*)
    Settings.Push(newEntry)
    
    LV.ModifyCol(1, "AutoHdr")
    LV.ModifyCol(2, "AutoHdr")
    LV.ModifyCol(3, "AutoHdr")
    
    SaveSettings(Settings)
    UserEditor.Destroy()
}

RemoveFromAccountList() {
    UserEditor := Gui(, "User Editor")
    UserEditor.Submit()
    UserEditor.Destroy()
    global LV  
    LV.Delete(UserTableRowBeingEdited)
    LV.ModifyCol(1)
    LV.ModifyCol(2)
    LV.ModifyCol(3)
    Settings := []
    Loop LV.GetCount() {
        AccountName := LV.GetText(A_Index, 1)
        AccountEmail := LV.GetText(A_Index, 2)
        AccountPassword := LV.GetText(A_Index, 3)
        AutoM1 := LV.GetText(A_Index, 4)
        AutoM2 := LV.GetText(A_Index, 5)
        AutoSpecial1 := LV.GetText(A_Index, 6)
        AutoSpecial2 := LV.GetText(A_Index, 7)
        AutoRButton := LV.GetText(A_Index, 8)
        AutoTButton := LV.GetText(A_Index, 9)
        AutoLoot := LV.GetText(A_Index, 10)
        AutoReconnect := LV.GetText(A_Index, 11)
        FXDisable := LV.GetText(A_Index, 12)
        DisableAccount := LV.GetText(A_Index, 13)
        winX := LV.GetText(A_Index, 14)
        winY := LV.GetText(A_Index, 15)
        winW := LV.GetText(A_Index, 16)
        winH := LV.GetText(A_Index, 17)
        AutoPvP := LV.GetText(A_Index, 18)
        OneTimeActDelayed := LV.GetText(A_Index, 19)
        Settings.Push([AccountName, AccountEmail, AccountPassword, AutoM1, AutoM2, AutoSpecial1, AutoSpecial2, AutoRButton, AutoTButton, AutoLoot, AutoReconnect, FXDisable, DisableAccount, winX, winY, winW, winH, AutoPvP, OneTimeActDelayed])
    }
    SaveSettings(Settings)
}

ListViewInteract(LV, RowNumber) {
    global UserTableRowBeingEdited, Settings
    if (RowNumber < 1) 
        return
    
    UserTableRowBeingEdited := RowNumber
    
    rowData := []
    Loop 19 {
        val := LV.GetText(RowNumber, A_Index)
        if (A_Index >= 4 && A_Index <= 13) || (A_Index = 18)
            val := val = "1" ? 1 : 0
        rowData.Push(val)
    }
    
    UserEditor := Gui(, "User Editor")
    
    ; Left Column 
    UserEditor.Add("GroupBox", "x10 y10 w220 h320", "Account Settings")
    UserEditor.Add("Text", "x20 y30", "Account Name:")
    UserEditor.Add("Edit", "x20 y50 w200 h20 vAccountName -VScroll", rowData[1])
    UserEditor.Add("Text", "x20 y80", "Email:")
    UserEditor.Add("Edit", "x20 y100 w200 h20 vAccountEmail -VScroll", rowData[2])
    UserEditor.Add("Text", "x20 y130", "Password:")
    UserEditor.Add("Edit", "x20 y150 w200 h20 vAccountPassword -VScroll", rowData[3])
    UserEditor.Add("Text", "x20 y180", "Window Position")
    UserEditor.Add("Text", "x20 y200", "X:")
    UserEditor.Add("Edit", "x35 y200 w40 h20 vwinX -VScroll", rowData[14])
    UserEditor.Add("Text", "x85 y200", "Y:")
    UserEditor.Add("Edit", "x100 y200 w40 h20 vwinY -VScroll", rowData[15])
    UserEditor.Add("Text", "x150 y200", "W:")
    UserEditor.Add("Edit", "x165 y200 w40 h20 vwinW -VScroll", rowData[16])
    UserEditor.Add("Text", "x20 y230", "H:")
    UserEditor.Add("Edit", "x35 y230 w40 h20 vwinH -VScroll", rowData[17])
    usereditor.Add("Text", "x20 y255", "M1 needs to be rebound to 3, and M2 to 4")
    usereditor.Add("Text", "x20 y270", "FXDisable recommended delay 15000ms+")
    usereditor.Add("Text", "x20 y285", "auto PVP requires an auto queue mod")
    usereditor.Add("Text", "x20 y300", "leave email and password blank (name req)")
    
    ; Right Column - auto actions
    UserEditor.Add("GroupBox", "x240 y10 w220 h320", "Automation Settings")
    UserEditor.Add("GroupBox", "x250 y30 w200 h200", "Auto Actions")  
    UserEditor.Add("CheckBox", "x260 y50 vAutoM1", "Auto M1").Value := rowData[4]
    UserEditor.Add("CheckBox", "x260 y70 vAutoM2", "Auto M2").Value := rowData[5]
    UserEditor.Add("CheckBox", "x260 y90 vAutoSpecial1", "Auto Special 1").Value := rowData[6]
    UserEditor.Add("CheckBox", "x260 y110 vAutoSpecial2", "Auto Special 2").Value := rowData[7]
    UserEditor.Add("CheckBox", "x260 y130 vAutoRButton", "Auto press R").Value := rowData[8]
    UserEditor.Add("CheckBox", "x260 y150 vAutoTButton", "Auto press T").Value := rowData[9]
    UserEditor.Add("CheckBox", "x260 y170 vAutoLoot", "Auto Loot").Value := rowData[10]
    UserEditor.Add("CheckBox", "x260 y190 vAutoReconnect", "Auto Reconnect").Value := rowData[11]
    UserEditor.Add("CheckBox", "x260 y210 vDisableAccount", "Disable Account").Value := rowData[13]
    
    ; Right Column - one time actions
    UserEditor.Add("GroupBox", "x250 y240 w200 h80", "One Time Actions")  
    UserEditor.Add("CheckBox", "x260 y260 vAutoPvP", "Auto start PvP").Value := rowData[18]
    UserEditor.Add("CheckBox", "x260 y280 vFXDisable", "FX Disable").Value := rowData[12]
    UserEditor.Add("Text", "x260 y300", "Delay:")
    UserEditor.Add("Edit", "x300 y298 w60 h20 vOneTimeActDelayed Number", rowData[19])
    UserEditor.Add("Text", "x365 y300", "ms")
    
    ; Bottom Buttons 
    buttonSave := UserEditor.Add("Button", "x45 y320 w150 h30", "Save")
    buttonSave.OnEvent("Click", ButtonSaveHandler)
    
    buttonRemove := UserEditor.Add("Button", "x275 y320 w150 h30", "Remove")
    buttonRemove.OnEvent("Click", RemoveHandler)
    
    UserEditor.Show()
}

ButtonSaveHandler(*) {
    ButtonSave()
    gui := GuiFromHwnd(WinExist("User Editor"))
    if gui
        gui.Destroy()
}

RemoveHandler(*) {
    RemoveFromAccountList()
    gui := GuiFromHwnd(WinExist("User Editor"))
    if gui
        gui.Destroy()
}

ButtonSave() {
    global Settings, LV, UserTableRowBeingEdited
    userEditorGui := ""
    try {
        userEditorGui := GuiFromHwnd(WinExist("User Editor"))
        if !userEditorGui {
            return
        }
    }

    savedValues := Map(
        "AccountName", userEditorGui["AccountName"].Value,
        "AccountEmail", userEditorGui["AccountEmail"].Value,
        "AccountPassword", userEditorGui["AccountPassword"].Value,
        "AutoM1", userEditorGui["AutoM1"].Value,
        "AutoM2", userEditorGui["AutoM2"].Value,
        "AutoSpecial1", userEditorGui["AutoSpecial1"].Value,
        "AutoSpecial2", userEditorGui["AutoSpecial2"].Value,
        "AutoRButton", userEditorGui["AutoRButton"].Value,
        "AutoTButton", userEditorGui["AutoTButton"].Value,
        "AutoLoot", userEditorGui["AutoLoot"].Value,
        "AutoReconnect", userEditorGui["AutoReconnect"].Value,
        "FXDisable", userEditorGui["FXDisable"].Value,
        "DisableAccount", userEditorGui["DisableAccount"].Value,
        "winX", userEditorGui["winX"].Value,
        "winY", userEditorGui["winY"].Value,
        "winW", userEditorGui["winW"].Value,
        "winH", userEditorGui["winH"].Value,
        "AutoPvP", userEditorGui["AutoPvP"].Value,
        "OneTimeActDelayed", userEditorGui["OneTimeActDelayed"].Value
    )
    userEditorGui.Destroy()

    if (UserTableRowBeingEdited > 0) {
        updatedEntry := [
            savedValues["AccountName"],
            savedValues["AccountEmail"],
            savedValues["AccountPassword"],
            savedValues["AutoM1"],
            savedValues["AutoM2"],
            savedValues["AutoSpecial1"],
            savedValues["AutoSpecial2"],
            savedValues["AutoRButton"],
            savedValues["AutoTButton"],
            savedValues["AutoLoot"],
            savedValues["AutoReconnect"],
            savedValues["FXDisable"],
            savedValues["DisableAccount"],
            savedValues["winX"],
            savedValues["winY"],
            savedValues["winW"],
            savedValues["winH"],
            savedValues["AutoPvP"],
            savedValues["OneTimeActDelayed"]
        ]

        LV.Modify(UserTableRowBeingEdited, "", updatedEntry*)
        Settings[UserTableRowBeingEdited] := updatedEntry
        
        LV.ModifyCol(1, "AutoHdr")
        LV.ModifyCol(2, "AutoHdr")
        LV.ModifyCol(3, "AutoHdr")
        
        SaveSettings(Settings)
    }
}


SaveSettings(Settings) {
    try {
        FileDelete A_ScriptDir "\Settings.ini"
        FileAppend "[Settings]`n", A_ScriptDir "\Settings.ini"
        for value in Settings {
            FileAppend value[1] "," value[2] "," value[3] "," value[4] "," value[5] "," value[6] "," value[7] "," value[8] "," value[9] "," value[10] "," value[11] "," value[12] "," value[13] "," value[14] "," value[15] "," value[16] "," value[17] "," value[18] "," (value[19] = "" ? 0 : value[19]) "`n", A_ScriptDir "\Settings.ini"
        }
    } catch Error as e {
        if DEBUG_MODE
            throw e
    }
}

LoadSettings() {
    try {
        if !FileExist(A_ScriptDir "\Settings.ini")
            return []
            
        SettingsFile := FileRead(A_ScriptDir "\Settings.ini")
        if !SettingsFile
            return []
            
        SettingsArray := StrSplit(SettingsFile, "`n")
        Settings := []
        
        for index, value in SettingsArray {
            if (index = 1 || index = SettingsArray.Length)  
                continue
                
            fields := StrSplit(value, ",")
            if fields.Length >= 19  
                Settings.Push(fields)
        }
        return Settings
    } catch Error as e {
        if DEBUG_MODE
            throw e
        return []
    }
}

SendKeyToWindow(key, windowTitle, holdTime := 300) {
    static WM_KEYDOWN := 0x100
    static WM_KEYUP := 0x101
    static MAPVK_VK_TO_VSC := 0
    static keyMap := Map(
        "1", 0x31, "2", 0x32, "3", 0x33, "4", 0x34,
        "r", 0x52, "t", 0x54, "e", 0x45, "b", 0x42,
        "Enter", 0x0D, "LCtrl", 0x11,
        "BomberRoyale", ["LCtrl", "b"]  
    )
    
    if WinExist(windowTitle) {
        vk := keyMap.Has(key) ? keyMap[key] : GetKeyVK(key)
        scanCode := DllCall("MapVirtualKey", "UInt", vk, "UInt", MAPVK_VK_TO_VSC)
        lParam := (scanCode << 16) | 1  
        
        PostMessage WM_KEYDOWN, vk, lParam,, windowTitle
        Sleep holdTime  
        
        lParam |= 0xC0000000  
        PostMessage WM_KEYUP, vk, lParam,, windowTitle
    }
}

SendKeyToWindowReverse(key, windowTitle) {
    static WM_KEYDOWN := 0x100
    static WM_KEYUP := 0x101
    static MAPVK_VK_TO_VSC := 0
    static keyMap := Map(
        "1", 0x31, "2", 0x32, "3", 0x33, "4", 0x34,
        "r", 0x52, "t", 0x54, "e", 0x45, "b", 0x42,
        "Enter", 0x0D, "LCtrl", 0x11
    )
    
    if WinExist(windowTitle) {
        vk := keyMap.Has(key) ? keyMap[key] : GetKeyVK(key)
        scanCode := DllCall("MapVirtualKey", "UInt", vk, "UInt", MAPVK_VK_TO_VSC)
        lParam := (scanCode << 16) | 1  
        
        lParam |= 0xC0000000  
        PostMessage WM_KEYUP, vk, lParam,, windowTitle
        Sleep 100 
        
        lParam &= ~0xC0000000  
        PostMessage WM_KEYDOWN, vk, lParam,, windowTitle
    }
}

SendCompoundKeys(keys, windowTitle, holdTime := 300) {
    if Type(keys) != "Array"
        return
        
    for key in keys {
        SendKeyToWindow(key, windowTitle)
        Sleep 50
    }
    
    Sleep holdTime
    
    Loop keys.Length
        SendKeyToWindow(keys[keys.Length - A_Index + 1], windowTitle, "UP")
}

AwaitActiveWindow(windowTitle) {
    startTime := A_TickCount
    timeout := 30000  
    
    while (!WinActive(windowTitle)) {
        if (A_TickCount - startTime > timeout) {
            MsgBox "Timeout waiting for window: " windowTitle,, "T5"  
            return false
        }
        Sleep 100
    }
    return true
}

