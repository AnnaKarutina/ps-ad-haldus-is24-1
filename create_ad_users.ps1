function translit {
    param(
        [string]$inputString
    )
    $Translit = @{
        [char]'ä' = 'a'
        [char]'ö' = 'o'
        [char]'ü' = 'u'
        [char]'õ' = 'o'
    }
    $outputString = ''

    foreach($character in $inputString.ToCharArray()){
        if($Translit[$character] -ne $null){
            $outputString = $outputString + $Translit[$character]
        } else {
            $outputString = $outputString + $character
        } 
    }
    Write-Output $outputString
}

$users = Import-Csv "C:\Users\Administrator\ps_haldus\adusers.csv" -Encoding Default -Delimiter ";"
foreach ($user in $users) {
    $username = $user.FirstName.ToLower() + "." + $user.LastName.ToLower()
    $username = translit($username)
    $displayname = $user.FirstName + " " + $user.LastName
    $upname = $username + "@sv-kool.local"
    $password = $user.Password | ConvertTo-SecureString -AsPlainText -Force

    $userExists = Get-ADUser -Filter {(whencreated -ge $sma)} | Select-Object Name | Where {$_.Name -like $username}
    if($userExists -eq $null) {
        New-ADUser -Name $username `
                   -DisplayName $displayname `
                   -GivenName $user.FirstName `
                   -Surname $user.LastName `
                   -Department $user.Department `
                   -UserPrincipalName $upname `
                   -Title $user.Role `
                   -AccountPassword $password `
                   -Enabled $true
        Write-Host $username "is created"
   } else {
        Write-Host $username "already exists"
   }
}