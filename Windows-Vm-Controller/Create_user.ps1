# create_user.ps1

$Username = "ansadmin"
$Password = ConvertTo-SecureString "test@123" -AsPlainText -Force

# Check if user exists
$UserExists = Get-LocalUser | Where-Object { $_.Name -eq $Username }

if (-not $UserExists) {
    New-LocalUser -Name $Username -Password $Password -FullName "Ansible Admin" -Description "User for Ansible Automation"
    Add-LocalGroupMember -Group "Administrators" -Member $Username
    Write-Output "User $Username created and added to Administrators."
} else {
    Write-Output "User $Username already exists."
}
