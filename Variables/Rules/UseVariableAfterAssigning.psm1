function Measure-UseVariableAfterAssigning
{
    <#
    .NOTES
    Created by Thomas Rayner
    Original from: https://github.com/ThmsRynr/CustomPSSARules
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param
    (
        [Parameter(
            Mandatory=$true,
            Position=1
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]$ScriptBlockAst
    )
    process
    {
        [string[]]$AutomaticVariables = (Get-Variable).name
        try
        {
			$ParametersAst = $ScriptBlockAst.FindAll( { $args[0] -is [System.Management.Automation.Language.ParamBlockAst] }, $true )
            $VariablesAssignmentAst = $ScriptBlockAst.FindAll( { $args[0] -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true )

            $Parameters = $ParametersAst.Parameters | Select-Object -Property @{l='Name';e={$_.Name.VariablePath.UserPath}}, @{l='Line';e={$_.Extent.StartLineNumber}}
            $Variables = $variablesAssignmentAst | Select-Object -Property @{l='Name';e={$_.Left.ToString().TrimStart('$')}}, @{l='Line';e={$_.Extent.StartLineNumber}}

            $Assigned = New-Object System.Collections.ArrayList
            foreach ($Parameter in $Parameters)
            {
                $Add = @{
                    'Name' = $Parameter.Name.ToString()
                    'Line' = [int]$Parameter.Line.ToString()
                }
                [void]($Assigned.Add( ( New-Object PSObject -Property $Add ) ))
            }
            foreach ($Variable in $Variables)
            {
                $Add = @{
                    'Name' = $var.Name.ToString()
                    'Line' = [int]$var.Line.ToString()
                }
                [void]($Assigned.Add(( New-Object PSObject -Property $Add )))
            }
            $Assigned = $Assigned | Sort-Object -Property Line

            $ExpressionsAst = $ScriptBlockAst.FindAll( { $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] }, $true )
            $Expressions = $ExpressionsAst | Select-Object -Property @{n='Name';e={$_.VariablePath.Userpath}}, @{l='Line';e={$_.Extent.StartLineNumber}}, Extent

            foreach ($Expression in $Expressions )
            {
                if (($Expression.Name.ToString() -notin $Assigned.Name) -and ($Expression.Name.ToString() -notin $AutomaticVariables))
                {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
					    Message  = "$($Expression.Name) is used before it is assigned a value"
					    Extent   = $Expression.Extent
					    RuleName = $PSCmdlet.MyInvocation.MyCommand.Name.Replace("Measure-","Use");
					    Severity = 'Warning'
				    }
                }
                else
                {
                    $Line = [int]$Exp.Line.ToString()
                    $AssignsAfter = @($Assigned | Where-Object { ( $_.Name -eq $Expression.Name.ToString() ) -and ( $_.Line -gt $Line ) })
                    $AssignsBefore = @($Assigned | Where-Object { ( $_.Name -eq $Expression.Name.ToString() ) -and ( $_.Line -lt $Line ) })

                    if ((-not $AssignsBefore) -and ($AssignsAfter))
                    {
                        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
					        Message  = "$($Expression.Name) is used before it is assigned a value"
					        Extent   = $Expression.Extent
					        RuleName = $PSCmdlet.MyInvocation.MyCommand.Name.Replace("Measure-","Use");
					        Severity = 'Warning'
				        }
                    } 
                }
            }
        }
        catch {
            $PSCmdlet.ThrowTerminatingError( $_ )
        }
    }
}
