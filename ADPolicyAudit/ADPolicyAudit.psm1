<#
.Synopsis
   Returns server password/lockout policy and lockout for a server
.DESCRIPTION
   Gets the server password/lockout policy for one or several servers.
   For times, a timespan object is returned. For non, time related
   fields, an integer is returned.
.PARAMETER ComputerName
   Name of a computer to get password policy and lockout policy
.EXAMPLE
   Get-PasswordLockoutPolicy -ComputerName DC01
.NOTES
   None
#>
function Get-PasswordLockoutPolicy
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param
    (
        # ComputerName to process policy
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $ComputerName
    )

    Begin
    {
    }
    Process
    {
        foreach ($Computer in $ComputerName)
        {
            try{
                $domNamingContext = Get-ADRootDSE -Server $Computer -ErrorAction Stop # get default domain naming context of server
				
                $props = @('minPwdAge','maxPwdAge','minPwdLength','pwdHistoryLength',
                           'lockoutThreshold','lockoutDuration','lockOutObservationWindow')

                # get password properties for domain that server is in. 
                $pwdProps = Get-ADObject -Identity $domNamingContext.rootDomainNamingContext -Properties $props |
                            Select-Object -Property $props 

                # convert "ticks" to Time-Spans.
                $obj = @{ ComputerName           = $Computer
						  PassMinAgeDays         = (New-TimeSpan -Start (get-date).AddTicks($pwdProps.minPwdAge) -End (get-date)).Days
                          PassMaxAgeDays         = (New-TimeSpan -Start (Get-Date).AddTicks($pwdProps.maxPwdAge) -End (Get-Date)).Days
                          PassLength             = $pwdProps.minPwdLength
                          PassHistoryCount       = $pwdProps.pwdHistoryLength
                          FailedLogonsAllowed    = $pwdProps.lockoutThreshold
                          PassUnlockoutMins      = (New-TimeSpan -Start (Get-Date).AddTicks($pwdProps.lockoutDuration) -End (Get-Date)).Minutes
                          ObservationWindowMins  = (New-TimeSpan -Start (get-date).AddTicks($pwdProps.lockOutObservationWindow) -End (get-date)).Minutes 
                        } # end obj

                New-Object -TypeName psobject -Property $obj
            } catch {
                $Error[0]
            } #end try/catch
        } # end foreach-object
    } # end process
    End
    {
    }
} # end Get-PasswordLockoutPolicy

<#
.Synopsis
   Audits Servers for password policy and sends results to email
.DESCRIPTION
   Compares password policy to password requirements of an organization.
   If any password requirement(s) does not match, they are sent to an
   output stream such as an email server, slack channel (future),
   reporting server (future).
.PARAMETER ComputerName
   Server to Audit
.PARAMETER SmtpServer
   SmtpServer to use for email 
.PARAMETER PassHistoryCount
   Password to remember before user can reuse a previous password 
.PARAMETER LockoutTime
   TimeSpan that User should be locked out 
.PARAMETER FailedLogonsAllowed
   Number of failed logon attempts allowed
.PARAMETER PassLength
   Minimum Number of characters that a password has to be
.PARAMETER PassMinAgeDays
   Minimum age of a password in days
.PARAMETER PassMaxAgeDays
   Maximum age of a password in days 
.PARAMETER PassUnlockoutMins
   Number of minutes that a password will be unlocked after being locked
.EXAMPLE
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
   Return compliance results of server DSDC01 and DSDC02
#>
function Test-PasswordAuditResults
{
    [CmdletBinding()]
    Param
    (
        # Server to test password compliance
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $ComputerName,

        # pwdHistoryLength
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $PassHistoryCount,

        # lockoutDuration
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $PassUnlockoutMins,

        # lockoutThreshold
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $FailedLogonsAllowed,

        # minPwdLength
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $PassLength,

        # minPwdAge
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $PassMinAgeDays,

        # maxPwdAge
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $PassMaxAgeDays,

        # lockOutObservationWindow
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $ObservationWindowMins
    )

    Begin
    {
		# Get the lockout policy for an array of computers
		$effectiveServerPolicy = Get-PasswordLockoutPolicy -ComputerName $ComputerName
    }
    Process
    {
		# create template object computer results to be added to
		$compObj = New-Object -TypeName psobject -Property @{
												             ComputerName    = ""
													         IsCompliant     = $false
															 PassCompliance  = @{}
												} #end property
        $compObj = @()

		# filter out results. when policy is different than desired policy, include in results 
		foreach ($policy in $effectiveServerPolicy) 
		{
			
			$IsCompliant = $true # overall compliance of the node
			$obj = @{					 
					 PassMinAgeDaysCompliant        = $true
					 PassMaxAgeDaysCompliant        = $true
					 PassLengthCompliant            = $true
					 PassHistoryCountCompliant      = $true
					 FailedLogonsAllowedCompliant   = $true
					 PassUnlockoutMinsCompliant     = $true
					 ObservationWindowMinsCompliant = $true
					} #close obj
			if ($policy.PassMinAgeDays -ne (New-TimeSpan -Days $PassMinAgeDays)) {
				$obj.PassMinAgeDaysCompliant = $false
				$IsCompliant = $false
			} #end if
			if ($policy.PassMaxAgeDays -ne (New-TimeSpan -Days $PassMaxAgeDays)) {
				$obj.PassMaxAgeDaysCompliant = $false
				$IsCompliant = $false
			} #end if
			if ($policy.PassLength -ne $PassLength) {
				$obj.PassLengthCompliant = $false
				$IsCompliant = $false
			} #end if
			if ($policy.PassHistoryCount -ne $PassHistoryCount) {
				$obj.PassHistoryCountCompliant = $false
				$IsCompliant = $false
			} #end if
			if ($policy.FailedLogonsAllowed -eq $FailedLogonsAllowed){
				$obj.FailedLogonsAllowedCompliant = $false
				$IsCompliant = $false
			} #end if
			if ($policy.PassUnlockoutMins -ne (New-TimeSpan -Minutes $PassUnlockoutMins)){
				$obj.PassUnlockoutMinsCompliant = $false
				$IsCompliant = $false
			} #end if
			if ($policy.ObservationWindowMins -ne (New-TimeSpan -Minutes $ObservationWindowMins)) {
				$obj.ObservationWindowMinsCompliant = $false
				$IsCompliant = $false
			} #end if

			#add results of current computer to final result
            if (-not $IsCompliant) {
			    $compObj += New-Object -TypeName psobject -Property @{Computername   = $policy.ComputerName
																       IsCompliant    = $IsCompliant
																       PassCompliance = $obj
                                                                      } #close prop
			} #end if
		} #end foreach

		$compObj
    } #end process
    End
    {
    }
}

