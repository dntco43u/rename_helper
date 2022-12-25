#include <Common>

;-------------------------------------------------------------------------------
; global variables
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; init
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; hotkeys
;-------------------------------------------------------------------------------

^+p:: ;ctrl+shift+p
{
  initHotkey("Pause")
  Pause
  return
}

^+r:: ;ctrl+shift+r
{
  Reload
  return
}

^+x:: ;ctrl+shift+x
{
  ExitApp
}

^+`:: ;ctrl+shift+`
{
  initHotkey("getPixelColor")
  getPixelColor("", "")
  return
}

^+z:: ;ctrl+shift+z
{
  initHotkey("test")
  test()
  return
}

^+1:: ;ctrl+shift+1
{
  initHotkey("testEncodeBase64")
  renameEncodeBase64()
  renameDecodeBase64()
  return
}

^+a:: ;ctrl+shift+a
{
  initHotkey("renameEncodeBase64")
  renameEncodeBase64()
  return
}

^+s:: ;ctrl+shift+s
{
  initHotkey("renameDecodeBase64")
  renameDecodeBase64()
  return
}

;-------------------------------------------------------------------------------
; test
;-------------------------------------------------------------------------------

test() {
  message := decodeString(encodeString("rename_helper")) " -> " encodeString("rename_helper")
  writeLogFile("WARN", A_ThisFunc, A_LineNumber, message)
}

;-------------------------------------------------------------------------------
; biz functions
;-------------------------------------------------------------------------------

