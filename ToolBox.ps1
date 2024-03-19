# Команда Add-Type загружает сборки Windows Forms и Drawing.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Соз. форму
$form = New-Object System.Windows.Forms.Form
$form.Text = "Tool Box" 
$form.Size = New-Object System.Drawing.Size(1200,1000) 
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle 

$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Size = New-Object System.Drawing.Size(460, 535)
$tabControl.Location = New-Object System.Drawing.Point(10, 10)

# tab1
$tab1 = New-Object System.Windows.Forms.TabPage
$tab1.Text = "NET."

$tab2 = New-Object System.Windows.Forms.TabPage
$tab2.Text = "DISK"

$tab3 = New-Object System.Windows.Forms.TabPage
$tab3.Text = "MEMORY"

$tab4 = New-Object System.Windows.Forms.TabPage
$tab4.Text = "ADMIN"


#----------------LATENCY---------------------------

# Окно IP-адреса
$textBoxIPAddress = New-Object System.Windows.Forms.TextBox
$textBoxIPAddress.Location = New-Object System.Drawing.Point(20,20)
$textBoxIPAddress.Size = New-Object System.Drawing.Size(200,20)
$tab1.Controls.Add($textBoxIPAddress)

#Кнопка задержки (латентности)
$buttonPing = New-Object System.Windows.Forms.Button
$buttonPing.Location = New-Object System.Drawing.Point(20,50)
$buttonPing.Size = New-Object System.Drawing.Size(100,30)
$buttonPing.Text = "Latency"
$buttonPing.Add_Click({
    
    Invoke-Ping -IPAddress $textBoxIPAddress.Text -resultTextBox $textBoxPingResult
})
$tab1.Controls.Add($buttonPing)

# Окно Ping
$textBoxPingResult = New-Object System.Windows.Forms.TextBox
$textBoxPingResult.Location = New-Object System.Drawing.Point(20, 90)
$textBoxPingResult.Size = New-Object System.Drawing.Size(300, 50)
$textBoxPingResult.Multiline = $true
$textBoxPingResult.ReadOnly = $true
$tab1.Controls.Add($textBoxPingResult)

function Invoke-Ping {
    param (
        [string]$IPAddress,
        [System.Windows.Forms.TextBox]$resultTextBox
    )

    # Выполнить пинг
    $pingResult = Test-Connection -ComputerName $IPAddress -Count 1 -Quiet

    # Отобразить результат пинга
    if ($pingResult) {
        $pingTime = (Test-Connection -ComputerName $IPAddress -Count 1).ResponseTime
        $resultTextBox.Text = "$IPAddress is reachable. Ping time: $pingTime ms"
    } else {
        $resultTextBox.Text = "$IPAddress is unreachable."
    }
}


#---------------------IP CONFIG--------------------------


# Соз. текстовое поле для отображения конфигурации IP.
$textBoxIPConfig = New-Object System.Windows.Forms.TextBox
$textBoxIPConfig.Location = New-Object System.Drawing.Point(20,150)
$textBoxIPConfig.Size = New-Object System.Drawing.Size(410, 125)
$textBoxIPConfig.Multiline = $true
$textBoxIPConfig.ReadOnly = $true
$form.Controls.Add($textBoxIPConfig)
$tab1.Controls.Add($textBoxIPConfig)

# Соз. кнопку для запуска получения конфигурации IP.
$buttonGetIPConfig = New-Object System.Windows.Forms.Button
$buttonGetIPConfig.Location = New-Object System.Drawing.Point(20,280)
$buttonGetIPConfig.Size = New-Object System.Drawing.Size(150,20)
$buttonGetIPConfig.Text = "Get IP Config"
$buttonGetIPConfig.Add_Click({
    # Вызовите функцию для получения конфигурации IP.
    $textBoxIPConfig.Text = Get-IPConfig
})
$form.Controls.Add($buttonGetIPConfig)
$tab1.Controls.Add($buttonGetIPConfig)


function Get-IPConfig {
    $ipConfig = Get-NetIPConfiguration | Select-Object -Property InterfaceAlias, IPv4Address, IPv6Address, DefaultGateway

    $output = "InterfaceAlias  
    IPv4Address     
    IPv6Address     
    DefaultGateway`n"
    foreach ($config in $ipConfig) {
        $output += "{0,-15} {1,-15} {2,-15} {3,-15}`n" -f $config.InterfaceAlias, 
        ($config.IPv4Address -join ', '), 
        ($config.IPv6Address -join ', '), 
        ($config.DefaultGateway -join ', ')
    }

    return $output
}

