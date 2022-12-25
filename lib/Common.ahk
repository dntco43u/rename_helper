#include <Base64>

#SingleInstance force
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#InstallKeybdHook
#InstallMouseHook
#UseHook

ListLines Off
Process, Priority, , A
SetTitleMatchMode, 2
SetTitleMatchMode, Fast
SetBatchLines, -1
SetKeyDelay, -1, -1, Play
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
CoordMode, Mouse, Client
CoordMode, Pixel, Client
CoordMode, ToolTip, Screen

FileEncoding, UTF-8

;-------------------------------------------------------------------------------
; global variables
;-------------------------------------------------------------------------------

global CURRENT_LOG_LEVEL := 0
global LOG_LEVEL_ARRAY := [["TRACE", 1], ["DEBUG", 2], ["INFO", 3], ["WARN", 4], ["ERROR", 5], ["SEVERE", 6]]
global LOG_FILE := A_ScriptDir "\log\" SubStr(A_ScriptName, 1, -4) ".log" ;log file
global PROPERTIES_FILE := A_ScriptDir "\" SubStr(A_ScriptName, 1, -4) ".properties" ;properties file

;-------------------------------------------------------------------------------
; init
;-------------------------------------------------------------------------------

init() 
;init

init() {
  getProperties(PROPERTIES_FILE) ;getProperties
  runAsAdmin()
  removeLogFile(8192)
}

;-------------------------------------------------------------------------------
; screen functions
;-------------------------------------------------------------------------------

getPixelColor(pixelX, pixelY) {
  if (pixelX = "") || (pixelY = "") {
    MouseGetPos, pixelX, pixelY
  }
  PixelGetColor, color, pixelX, pixelY
  message := "PixelGetColor() " (ErrorLevel = 0 ? "SUCCEED" : "FAILED ") " " pixelX ", " pixelY " " color
  writeLogFile("INFO", A_ThisFunc, A_LineNumber, message)
  showToolTip("INFO", message)
  return color
}

isColorFromPixel(startX, startY, color, variation) {
  endX := startX + 1
  endY :=startY + 1
  PixelSearch, foundX, foundY, startX, startY, endX, endY, color, variation, Fast
  result := ErrorLevel = 0 ? true : false
  message := "PixelSearch() " (result ? "SUCCEED " foundX ", " foundY : "FAILED ") " " color
  writeLogFile("DEBUG", A_ThisFunc, A_LineNumber, message)
  showToolTip("WARN", message)
  if result
    return true
  else
    return false
}

;-------------------------------------------------------------------------------
; file functions
;-------------------------------------------------------------------------------

removeFile(file) {
  FileDelete, %file%
  message := "FileDelete() " (ErrorLevel = 0 ? "SUCCEED" : "FAILED ") " " file
  writeLogFile("DEBUG", A_ThisFunc, A_LineNumber, message)
}

getTextFile(textFile) {
  FileRead, outText, %textFile%
  message := "FileRead() " (ErrorLevel = 0 ? "SUCCEED" : "FAILED ") " " textFile
  writeLogFile("DEBUG", A_ThisFunc, A_LineNumber, message)
  message := "getTextFile() " outText " (" StrLen(outText) ")"
  writeLogFile("DEBUG", A_ThisFunc, A_LineNumber, message)
  showToolTip("DEBUG", message)
  return outText
}

setTextFile(outText, textFile) {
  FileAppend, % outText "`r`n", %textFile%
  message := "FileAppend() " (ErrorLevel = 0 ? "SUCCEED" : "FAILED ") " " textFile
  writeLogFile("DEBUG", A_ThisFunc, A_LineNumber, message)
  message := "setTextFile() " outText " (" StrLen(outText) ")"
  writeLogFile("DEBUG", A_ThisFunc, A_LineNumber, message)
  showToolTip("DEBUG", message)
}

;-------------------------------------------------------------------------------
; common functions
;-------------------------------------------------------------------------------

