#Cloning the HES GitHub repository
cd C:\
md Hideez
cd Hideez
git clone https://github.com/HideezGroup/HES src
cd src\HES.Web


#Install MySQL
#https://dev.mysql.com/downloads/file/?id=492455

# downlozd zip
#https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.19-winx64.zip

$url = "https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.19-winx64.zip"
$output = "$PSScriptRoot\mysql-8.0.19-winx64.zip"
$start_time = Get-Date

#Invoke-WebRequest -Uri $url -OutFile $output
Invoke-WebRequest -Uri $url -OutFile $output


Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"


Expand-Archive -LiteralPath $output -DestinationPath "C:\Program Files\MySQL"
Move-Item  "C:\Program Files\MySQL\mysql-8.0.19-winx64\*"  "C:\Program Files\MySQL"