renameEncodeBase64() {
  ;FileSelectFolder, selectedPath, *C:\Users\%A_UserName%\Downloads\gzmo5ajq
  FileSelectFolder, selectedPath, *C:\Users\%A_UserName%\Downloads\1
  if ErrorLevel
    return
  renameEncodeFile := selectedPath "\" "renameCrypt.enc"
  renameDecodeFile := selectedPath "\" "renameCrypt.dec"
  removeFile(renameEncodeFile)
  removeFile(renameDecodeFile)
  rootPath := selectedPath
  loop Files, %selectedPath%\*.*, DFR
  {
    SplitPath, A_LoopFileFullPath, , outDir, outExt, outNameNoExt
    loopPath := StrReplace(A_LoopFileFullPath, selectedPath "\")
    cryptLoopPath := ""
    loopPathAttrib = ""
    oPathString := StrSplit(loopPath, "\")
    if (InStr(A_LoopFileAttrib, "D")) {
      loopPathAttrib := "D"
      loop, % oPathString.MaxIndex() {
        cryptLoopPath := cryptLoopPath "\" encodeString(oPathString[A_Index])
      }
    } else {
      loopPathAttrib := "F"
      loop, % oPathString.MaxIndex() {
        if (A_Index = oPathString.MaxIndex()) {
          cryptLoopPath := cryptLoopPath "\" encodeString(outNameNoExt) "." outExt
        } else {
          cryptLoopPath := cryptLoopPath "\" encodeString(oPathString[A_Index])
        }
      }
    }
    cryptLoopPath := SubStr(cryptLoopPath, 2, StrLen(cryptLoopPath))
    encodeSource := A_LoopFileFullPath
    encodeTarget := rootPath "\" cryptLoopPath
    setTextFile(loopPathAttrib "█" encodeSource "█" encodeTarget, renameEncodeFile)
  }
  if (copySourceFile(renameEncodeFile))
    removeSourceFile(renameEncodeFile) 
  removeFile(renameEncodeFile)
  playBeep(1, 7902, 80) ;SUCCEED
}

renameDecodeBase64() {
  FileSelectFolder, selectedPath, *C:\Users\%A_UserName%\Downloads\gzmo5ajq
  if ErrorLevel
    return
  renameEncodeFile := selectedPath "\" "renameCrypt.enc"
  renameDecodeFile := selectedPath "\" "renameCrypt.dec"
  removeFile(renameEncodeFile)
  removeFile(renameDecodeFile)
  rootPath := selectedPath
  loop Files, %selectedPath%\*.*, DFR
  {
    SplitPath, A_LoopFileFullPath, , outDir, outExt, outNameNoExt
    loopPath := StrReplace(A_LoopFileFullPath, selectedPath "\")
    cryptLoopPath := ""
    loopPathAttrib = ""
    oPathString := StrSplit(loopPath, "\")
    if (InStr(A_LoopFileAttrib, "D")) {
      loopPathAttrib := "D"
      loop, % oPathString.MaxIndex() {
        cryptLoopPath := cryptLoopPath "\" decodeString(oPathString[A_Index])
      }
    } else {
      loopPathAttrib := "F"
      loop, % oPathString.MaxIndex() {
        if (A_Index = oPathString.MaxIndex()) {
          cryptLoopPath := cryptLoopPath "\" decodeString(outNameNoExt) "." outExt
        } else {
          cryptLoopPath := cryptLoopPath "\" decodeString(oPathString[A_Index])
        }
      }
    }
    cryptLoopPath := SubStr(cryptLoopPath, 2, StrLen(cryptLoopPath))
    decodeSource := A_LoopFileFullPath
    decodeTarget := rootPath "\" cryptLoopPath
    setTextFile(loopPathAttrib "█" decodeSource "█" decodeTarget, renameDecodeFile)

  }
  if (copySourceFile(renameDecodeFile))
    removeSourceFile(renameDecodeFile) 
  removeFile(renameDecodeFile)
  playBeep(1, 7902, 80) ;SUCCEED
}

copySourceFile(renameCryptFile) {
  copyErrorLevel := 0
  FileRead, cryptString, %renameCryptFile%
  if ErrorLevel
    return false
  oCryptString := StrSplit(cryptString, "`r`n")
  loop, % oCryptString.MaxIndex() {
    if (InStr(oCryptString[A_Index], "█")) {
      cryptType := StrSplit(oCryptString[A_Index], "█")[1]
      cryptSource := StrSplit(oCryptString[A_Index], "█")[2]
      cryptTarget := StrSplit(oCryptString[A_Index], "█")[3]
      message := ""
      if (cryptType = "D") {
        FileCreateDir, %cryptTarget%
        copyErrorLevel := ErrorLevel
        message := "FileCreateDir() " (ErrorLevel = 0 ? "SUCCEED" : "FAILED ") " " cryptSource " -> " cryptTarget
      } else if (cryptType = "F") {
        FileCopy, %cryptSource%, %cryptTarget%, 1
        copyErrorLevel := ErrorLevel
        message := "FileCopy() " (ErrorLevel = 0 ? "SUCCEED" : "FAILED ") " " cryptSource " -> " cryptTarget
      }
      writeLogFile("INFO", A_ThisFunc, A_LineNumber, message)
      showToolTip("INFO", message)
      if copyErrorLevel {
        MsgBox, %cryptSource%
        return false
      }
    }
  }
  return true
}

removeSourceFile(renameCryptFile) {
  FileRead, cryptString, %renameCryptFile%
  if ErrorLevel
    return false
  oCryptString := StrSplit(cryptString, "`r`n")
  loop, % oCryptString.MaxIndex() {
    if (InStr(oCryptString[A_Index], "█")) {
      cryptType := StrSplit(oCryptString[A_Index], "█")[1]
      cryptSource := StrSplit(oCryptString[A_Index], "█")[2]
      message := ""
      if (cryptType = "D") {
        FileRemoveDir , %cryptSource%, 1
        message := "FileRemoveDir() " (ErrorLevel = 0 ? "SUCCEED" : "FAILED ") " " cryptSource
      } else if (cryptType = "F") {
        FileDelete, %cryptSource%
        message := "FileDelete() " (ErrorLevel = 0 ? "SUCCEED" : "FAILED ") " " cryptSource
      }
      writeLogFile("INFO", A_ThisFunc, A_LineNumber, message)
      showToolTip("INFO", message)
    }
  }
}

;XXX: Remove CRLF and use CRYPT_STRING_HEXRAW Crypt / Case of Base64, file name contains special characters that cannot be used
encodeString(str, formatName := "CRYPT_STRING_HEXRAW", encoding := "UTF-8", NOCRLF := true) {
  chars := StrPut(str, encoding) - 1
  VarSetCapacity(buff, size := chars << (encoding = "utf-16" || encoding = "cp1200"), 0)
  StrPut(str, &buff, chars, encoding)
  return cryptBinaryToString(&buff, size, formatName, NOCRLF)
}

decodeString(encodedStr, formatName := "CRYPT_STRING_HEXRAW", encoding := "UTF-8") {
  size := cryptStringToBinary(encodedStr, data, formatName)
  return StrGet(&data, size, encoding)
}

cryptBinaryToString(pData, size, formatName := "CRYPT_STRING_HEXRAW", NOCRLF := true) {
  static formats := { CRYPT_STRING_BASE64: 0x1, CRYPT_STRING_HEX: 0x4, CRYPT_STRING_HEXRAW: 0xC }, CRYPT_STRING_NOCRLF := 0x40000000
  fmt := formats[formatName] | (NOCRLF ? CRYPT_STRING_NOCRLF : 0)
  if !DllCall("Crypt32\CryptBinaryToString", "Ptr", pData, "UInt", size, "UInt", fmt, "Ptr", 0, "UIntP", chars)
    throw "CryptBinaryToString failed. LastError: " . A_LastError
  VarSetCapacity(outData, chars << !!A_IsUnicode)
  DllCall("Crypt32\CryptBinaryToString", "Ptr", pData, "UInt", size, "UInt", fmt, "Str", outData, "UIntP", chars)
  return outData
}

cryptStringToBinary(string, ByRef outData, formatName := "CRYPT_STRING_HEXRAW")
{
  static formats := { CRYPT_STRING_BASE64: 0x1, CRYPT_STRING_HEX: 0x4, CRYPT_STRING_HEXRAW: 0xC }
  fmt := formats[formatName]
  chars := StrLen(string)
  if !DllCall("Crypt32\CryptStringToBinary", "Ptr", &string, "UInt", chars, "UInt", fmt, "Ptr", 0, "UIntP", bytes, "UIntP", 0, "UIntP", 0)
    throw "CryptStringToBinary failed. LastError: " . A_LastError
   VarSetCapacity(outData, bytes)
   DllCall("Crypt32\CryptStringToBinary", "Ptr", &string, "UInt", chars, "UInt", fmt, "Str", outData, "UIntP", bytes, "UIntP", 0, "UIntP", 0)
   return bytes
}