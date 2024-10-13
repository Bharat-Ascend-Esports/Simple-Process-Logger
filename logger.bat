@echo off
setlocal enabledelayedexpansion

:: Set up ANSI escape code variable for color formatting
for /f skip^=4 %%e in ('echo;prompt $E^|cmd.exe') do set "_$E=%%~e"

:: ASCII Banner Display
set "banner[1]= _______  ______    _______  __   __  ______     _     _  _______  _______  _______  __   __  _______  ______"   
set "banner[2]=|       ||    _ |  |   _   ||  | |  ||      |   | | _ | ||   _   ||       ||       ||  | |  ||       ||    _ |"  
set "banner[3]=|    ___||   | ||  |  |_|  ||  | |  ||  _    |  | || || ||  |_|  ||_     _||       ||  |_|  ||    ___||   | ||"  
set "banner[4]=|   |___ |   |_||_ |       ||  |_|  || | |   |  |       ||       |  |   |  |       ||       ||   |___ |   |_||_" 
set "banner[5]=|    ___||    __  ||       ||       || |_|   |  |       ||       |  |   |  |      _||       ||    ___||    __  |"
set "banner[6]=|   |    |   |  | ||   _   ||       ||       |  |   _   ||   _   |  |   |  |     |_ |   _   ||   |___ |   |  | |"
set "banner[7]=|___|    |___|  |_||__| |__||_______||______|   |__| |__||__| |__|  |___|  |_______||__| |__||_______||___|  |_|"

