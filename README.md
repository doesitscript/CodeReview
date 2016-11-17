# CodeReview: ADPolicyAUdit Release (1.0)
Validates a password policy of a domain.

https://www.powershellgallery.com/packages/ADPolicyAudit/1.0

### Download and Install ADPolicyAudit using the PowerShellGallery. 

	Install-Module -Name ADPolicyAudit

### Download the latest release (1.0)
https://github.com/proxb/PoshRSJob/archive/master.zip

### Examples
####view the Password Policy and Lockout of a server, uncommenting the following
	Get-PasswordLockoutPolicy -ComputerName "DC1","DC2"  

#### Test the compliance of your environment
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
	Test-PasswordAuditResults @myargs

#### Send the results in a pretty format to your boss.
	Send-PasswordCompliance -FailedComputers (Test-PasswordAuditResults @myargs) -To jerry.seinfeld@mycompany.com -SMTP smtp.mycompany.com
	