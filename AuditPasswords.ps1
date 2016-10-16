Import-Module -Name $PSScriptRoot\ADPolicyAudit -Force

#Change the following for the expected password compliance values for your environment
$myargs = @{
ComputerName          = "DSDC01","DSDC02" # array of computernames
PassHistoryCount      = 10                # Number of remembered passwords
PassUnlockoutMins     = 30                # Number of minutes before password is unlocked
FailedLogonsAllowed   = 4                 # Allowed Failed Logons
PassLength            = 15                # Required password length
PassMinAgeDays        = 4                 # Minimum age of password in days
PassMaxAgeDays        = 10                # Maximum age of password in days
ObservationWindowMins = 20                # Number of 
}

# view the Password Policy and Lockout of a server, uncommenting the following
# Get-PasswordLockoutPolicy -ComputerName "DC1","DC2"

# If an email server is not available use the following to display the results to the console
# To keep results in an object, use Test-PasswordAuditResults @myargs
# $failedComputers = Test-PasswordAuditResults @myargs
# Send-PasswordCompliance -FailedComputers $failedComputers

$failedComputers = Test-PasswordAuditResults @myargs

Send-PasswordCompliance -FailedComputers $failedComputers -To jerry.seinfeld@mycompany.com -SMTP smtp.mycompany.com

