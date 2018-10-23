# Local Network Utility Configurator

# Script References & Configuration Variables
$IconOKLocation = ".\icon-ok.ico"
$ExternalTestingHost = "www.azure.microsoft.com"

# Generate Form
[void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
$Form = New-Object System.Windows.Forms.form
$NotifyIcon= New-Object System.Windows.Forms.NotifyIcon
$ContextMenu = New-Object System.Windows.Forms.ContextMenu

$iconOK = New-Object System.Drawing.Icon($IconOKLocation)

$Button_CloseApplication = New-Object System.Windows.Forms.MenuItem
$Button_RunTests = New-Object System.Windows.Forms.MenuItem


# Configure Form Display
$Form.ShowInTaskbar = $false
$Form.WindowState = "minimized"

# Configure Taskbar Items
$NotifyIcon.Icon =  $iconOk
$NotifyIcon.ContextMenu = $ContextMenu
$NotifyIcon.Visible = $True
$NotifyIcon.Text = "Network Utility is Loading Please wait..."

# Configure Taskbar Item Componets
$NotifyIcon.ContextMenu.MenuItems.AddRange($Button_RunTests)
$NotifyIcon.ContextMenu.MenuItems.AddRange($Button_CloseApplication)


# Configure Right-Click Menu Items

$Button_CloseApplication.Text = "Exit"
$Button_CloseApplication.add_Click({
    $NotifyIcon.Visible = $False
    $Form.Close()
    exit
})
$Button_RunTests.Text = "Run Network Tests"
$Button_RunTests.add_Click({

    Get-NetworkPerformce

})


# Reference Functions for Script Operations
function Get-NetworkPacketLoss{
    param(
        $TargetDestination
    )

    $No_Of_TestPackets = 25
    $Total_Responces = Test-Connection $TargetDestination -Count $No_Of_TestPackets -ErrorAction SilentlyContinue

    $Percent_Loss = ($Total_Responces).Count / $No_Of_TestPackets
    
    return $Percent_Loss
}
Function Get-AvgPingTime{
    param(
        $TargetDestination
    )
    $No_Of_TestPackets = 4

    $Results = Test-Connection $TargetDestination -Count $No_Of_TestPackets

    $Results = $Results | Select-Object -Property ResponseTime | Measure-Object -Sum ResponseTime
    $Results = $Results / $No_Of_TestPackets

    return $Results

}
function Get-NetworkType{

    $Result = $(Get-NetIPConfiguration | Select-Object -Property InterfaceAlias)[0]

    return $Result.InterfaceAlias
}
function Get-NetworkUploadSpeed{
    # you need code to find the upload speed. this will require a destination to upload a file too and calulcate total time required
    return "Speed Service not Intialized"
}
function Get-NetworkDownloadSpeed{
    # you need code to find the download speed. this will require a destination to download a file from and calulcate total time required
    return "Speed Service not Intialized"
}
function Get-CurrentISP{
    # you will need a service to query inorder to Geolocate / ISP identify your external IP address.
    return "ISP Detection Service not Intialized"
}
function Get-NetworkPerformce {
    $NotifyIcon.Text = "Collecting Network Statistics... Step 0 of 10 Compleated"
    # Get's the Network gateway of the first network device listed in the system
    $IP_Address_Gateway = $(Get-NetIPConfiguration | ForEach-Object IPv4DefaultGateway).NextHop.split("{`n}")[0]
    $NotifyIcon.Text = "Collecting Network Statistics... Step 1 of 10 Compleated"
    # Get's the IP address of the external network host for testing agianst
    $IP_Address_Extern = ([System.Net.Dns]::GetHostByName($ExternalTestingHost).AddressList[0]).IpAddressToString
    $NotifyIcon.Text = "Collecting Network Statistics... Step 2 of 10 Compleated"

    # Collect the required Network Data for the tooltip display

    $PacketLoss_Gateway = Get-NetworkPacketLoss -TargetDestination $IP_Address_Gateway
    $NotifyIcon.Text = "Collecting Network Statistics... Step 3 of 10 Compleated"

    $PacketLoss_Extern = Get-NetworkPacketLoss -TargetDestination $IP_Address_Extern
    $NotifyIcon.Text = "Collecting Network Statistics... Step 4 of 10 Compleated"

    $PingTime_Gateway = Get-AvgPingTime -TargetDestination $IP_Address_Gateway
    $NotifyIcon.Text = "Collecting Network Statistics... Step 5 of 10 Compleated"

    $PingTime_Extern = Get-AvgPingTime -TargetDestination $IP_Address_Extern
    $NotifyIcon.Text = "Collecting Network Statistics... Step 6 of 10 Compleated"

    $Connection_Type = Get-NetworkType
    $NotifyIcon.Text = "Collecting Network Statistics... Step 7 of 10 Compleated"

    $Connection_Speed_up = Get-NetworkUploadSpeed
    $NotifyIcon.Text = "Collecting Network Statistics... Step 8 of 10 Compleated"

    $Connection_Speed_Down = Get-NetworkDownloadSpeed
    $NotifyIcon.Text = "Collecting Network Statistics... Step 9 of 10 Compleated"

    $Current_ISP = Get-CurrentISP
    $NotifyIcon.Text = "Collecting Network Statistics... Step 10 of 10 Compleated"

    [System.Windows.Forms.MessageBox]::Show(@" 
Current Gateway Packet Loss     : $PacketLoss_Gateway %
Current External Packet Loss    : $PacketLoss_Extern %
Current Avg Gateway Ping Time   : $PingTime_Gateway ms
Current Avg External Ping Time  : $PingTime_Extern ms
Current Connection Type is      : $Connection_Type
Current Connection Upload       : $Connection_Speed_Up
Current Connection Download     : $Connection_Speed_Down
Current ISP                     : $Current_ISP
"@)

$NotifyIcon.Text = "Run Network Tests for Details..."
    
}

# Run the Form
[void][System.Windows.Forms.Application]::Run($Form)
