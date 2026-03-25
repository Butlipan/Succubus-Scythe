#<><><><><><><>
#STYLE CODE 
#It's just for rule "DRY"
function wait { Start-Sleep 1 }                     
function stripe {Write-Host "<==========================================>" -ForegroundColor Magenta}
#<><><><><><><>
#========
#WIN. VERSION
function version {
       try {
            Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber  
       }
       catch {
            Write-Host "`n[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red 
       }
}       
#========
#USER. ENUMERATION
function users {
    try {
        Write-Host "`n[+] Local users:" -ForegroundColor Cyan
        Get-LocalUser | Format-Table -AutoSize
    }
    catch {
        Write-Host "`n[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red
    }
    try {
        Write-Host "`n[+] Local groups:" -ForegroundColor Cyan
        Get-LocalGroup | Format-Table -AutoSize
    }
    catch {
        Write-Host "`n[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red
    }
    try {
        Write-Host "`n[+] Administrators group members:" -ForegroundColor Cyan
        Get-LocalGroupMember -SID "S-1-5-32-544" -ErrorAction Stop | ForEach-Object {
            Write-Host " - $($_.Name)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "`n[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red
    }
}
#========
#FIREWALL CHECK
function firewall {
    while ($true) {  
        $x = Read-Host "Do you want to see full report of firewall? (Y/N) "
        switch ($x.ToUpper()) {
            "Y" {
                try {
                    Write-Host "`n[+] === Full firewall report ===" -ForegroundColor Cyan
                    netsh advfirewall show allprofiles | Format-Table -AutoSize
                    return
                }
                catch {
                    Write-Host "[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red
                    return
                } 
            }
            "N" {
                try {
                    Write-Host "[=] Skipping full report, showing basic info..." -ForegroundColor Yellow
                    Write-Host "`n[+] Firewall state:" -ForegroundColor Cyan

                    netsh advfirewall show allprofiles |
                        Select-String "State|Profile|ON|OFF" | Format-Table -AutoSize
                    return
                }
                catch {
                    Write-Host "[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red
                    return
                } 
            }
            default {
                Write-Host "[=] BAD INPUT" -ForegroundColor White
            }
        }
    }
}
#=======
#RUNNING SERVICES
function services {
    try {
        Get-CimInstance Win32_Service | Where-Object { $_.PathName -match ' ' -and $_.PathName -notmatch '"' } | Select-Object Name, PathName, StartMode
    }
    catch {
        Write-Host "[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red
    }
}
#=======
#SCHEDULED TASKS
function cronjobs {
    try {
        Get-ScheduledTask | Select-Object TaskName, TaskPath, State | Sort-Object -Property State -Descending | Format-Table TaskName, TaskPath, State -AutoSize
    }
    catch {
        Write-Host "[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red
    }
}
#=======
#PASSWORD POLICY
function password {
    try {
        Write-Host "`n[+] Password required?: " -ForegroundColor Cyan 
        Get-LocalUser | Select-Object Name, PasswordRequired | Format-Table -AutoSize
    }
    catch {
        Write-Host "[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red 
    }
    try {
        Write-Host "`[+] Password policy for users: " -ForegroundColor Cyan 
        Write-Host " " 
        net accounts 
    }
    catch {
        Write-Host "[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red 
    }
}
#=======
#SEARCHING FOR SPECIFIC FILES 
function fileSearch {
    Write-Host "`n[!] File search module" -ForegroundColor Cyan
    Write-Host "[=] This scan targets common sensitive locations (optimized, not full disk)" -ForegroundColor Yellow
    $choice = Read-Host "Do you want to run file search? (Y/N)"
    if ($choice.ToUpper() -ne "Y") {
        Write-Host "[=] Skipping file search..." -ForegroundColor Yellow
        return
    }
#target paths
    $paths = @(
        "C:\Users",
        "C:\Windows\Temp",
        "C:\ProgramData"
    )
#patterns
    $patterns = @(
        "*password*",
        "*cred*",
        "*.config",
        "*.xml",
        "*.txt",
        "*.ini",
        "*.log",
        "*.zip"
    )
    foreach ($path in $paths) {
        Write-Host "`n[+] Scanning: $path" -ForegroundColor Cyan
        foreach ($pattern in $patterns) {
            try {
                $results = Get-ChildItem -Path $path -Recurse -Force -File `
                    -ErrorAction SilentlyContinue -Filter $pattern

                foreach ($file in $results) {
                    Write-Host "[!] Found: $($file.FullName)" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "[=] Skipping $path ($pattern): $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
    Write-Host "`n[+] File search completed." -ForegroundColor Green
}
#=======
#REGISTRY KEYS
function keys {   #<--- Why not cmdlets? Reg is less grumpy
    try {
        Write-Host "`n[+] HKLM keys: " -ForegroundColor Cyan 
        reg query HKLM 
    }
    catch {
        Write-Host "[-] NO PERMISSIONS FOR REG QUERY HKLM" -ForegroundColor Red 
    }
    try {
        Write-Host "`n[+] HKCU keys: " -ForegroundColor Cyan 
        reg query HKCU 
    }
    catch {
        Write-Host "[-] NO PERMISSIONS FOR REG QUERY HCKU" -ForegroundColor Red 
    }
    try {
        Write-Host "`n[+] HKU keys: " -ForegroundColor Cyan 
        reg query HKU 
    }
    catch {
        Write-Host "[-] NO PERMISSIONS FOR REG QUERY HKU" -ForegroundColor Red 
    }
}
#=======
#STARTUP REGISTRY KEYS
function startUp {
     try {
        Write-Host "`n[+] HKLM startups found: " -ForegroundColor Cyan
        reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" 
     }
     catch {
         Write-Host "[-] NO PERMISSIONS FOR REG [HKLM]" 
     }
     try {
        Write-Host "`n[+] HKCU startups found: " -ForegroundColor Cyan
        reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" 
     }
     catch {
        Write-Host "[-] NO PERMISSIONS OR ERROR [HKCU]"
     }   
}
#=======
#CHECKING FOR SMB SHARES
function smb {
  try {
    Get-SmbShare 
  }
  catch {
    Write-Host "[-] NO PERMISSIONS OR ERROR" 
  }  
}
#=======
#CHECKING ALL CONNECTIONS, LIKE LOCALHOST ETC.
function connections {
    try {
        Get-NetTCPConnection
    }
    catch {
        Write-Host "[-] NO PERMISSIONS OR ERROR" 
    }
}
#=======
#CHECKING FOR PRIVSEC THROUGH UNQ. PATHS
function unquotedServices {
    Write-Host "`n[+] Checking for Unquoted Service Paths..." -ForegroundColor Cyan

    try {
        $services = Get-CimInstance Win32_Service

        $vuln = $services | Where-Object {
            $_.PathName -match ' ' -and
            $_.PathName -notmatch '"' -and
            $_.PathName -notmatch 'svchost.exe' -and
            $_.PathName -notmatch 'dllhost.exe' -and
            $_.PathName -notmatch 'msiexec.exe' -and
            $_.PathName -notmatch ' -' -and
            $_.PathName -notmatch ' /'
        }

        if ($vuln) {
            Write-Host "[!] POSSIBLE Unquoted Service Paths FOUND (check icacls)" -ForegroundColor Yellow

            foreach ($svc in $vuln) {
                Write-Host "`n[!] Service: $($svc.Name)" -ForegroundColor Yellow
                Write-Host "    PathName: $($svc.PathName)"
            }
        }
        else {
            Write-Host "[-] No vulnerable services found." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "[-] ERROR" -ForegroundColor Red
    }
}
#=======
#CHECKING FOR PRIVSEC THROUGH BAD PERMISSIONS
function weakpermissions {

    $x = Read-Host "Do you want to run weak permissions check? (Y/N)"
    switch ($x.ToUpper()) {
        "Y" {   
            $Root = "C:\" # <- Here, you can change drive, u want to check. I'm added this option to not search through all host. Also, if you're have Admin. rights, you comment out this section
            Write-Host "[+] Scanning: $Root" -ForegroundColor Cyan

            Get-ChildItem -Path $Root -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {

                $path = $_.FullName

                try {
                    $acl = Get-Acl -Path $path -ErrorAction Stop

                    foreach ($ace in $acl.Access) {
                        if ($ace.FileSystemRights -match "Write|Modify|FullControl") {
                            Write-Host "`n[!] POSSIBLE WEAK PERMISSION" -ForegroundColor Red
                            Write-Host "    Path: $path"
                            Write-Host "    Identity: $($ace.IdentityReference)"
                            Write-Host "    Rights: $($ace.FileSystemRights)"
                        }
                    }
                }
                catch {
                    Write-Host "[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red
                }
            }
        }
        "N" {
            Write-Host "[=] Skipping weak permissions check..." -ForegroundColor Yellow
            return
        }
        default {
            Write-Host "[=] BAD INPUT" -ForegroundColor White
        }
    }
}
#=======
#CHECKING FOR PRIVSEC THROUGH HIDDEN CREDS.
function creds {
    #Winlogon section
    Write-Host "`n[+] Checking AutoLogon credentials..." -ForegroundColor Cyan
    try {
        $reg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        $user = $reg.DefaultUserName
        $pass = $reg.DefaultPassword
        $domain = $reg.DefaultDomainName

        if ($pass) {
            Write-Host "[!] POSSIBLE CREDENTIALS FOUND!" -ForegroundColor Red
            Write-Host "    User: $user"
            Write-Host "    Password: $pass"
            Write-Host "    Domain: $domain"
        }
        else {
            Write-Host "[-] No AutoLogon credentials found." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red
    }
    #Putty section
    Write-Host "`n[+] Checking Putty credentials..." -ForegroundColor Cyan
    try {
        $sessions = Get-ChildItem "HKCU:\SOFTWARE\SimonTatham\PuTTY\Sessions" -ErrorAction Stop
        foreach ($session in $sessions) {
            $data = Get-ItemProperty $session.PSPath
            Write-Host "`n[+] Session: $($session.PSChildName)" -ForegroundColor Green
            if ($data.ProxyUsername -or $data.UserName) {
                Write-Host "    User: $($data.UserName)"
                Write-Host "    ProxyUser: $($data.ProxyUsername)"
            }
            if ($data.ProxyPassword) {
                Write-Host "    [!] POSSIBLE PASSWORD FOUND!" -ForegroundColor Red
                Write-Host "    Password: $($data.ProxyPassword)"
            }
        }
    }
    catch {
        Write-Host "[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red
    }
    #Cmdkey section
    Write-Host "`n[+] Checking cmdkey..." -ForegroundColor Cyan
    try {
        cmdkey /list
    }
    catch {
        Write-Host "[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red
    }
    #Wifi section
    Write-Host "`n[+] Checking for wifi stored creds...." -ForegroundColor Cyan
    try {
        $profiles = netsh wlan show profiles | Select-String "All User Profile\s+:\s+(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value }; foreach ($profile in $profiles) { Write-Host "Wifi:     $profile"; netsh wlan show profile name=$profile key=clear | Select-String "Key Content\s+:\s+(.+)$" | ForEach-Object { Write-Host "Password: $($_.Matches.Groups[1].Value)`r`n" } }; Write-Host ''
    }
    catch {
        Write-Host "[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red
    }
    
}
#=======
#CHECKING PS HISTORY OF ALL USERS
function checking_powershell {
   $x = Read-Host "Do you want to check all users powershell history? (Y/N)"
   switch ($x) {
     "Y" {
        try {
            Write-Host "`n[+] Checking PS history..." -ForegroundColor Cyan
            foreach($user in ((Get-Childitem C:\users).fullname)){Get-Content "$user\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt" -ErrorAction SilentlyContinue}
        }
        catch {
            Write-Host "[-] NO PERMISSIONS OR ERROR" -ForegroundColor Red
        }
     }
     "N"{
        Write-Host "[=] Skipping PS history check..." -ForegroundColor Yellow
        return
     }
     default {
        Write-Host "[=] BAD INPUT" -ForegroundColor White
     }
    }
}
#<><><><><>
#PRESENTATION SECTION
stripe
Write-Host "PROJECT-SUCUBI -> SUCUWIN" -ForegroundColor Blue
Write-Host "SCRIPT MADE BY TULIPAN" -ForegroundColor Blue
Write-Host "Please, give some resp. on HTB :) -> https://app.hackthebox.com/users/2478290" -ForegroundColor Blue
stripe
wait
Start-Sleep 1.5
Write-Host "........................................................................................................................................................................"
Write-Host ".....................................................................*############################=....................................................................."
Write-Host "..............................................................###########################################:.............................................................."
Write-Host ".........................................................##############*:.....................:*##############.........................................................."
Write-Host "....................................................*###########.......................................%##########+....................................................."
Write-Host ".................................................#########:.................................................##########.................................................."
Write-Host "..............................................########..........................................................#########..............................................."
Write-Host "...........................................########...................-######################.......................########............................................"
Write-Host ".........................................#######...................######=:..............:#######=.....................#######=........................................."
Write-Host "......................................+######....................###............................###.......................#######......................................."
Write-Host "....................................#######......................###:...........................###.........................#######....................................."
Write-Host "..................................######+.........................%######*.................:#####%............................:######..................................."
Write-Host "................................+#####-...............................%######################%...................................######................................."
Write-Host "...............................#####*.........................##.....................................%#............................#####*..............................."
Write-Host ".............................######...........................##.....................................##.............................=#####.............................."
Write-Host "............................#####................###.........=##%..........##############:..........###..........###=.................%####%............................"
Write-Host "..........................%####:.............:######.........+####......####################+.....#####..........:######................#####..........................."
Write-Host ".........................#####.............########..........:######:#########################+.#######...........#########..............#####-........................."
Write-Host "........................#####...........*#########............########################################*............##########+............=#####........................"
Write-Host ".......................####-..........############............:#######################################.............#############............#####......................."
Write-Host "......................####..........##############.............*#####################################..............*######:#######...........#####......................"
Write-Host ".....................####.........#######.*#######.............######################################..............+#######..#######..........#####....................."
Write-Host "....................####........=#####-..#########............*###########################..##########.............#########...+#####+.........#####...................."
Write-Host "...................####........#####-...%#########............##########################....*#########.............##########....+#####.........#####..................."
Write-Host "..................####=......######....#####-#####...........#########################........########.............#####.#####.....######........####-.................."
Write-Host ".................#####......#####......####:.#####+.........+####################:.............:######............######..#####......#####........####.................."
Write-Host ".................####......####*......####...######.........#################....................#####...........:#####....####:......#####-......#####................."
Write-Host "................####:....+####.......%###-....######.......################....=###...........-#######...........######.....####........#####......####-................"
Write-Host "...............-####....*####........####.....*#####......################........###.......+#=.:#####..........######.......###+........#####......####................"
Write-Host "...............####....+####........####.......######...#################....#####%##......##%#######+.........######........####.........#####.....####+..............."
Write-Host "..............-####...-####.........###.........#########################.....######-.....#####*#####.........######:.........###..........#####.....####..............."
Write-Host "..............####....###%.........####..........########################.................#.....#####.......:######:..........####..........*####....####..............."
Write-Host "..............####...###%..........###............#######################.................#....=#####......#######.............###...........*###:...-####.............."
Write-Host ".............*####..####...........###............#######################.................#....#######....#######..............###............%###....####.............."
Write-Host ".............####-.:###...........*##:..........=########################.............#####...:########.#######=...............*##-............####...####.............."
Write-Host ".............####..###............###..........=##########################...................:################..................##%.............###...####+............."
Write-Host ".............####.+##=............###..........############################.......-+=*%##:..%###############....................##%..............###..=####............."
Write-Host ".............####.###.............##%.........##############################%.......+###...###############+.....................###..............*##:..####............."
Write-Host "............:####:##..............###.........###########################.####*..........:################......................###...............###..####............."
Write-Host "............:#######..:########...##:.....:...##########################....#####.......##################-.........#######+....###..:########*...:##..####............."
Write-Host "............:######:#############.##..#################################.......=###########################-......#############..###.#############..###.####............."
Write-Host ".............##########.......######*#######%#########=........######:............########################......###=......############*.......%###:-##*####............."
Write-Host ".............########...........########......######..............:###*.............######........#######=.....##............########...........###########............."
Write-Host ".............######-.............#####.......#####....................:%+..........####.............#####......................####:.............:#########............."
Write-Host ".............#####-...............###......=####:.................................%#.................#####......................##-................#######:............."
Write-Host ".............#####................##......#####........................................................####......................#..................######.............."
Write-Host "..............####.......................#####..........................................................####........................................=#####.............."
Write-Host "..............####......................####:............................................................####........................................####*.............."
Write-Host "..............####+....................####......................................................#:.......#####......................................####..............."
Write-Host "...............####..................#####...............-##:.........*#######+..................##........#####....................................*###%..............."
Write-Host "...............%###*................#####..............#####*......######%%#########.............###........+####-.....*####-.......................####................"
Write-Host "................####...............####..............########..=#####:..........*#########........###.........#####..###########...................####%................"
Write-Host "................*####............####%.............###############......................####......-###.........%#######......:#####%..............:####................."
Write-Host ".................####=..........####.............#############*..................*##=.....###-.....####..........####............#######%.........####.................."
Write-Host "..................####........:###*.......=#############*...................##%....######..#####...=###:........###=.................=######.....#####.................."
Write-Host "..................-####......+###....+#######=:...................#######*...#####..*######.+#####.-####......####.................=......####..*####..................."
Write-Host "...................#####....-###...............................############..*#####-.###-#######--.%#####....###.....######....##*..*###....###-####...................."
Write-Host "....................####%...###.............................################..##*####.##...#####...########.###...##########+..####..-####*.=######....................."
Write-Host ".....................####%.###+..........................*##########......###.%##.######+..........###..######...########.%##..:####%.######.#####......................"
Write-Host "......................########........................%###########:........######...#####.........####.....###..########...###..######.##########......................."
Write-Host ".......................#######.....................###############:.........=####.....%#.........###%.......##.#########...-##..##:-##*=##.#####........................"
Write-Host "........................######................:#######*...*#######:...........+#................###.........####..:####.....###.##..%##.##..####........................"
Write-Host "..........................####*...........#########:.......#######.............................###..........................%##*##...#####..##%........................."
Write-Host "...........................####################............#######.............................#%............................####....:####%..#.........................."
Write-Host "............................*#############-................#######....................................................................####*............................."
Write-Host "..............................#####........................#######........-##################=.......................................#####.............................."
Write-Host "...............................-#####......................######........*####################:..####+...............+#............#####*..............................."
Write-Host ".................................######...................%#####+........#####################...#####################=..........######................................."
Write-Host "...................................######................%######........+####################=..######################.........######..................................."
Write-Host ".....................................######+............#######.........#####################...#####################=......-######....................................."
Write-Host ".......................................#######.........######+.........:####################+..######################.....#######......................................."
Write-Host ".........................................=#######....#######...........#####################...#####################+..#######.........................................."
Write-Host "............................................###############............####################:..######################...####*............................................"
Write-Host "...............................................##########.............%####################...#####################*..##%..............................................."
Write-Host "..................................................#########-..........####.........:%#####...######################....................................................."
Write-Host ".....................................................:##########:........................-..:######################....................................................."
Write-Host "..........................................................########.....###############........####################......................................................"
Write-Host "...............................................................+#...#####################...........=######+............................................................"
Write-Host "....................................................................####################...####-................-......................................................."
Write-Host "...................................................................#####################...######################......................................................."
Write-Host "..................................................................:####################...######################........................................................"
Write-Host "..................................................................#####################...#####################+........................................................"
Write-Host "..................................................................####################:..######################........................................................."
Write-Host ".................................................................#####################...#####################.........................................................."
Write-Host ".................................................................####################...######################.........................................................."
Write-Host "................................................................#####################...#####################..........................................................."
Write-Host ".................................................................................###...######################..........................................................."
Write-Host ".......................................................................................#####################............................................................"
Write-Host "...........................................................................................##############+.............................................................."
Write-Host "........................................................................................................................................................................"
Write-Host "........................................................................................................................................................................"
Start-Sleep 2
#<><><><><>
#INVOKING FUNCTIONS SECTION
Write-Host '================= BASIC INFO ===============' -ForegroundColor Magenta
version | Out-Host
stripe
wait
Write-Host '=================  USERS  ==================' -ForegroundColor Magenta
users | Out-Host
stripe
wait
Write-Host '============= PASSWORD POLICY ==============' -ForegroundColor Magenta
password | Out-Host
stripe
wait
Write-Host '======= CHECKING FOR HIDDEN CREDS. =======' -ForegroundColor Magenta
creds | Out-Host
stripe
wait
Write-Host '=========== CHECKING PS HISTORY ===========' -ForegroundColor Magenta
checking_powershell | Out-Host
stripe
wait
Write-Host '================  FIREWALL  ================' -ForegroundColor Magenta
firewall | Out-Host
stripe
wait
Write-Host '===========  ACTIVE CONNECTIONS  ===========' -ForegroundColor Magenta
connections | Out-Host
stripe
wait
Write-Host '==================  SMB  ===================' -ForegroundColor Magenta
smb | Out-Host
stripe
wait
Write-Host '============= WEAK PERMISSIONS ==============' -ForegroundColor Magenta
weakpermissions  | Out-Host
stripe
wait
Write-Host '================ SERVICES =================' -ForegroundColor Magenta
services | Out-Host  
stripe
wait
Write-Host '===========  UNQUOTED SERVICES  ============' -ForegroundColor Magenta
unquotedServices | Out-Host
stripe
wait
Write-Host '============= SCHEDULED TASKS ==============' -ForegroundColor Magenta
cronjobs |Out-Host
stripe
wait
Write-Host '================ REG. KEYS =================' -ForegroundColor Magenta
keys | Out-Host
stripe
wait
Write-Host '============= STARTUP PROGRAMS =============' -ForegroundColor Magenta
startUp | Out-Host
stripe
wait
Write-Host '=============== FILE SEARCH ================' -ForegroundColor Magenta
fileSearch | Out-Host
stripe
wait
