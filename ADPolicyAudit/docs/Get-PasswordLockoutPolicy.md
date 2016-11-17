---
external help file: ADPolicyAudit-help.xml
online version: 
schema: 2.0.0
---

# Get-PasswordLockoutPolicy

## SYNOPSIS
Returns server password/lockout policy and lockout for a server

## SYNTAX

```
Get-PasswordLockoutPolicy [-ComputerName] <Object> [-WhatIf] [-Confirm]
```

## DESCRIPTION
Gets the server password/lockout policy for one or several servers.
For times, a timespan object is returned.
For non, time related
fields, an integer is returned.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-PasswordLockoutPolicy -ComputerName DC01
```

## PARAMETERS

### -ComputerName
Name of a computer to get password policy and lockout policy

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
None

## RELATED LINKS