getProperties(propertiesFile) {
  FileRead, properties, %propertiesFile%
  if errorlevel
    return
  oProperties := StrSplit(properties, "`r`n")
  loop, % oProperties.MaxIndex() {
    if (InStr(oProperties[A_Index], "LOG_LEVEL")) {
      logLevelProperties := StrSplit(oProperties[A_Index], "=")[2]
      loop, % LOG_LEVEL_ARRAY.MaxIndex() {
        if (logLevelProperties = LOG_LEVEL_ARRAY[A_Index][1]) {
          CURRENT_LOG_LEVEL := LOG_LEVEL_ARRAY[A_Index][2]
        }
      }
    }
  }
}

runAsAdmin() {
  message := "A_IsAdmin " (A_IsAdmin = 1 ? "SUCCEED" : "FAILED ")
  writeLogFile("DEBUG", A_ThisFunc, A_LineNumber, message)
  showToolTip("DEBUG", message)
  if A_IsAdmin
    return
  Run *RunAs "%A_ScriptFullPath%"
  ExitApp
}

writeLogFile(levelName, functionName, lineNumber, message) {
  level := 0
  loop, % LOG_LEVEL_ARRAY.MaxIndex() {
    if (levelName = LOG_LEVEL_ARRAY[A_Index][1]) {
      level := LOG_LEVEL_ARRAY[A_Index][2]
    }
  }
  if (CURRENT_LOG_LEVEL > level)
    return
  ;write log file
  FileAppend, % A_YYYY "-" A_MM  "-" A_DD " " A_Hour ":" A_Min ":" A_Sec "." A_MSec " " levelName " " A_ScriptName "." functionName "() Line " lineNumber " " message "`n", %LOG_FILE%
}

removeLogFile(thresholdSize) {
  FileGetSize, fileSize, %LOG_FILE%, K
  message := "FileGetSize() " (ErrorLevel = 0 ? "SUCCEED" : "FAILED ") " " fileSize "KB " LOG_FILE
  writeLogFile("WARN", A_ThisFunc, A_LineNumber, message)
  if (fileSize < thresholdSize)
    return
  FileDelete, %LOG_FILE%
  message := "FileDelete() " (ErrorLevel = 0 ? "SUCCEED" : "FAILED ") " " LOG_FILE
  writeLogFile("WARN", A_ThisFunc, A_LineNumber, message)
  showToolTip("WARN", message)
}

showToolTip(levelName, message) {
  level := 0
  loop, % LOG_LEVEL_ARRAY.MaxIndex() {
    if (levelName = LOG_LEVEL_ARRAY[A_Index][1]) {
      level := LOG_LEVEL_ARRAY[A_Index][2]
    }
  }
  if (CURRENT_LOG_LEVEL > level)
    return
  ToolTip, %message%, 5, 5
  SetTimer, removeTooltipTimer, -7000
}

removeTooltipTimer:
{
  ToolTip
  return
}

initHotkey(description) {
  if GetKeyState("Ctrl") {
    Send, {Ctrl Up}
    Sleep, 1
  }
  if GetKeyState("Alt") {
    Send, {Alt Up}
    Sleep, 1
  }
  if GetKeyState("Shift") {
    Send, {Shift Up}
    Sleep, 1
  }
  if GetKeyState("LButton") {
    Send, {LButton Up}
    Sleep, 1
  }
  if GetKeyState("RButton") {
    Send, {RButton Up}
    Sleep, 1
  }
  KeyWait, Ctrl
  KeyWait, Alt
  KeyWait, Shift
  Sleep, 20
  showToolTip("INFO", A_ScriptName "." description)
}

;playBeep(1, 7902, 80) ;SUCCEED
;playBeep(1, 2489, 80) ;FAILED
playBeep(times, freq, dur) {
  loop, % times {
    SoundBeep, freq, dur
    Sleep, 10
  }
}