<#
.Synopsis
  Formats and Email with Password Audit of a Server or to the console in a pretty format.
.DESCRIPTION
  For servers that are not in compliance with the password policies
  and lockout policies, will send an email with the names of the
  attributes that are out of compliance
.PARAMETER To
  Recipient of the compliance results
.PARAMETER SMTP
  SMTP Server used to send email
.PARAMETER FailedComputers
  Custom object containing computers and their password compliance results
.NOTES
  Sends to console in a pretty format. To keep results in objects, use Test-PasswordAuditResults
.EXAMPLE
  Send-PasswordCompliance -To jerry.seinfeld@mycompany.com -CompObj $Comps -SMTP smtp.mycompany.com
#>
function Send-PasswordCompliance
{
    [CmdletBinding()]
    param
    (
        # email address to send to
        [Parameter(Mandatory=$false, 
			       ValueFromPipelineByPropertyName=$true,
				   ParameterSetName='Email')]
        $To,

        # SMTP Server
        [Parameter(Mandatory=$false, 
			       ValueFromPipelineByPropertyName=$true,
				   ParameterSetName='Email')]
        $SMTP,

        # Computer objects with compliance results
        [Parameter(Mandatory=$true, 
			       ValueFromPipelineByPropertyName=$true)]
        $FailedComputers
	)
        Begin
        {
          
        }

        Process
        {
			#create body of email
			$complianceReport = @"
         ServerResults                 Compliance
---------------------------        ---------------

"@
			#add only items that are not in compliance to report. Parse hash table
			foreach ($computer in $FailedComputers)
			{
				#format here string
				$complianceReport += $computer.Computername
				if (-not ($computer.PassCompliance)['PassMinAgeDaysCompliant'])        { $complianceReport += "`nPassMinAgeDaysCompliant               $(($computer.PassCompliance)['PassMinAgeDaysCompliant'])"}
				if (-not ($computer.PassCompliance)['PassMaxAgeDaysCompliant'])        { $complianceReport += "`nPassMaxAgeDaysCompliant               $(($computer.PassCompliance)['PassMaxAgeDaysCompliant'])"}
				if (-not ($computer.PassCompliance)['ObservationWindowMinsCompliant']) { $complianceReport += "`nObservationWindowMinsCompliant        $(($computer.PassCompliance)['ObservationWindowMinsCompliant'])"}
				if (-not ($computer.PassCompliance)['PassLengthCompliant'])            { $complianceReport += "`nPassLengthCompliant                   $(($computer.PassCompliance)['PassLengthCompliant'])"}
				if (-not ($computer.PassCompliance)['FailedLogonsAllowedCompliant'])   { $complianceReport += "`nFailedLogonsAllowedCompliant          $(($computer.PassCompliance)['FailedLogonsAllowedCompliant'])"}
				if (-not ($computer.PassCompliance)['PassHistoryCountCompliant'])      { $complianceReport += "`nPassHistoryCountCompliant             $(($computer.PassCompliance)['PassHistoryCountCompliant'])"}
				if (-not ($computer.PassCompliance)['PassUnlockoutMinsCompliant'])     { $complianceReport += "`nPassUnlockoutMinsCompliant            $(($computer.PassCompliance)['PassUnlockoutMinsCompliant'])"}
				$complianceReport += "`n`n"
			} #end foreach

			switch ($pscmdlet.ParameterSetName) {
				'Email' {
					Send-MailMessage -Body $complianceReport -SmtpServer $SMTP -To $To -From noreply@mycompany.com -Subject "Failed Password Policies"
					break
				} #end email
				Default { $complianceReport } #sends to console in a pretty format. To keep in objects, use Test-PasswordAuditResults
			}
			
    } #end Process
    End
    {

    }
} #end Send-PasswordCompliance