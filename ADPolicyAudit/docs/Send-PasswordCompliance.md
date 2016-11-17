---
external help file: ADPolicyAudit-help.xml
online version: 
schema: 2.0.0
---

# Send-PasswordCompliance

## SYNOPSIS
Formats and Email with Password Audit of a Server or to the console in a pretty format.

## SYNTAX

```
Send-PasswordCompliance [-To <Object>] [-SMTP <Object>] -FailedComputers <Object>
```

## DESCRIPTION
For servers that are not in compliance with the password policies
and lockout policies, will send an email with the names of the
attributes that are out of compliance

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Send-PasswordCompliance -To jerry.seinfeld@mycompany.com -CompObj $Comps -SMTP smtp.mycompany.com
```

## PARAMETERS

### -To
Recipient of the compliance results

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SMTP
SMTP Server used to send email

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FailedComputers
Custom object containing computers and their password compliance results

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
Sends to console in a pretty format.
To keep results in objects, use Test-PasswordAuditResults

## RELATED LINKS

