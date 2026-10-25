# Copy and paste the contents of this into an elevated PowerShell ISE on a domain controller and click the run button
# Configure the outputfolder variable e.g. domain_ghosts
$outputfolder = "domain_ghosts"

mkdir c:\$outputfolder
# Privileged Groups Membership Lists and Counts
$targetgroup = "Administrators"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "Domain Admins"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "Enterprise Admins"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "DNSAdmins"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "Schema Admins"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "Account Operators"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "Backup Operators"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "Print Operators"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "Server Operators"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "Hyper-V Administrators"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "Remote Desktop Users"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "Group Policy Creator Owners"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "Remote Management Users"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "Network Configuration Operators"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt
$targetgroup = "Protected Users"
Get-ADGroupMember -Identity $targetgroup -Recursive > c:\$outputfolder\ad_priv_groups_$targetgroup.txt
Write "Number of users in $targetgroup group:" (Get-ADGroupMember -Identity $targetgroup -Recursive).count >> c:\$outputfolder\ad_priv_groups_count.txt

# Get "Password Never Expires" information
Get-ADUser -Filter {Enabled -eq $True} -properties Name,PasswordNeverExpires | Where-Object {$_.PasswordNeverExpires -eq "True"} > c:\$outputfolder\passwordneverexpires.txt
Get-ADUser -Filter {Enabled -eq $True} -properties Name,PasswordNeverExpires | Where-Object {$_.PasswordNeverExpires -eq "True"} | Measure-object > c:\$outputfolder\passwordneverexpires_count.txt

# Get list of users that have not logged on in over <variable> days
$lastlogondays = "1500"
Get-ADUser -Filter {Enabled -eq $True} -Properties Name,LastLogonDate | Where-Object {$_.LastLogonDate -lt (Get-Date).adddays(-$lastlogondays)} | Select Name,SamAccountName,LastLogonDate > c:\$outputfolder\stale_accounts_1500days.txt
Write "The number of users that last logged on >$lastlogondays days ago:" (Get-ADUser -Filter {Enabled -eq $True} -Properties Name,LastLogonDate | Where-Object {$_.LastLogonDate -lt (Get-Date).adddays(-$lastlogondays)}).count >> c:\$outputfolder\stale_accounts_1500days_count.txt

# Get list of privileged accounts that have not logged into the domain for > 365 days
$lastlogondays = "365"
Get-ADUser -Filter {Enabled -eq $True -and AdminCount -gt 0} -Properties Name,LastLogonDate | Where-Object {$_.LastLogonDate -lt (Get-Date).adddays(-$lastlogondays)} | Select Name,SamAccountName,LastLogonDate > c:\$outputfolder\stale_admin_accounts_365days.txt
Write "The number of privileged users (users with AdminCount=1) that last logged on >$lastlogondays days ago:" (Get-ADUser -Filter {Enabled -eq $True -and AdminCount -gt 0} -Properties Name,LastLogonDate | Where-Object {$_.LastLogonDate -lt (Get-Date).adddays(-$lastlogondays)}).count >> c:\$outputfolder\stale_admin_accounts_365days_count.txt

# Get Password Last Set > 10 years ago. Recommend setting passwordage to whatever your password policy maximum password age is configured to.
$passwordage = "3650"
Get-ADUser -Filter {Enabled -eq $True} -Properties PasswordLastSet | Where-Object {$_.PasswordLastSet -lt (Get-Date).adddays(-$passwordage)} > c:\$outputfolder\password_age_10_years_users.txt
Write "The number of users with a password older than $passwordage days:" (Get-ADUser -Filter {Enabled -eq $True} -Properties PasswordLastSet | Where-Object {$_.PasswordLastSet -lt (Get-Date).adddays(-$passwordage)}).count > c:\$outputfolder\password_age_10_years_users_count.txt
Get-ADUser -Filter {Enabled -eq $True -and AdminCount -gt 0} -Properties PasswordLastSet | Where-Object {$_.PasswordLastSet -lt (Get-Date).adddays(-$passwordage)} > c:\$outputfolder\password_age_10_years_admins.txt
Write "The number of Admin users with a password older than $passwordage days:" (Get-ADUser -Filter {Enabled -eq $True -and AdminCount -gt 0} -Properties PasswordLastSet | Where-Object {$_.PasswordLastSet -lt (Get-Date).adddays(-$passwordage)}).count > c:\$outputfolder\password_age_10_years_admins_count.txt

# Get details for all computer accounts such as LastLogonDate, OperatingSystemVersion, PasswordLastSet and attempt to determine if object is stale based on LastLogonDate and PasswordLastSet > 90 days.
Get-ADComputer -Filter * -Properties OperatingSystem,OperatingSystemVersion,Description,Enabled,LastLogonDate,PasswordLastSet | Select-Object Name,OperatingSystem,OperatingSystemVersion,Description,Enabled,LastLogonDate,PasswordLastSet,DistinguishedName,@{N='Stale';E={($_.LastLogonDate -lt (Get-Date).AddDays(-90)) -and ($_.PasswordLastSet -lt (Get-Date).AddDays(-90))}} | Export-Csv "C:\$outputfolder\AD_allcomputers.csv" -NoTypeInformation
