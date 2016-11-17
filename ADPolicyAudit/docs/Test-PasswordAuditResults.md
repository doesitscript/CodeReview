---
external help file: ADPolicyAudit-help.xml
online version: 
schema: 2.0.0
---

# Test-PasswordAuditResults

## SYNOPSIS
Audits Servers for password policy and sends results to email

## SYNTAX

```
Test-PasswordAuditResults [-ComputerName] <Object> -PassHistoryCount <Object> -PassUnlockoutMins <Object>
 -FailedLogonsAllowed <Object> -PassLength <Object> -PassMinAgeDays <Object> -PassMaxAgeDays <Object>
 -ObservationWindowMins <Object>
```

## DESCRIPTION
Compares password policy to password requirements of an organization.
If any password requirement(s) does not match, they are sent to an
output stream such as an email server, slack channel (future),
reporting server (future).

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
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
```
## PARAMETERS

### -ComputerName
Server to Audit

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -PassHistoryCount
Password to remember before user can reuse a previous password

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PassUnlockoutMins
Number of minutes that a password will be unlocked after being locked

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FailedLogonsAllowed
Number of failed logon attempts allowed

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PassLength
Minimum Number of characters that a password has to be

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PassMinAgeDays
Minimum age of a password in days

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PassMaxAgeDays
Maximum age of a password in days

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ObservationWindowMins
lockOutObservationWindow

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