# Соз. кнопку для открытия настроек Ethernet.
$buttonOpenEthernetSettings = New-Object System.Windows.Forms.Button
$buttonOpenEthernetSettings.Location = New-Object System.Drawing.Point(20,310)
$buttonOpenEthernetSettings.Size = New-Object System.Drawing.Size(150,30)
$buttonOpenEthernetSettings.Text = "Ethernet Settings"
$buttonOpenEthernetSettings.Add_Click({
    Start-Process "ms-settings:network-ethernet"
})
$form.Controls.Add($buttonOpenEthernetSettings)
$tab1.Controls.Add($buttonOpenEthernetSettings)

#------------------Disk tab-------------------------
#------------------DiskPart-------------------------

$buttonOpenDiskPart = New-Object System.Windows.Forms.Button
$buttonOpenDiskPart.Location = New-Object System.Drawing.Point(20,20)
$buttonOpenDiskPart.Size = New-Object System.Drawing.Size(150,30)
$buttonOpenDiskPart.Text = "Open DiskPart"
$buttonOpenDiskPart.Add_Click({
    # Вызов функцию для открытия DiskPart.
    Open-DiskPart
})
function Open-DiskPart {
    Start-Process "diskpart.exe"
}
$form.Controls.Add($buttonOpenDiskPart)
$tab2.Controls.Add($buttonOpenDiskPart)

$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(20,55)
$button.Size = New-Object System.Drawing.Size(150,30)
$button.Text = "Get Logical Disk Info"
$button.Add_Click({
    # Обра. события для нажатия кнопки
    ButtonClick
})
$form.Controls.Add($button)
$tab2.Controls.Add($button)

# Соз. функцию для обработки нажатия кнопки
function ButtonClick {
    # Выз. функцию для получения информации о логических дисках
    Get-LogicalDiskInfo
}

function Get-LogicalDiskInfo {
    # Получаем информацию о логических дисках
    $logicalDisks = Get-WmiObject -Class Win32_LogicalDisk

    # Под.текст для сообщения
    $message = "Logical Disk Information:`n`n"
    foreach ($disk in $logicalDisks) {
        $message += "Drive: $($disk.DeviceID)`n"
        $message += "  Volume Name: $($disk.VolumeName)`n"
        $message += "  File System: $($disk.FileSystem)`n"
        $message += "  Size: $($disk.Size / 1GB) GB`n"
        $message += "  Free Space: $($disk.FreeSpace / 1GB) GB`n"
        $message += "  Drive Type: $($disk.DriveType)`n`n"
    }

    # Выв. сообщение с информацией о дисках
    [System.Windows.Forms.MessageBox]::Show($message, "Logical Disk Info", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)
}

#--------------------MEMORY-------------------

$buttonGetMemoryInfo = New-Object System.Windows.Forms.Button
$buttonGetMemoryInfo.Location = New-Object System.Drawing.Point(20,20)
$buttonGetMemoryInfo.Size = New-Object System.Drawing.Size(150,30)
$buttonGetMemoryInfo.Text = "Get Memory Info"
$buttonGetMemoryInfo.Add_Click({
    # Вызов функцию для получения информации о памяти
    Get-MemoryInfo
})
$form.Controls.Add($buttonGetMemoryInfo)
$tab3.Controls.Add($buttonGetMemoryInfo)

function Get-MemoryInfo {
    #Получить общий объем физической памяти
    $totalPhysicalMemory = (Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory
    
    #Получить свободный объем физической памяти
    $freePhysicalMemory = (Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory
    #Рас. доступную память
    $usedMemory = $totalPhysicalMemory - $freePhysicalMemory

    $availableMemory = $freePhysicalMemory

    #Преобразовать значения памяти в гигабайты
    $totalPhysicalMemoryGB = [math]::Round($totalPhysicalMemory / 1GB, 2)
    $availableMemoryGB = [math]::Round($availableMemory / 1GB, 2)
    $usedMemoryGB = [math]::Round($usedMemory / 1GB, 2)
    
    $memoryInfo = "System Memory Information:`n"
    $memoryInfo += "Total Physical Memory: $totalPhysicalMemoryGB GB`n"
    $memoryInfo += "Available Memory: $availableMemoryGB GB`n"
    $memoryInfo += "Used Memory: $usedMemoryGB GB"
    
    
    [System.Windows.Forms.MessageBox]::Show($memoryInfo, "Memory Information", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)
}

$tabControl.TabPages.Add($tab1)
$tabControl.TabPages.Add($tab2)
$tabControl.TabPages.Add($tab3)
$tabControl.TabPages.Add($tab4)


$form.Controls.Add($tabControl)


$form.ShowDialog() | Out-Null