for /L %%i in (1,1,7) do ( echo !banner[%%i]! )
echo ============================================================
echo %_$E%[0;36;40m              Integrity is the real victory.%_$E%[0m
echo ============================================================

pause  :: Press any key to continue and start logging

:: Initialize cycle counter in memory (start from 1)
set cycle_count=1
echo %_$E%[0;34;40m[INFO] Initial cycle count set to 1.%_$E%[0m

:: PowerShell Script and Log Paths
set current_dir=%~dp0
set temp_log_file=%current_dir%\temp_process_log.txt
set final_log_file=%current_dir%\process_log.txt
set backup_log_file=%current_dir%\process_log_bk.txt
set temp_encrypted_log=%current_dir%\temp_process_log_encrypted.txt
set final_encrypted_log=%current_dir%\process_log_encrypted.txt
set backup_encrypted_log=%current_dir%\process_log_bk_encrypted.txt
set public_key=%current_dir%\public_key.xml

:loop
:: Debug - Starting new cycle
echo %_$E%[0;34;40m[INFO] Starting cycle %cycle_count%%_$E%[0m

:: Step 1: Hash the previous cycle's backup log (if exists) in odd cycles
set /A mod=cycle_count %% 2
if %mod% neq 0 (
    if exist "%backup_log_file%" (
        echo %_$E%[0;34;40m[INFO] Hashing process_log_bk.txt from the previous cycle...%_$E%[0m
        powershell -Command ^
          "$hash = Get-FileHash -Path '%backup_log_file%' -Algorithm SHA256;" ^
          "[System.IO.File]::WriteAllText('%current_dir%\logfile_hash_bk.txt', $hash.Hash);"
        if not exist "%current_dir%\logfile_hash_bk.txt" (
            echo %_$E%[0;31;40m[ERROR] Hashing process_log_bk.txt failed. Exiting...%_$E%[0m
            exit /b
        )

        :: Encrypt the backup log hash
        echo %_$E%[0;34;40m[INFO] Encrypting the backup log file...%_$E%[0m
        powershell -Command ^
          "$rsa = [System.Security.Cryptography.RSACng]::new();" ^
          "$publicKeyXml = Get-Content -Path '%public_key%' -Raw;" ^
          "$rsa.FromXmlString($publicKeyXml);" ^
          "$hashBytes = [System.IO.File]::ReadAllBytes('%current_dir%\logfile_hash_bk.txt');" ^
          "$encryptedLog = $rsa.Encrypt($hashBytes, [System.Security.Cryptography.RSAEncryptionPadding]::Pkcs1);" ^
          "[System.IO.File]::WriteAllBytes('%temp_encrypted_log%', $encryptedLog);"
        if exist "%temp_encrypted_log%" (
            move "%temp_encrypted_log%" "%backup_encrypted_log%"
            echo %_$E%[0;32;40m[+] Encrypted backup log file moved to final destination.%_$E%[0m
        ) else (
            echo %_$E%[0;31;40m[-] Encryption of the backup log failed. Exiting...%_$E%[0m
            exit /b
        )
    )
)

:: Step 2: Clear temp log file for fresh logging each cycle
echo %_$E%[0;34;40m[INFO] Clearing temp log file...%_$E%[0m
echo. > "%temp_log_file%"
if not exist "%temp_log_file%" (
    echo %_$E%[0;31;40m[ERROR] Failed to clear temp_process_log.txt. Exiting...%_$E%[0m
    exit /b
)

:: Step 3: Create PowerShell script to log processes
echo %_$E%[0;34;40m[INFO] Creating PowerShell script...%_$E%[0m
(
    echo Add-Content -Path "%temp_log_file%" -Value "========================="
    echo Add-Content -Path "%temp_log_file%" -Value "Log time: $(Get-Date) - Cycle: %cycle_count%"
    echo Add-Content -Path "%temp_log_file%" -Value "========================="
    echo Get-Process ^| ForEach-Object {
    echo     try {
    echo         $processPath = $_.Path
    echo         Add-Content -Path "%temp_log_file%" -Value "$($_.ProcessName) - $processPath"
    echo     } catch {
    echo         Add-Content -Path "%temp_log_file%" -Value "$($_.ProcessName) - Path Not Available"
    echo     }
    echo }
    echo Add-Content -Path "%temp_log_file%" -Value "`n"
) > "%current_dir%\capture_processes.ps1"

:: Step 4: Execute PowerShell script to capture process information
echo %_$E%[0;34;40m[INFO] Running PowerShell script...%_$E%[0m
powershell.exe -ExecutionPolicy Bypass -File "%current_dir%\capture_processes.ps1"
if not exist "%temp_log_file%" (
    echo %_$E%[0;31;40m[ERROR] PowerShell script did not generate temp_process_log.txt. Exiting...%_$E%[0m
    exit /b
)

:: Step 5: Append temp log to process_log.txt
echo %_$E%[0;34;40m[INFO] Appending temp log to process_log.txt...%_$E%[0m
type "%temp_log_file%" >> "%final_log_file%"
if not exist "%final_log_file%" (
    echo %_$E%[0;31;40m[ERROR] Failed to append temp log to process_log.txt. Exiting...%_$E%[0m
    exit /b
)

:: Step 6: Backup and hash process_log.txt in even cycles
if %mod% equ 0 (
    echo %_$E%[0;34;40m[INFO] Copying process_log.txt to process_log_bk.txt...%_$E%[0m
    copy "%final_log_file%" "%backup_log_file%" /Y
    if not exist "%backup_log_file%" (
        echo %_$E%[0;31;40m[ERROR] Failed to create backup. Exiting...%_$E%[0m
        exit /b
    )
)

:: Step 7: Hash process_log.txt after writing it
echo %_$E%[0;34;40m[INFO] Hashing process_log.txt...%_$E%[0m
powershell -Command ^
  "$hash = Get-FileHash -Path '%final_log_file%' -Algorithm SHA256;" ^
  "[System.IO.File]::WriteAllText('%current_dir%\logfile_hash.txt', $hash.Hash);"

:: Step 8: Encrypt the hash of process_log.txt using the RSA public key
echo %_$E%[0;34;40m[INFO] Encrypting the log file...%_$E%[0m
powershell -Command ^
  "$rsa = [System.Security.Cryptography.RSACng]::new();" ^
  "$publicKeyXml = Get-Content -Path '%public_key%' -Raw;" ^
  "$rsa.FromXmlString($publicKeyXml);" ^
  "$hashBytes = [System.IO.File]::ReadAllBytes('%current_dir%\logfile_hash.txt');" ^
  "$encryptedLog = $rsa.Encrypt($hashBytes, [System.Security.Cryptography.RSAEncryptionPadding]::Pkcs1);" ^
  "[System.IO.File]::WriteAllBytes('%temp_encrypted_log%', $encryptedLog);"

:: Step 9: Ensure encryption was successful before moving encrypted log to final destination
if exist "%temp_encrypted_log%" (
    move "%temp_encrypted_log%" "%final_encrypted_log%"
    echo %_$E%[0;32;40m[+] Encrypted log file moved to final destination.%_$E%[0m
) else (
    echo %_$E%[0;31;40m[-] Encryption failed. Exiting...%_$E%[0m
    exit /b
)

:: Step 10: Increment cycle count and log the new cycle
set /A cycle_count+=1
echo %_$E%[0;34;40m[INFO] Updated cycle count: %cycle_count%%_$E%[0m

:: Step 11: Wait for 30 seconds before the next run
echo %_$E%[0;34;40m[INFO] Waiting for 30 seconds before the next cycle...%_$E%[0m
timeout /t 30 /nobreak >nul

:: Loop back to repeat
goto loop
