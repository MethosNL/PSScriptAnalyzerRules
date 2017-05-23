function Measure-AssignedVariables
{
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
        try
        {
            $VariablesAssignmentAst = $AST.FindAll( { $args[0] -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true ) | Select-Object -Property @{l='Name';e={$_.Left.ToString().TrimStart('$')}}, @{l='Line';e={$_.Extent.StartLineNumber}}
            $VariablesAst = $AST.FindAll( { $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] }, $true ) | Where-Object {$_.extent.tostring() -eq $_.parent.tostring()} | Select-Object -Property @{l='Name';e={$_.Extent.Text.ToString().TrimStart('$')}}, @{l='Line';e={$_.Extent.StartLineNumber}}
            foreach ($Variable in $VariablesAssignmentAst)
            {
                if ($VariablesAst.Name -notcontains $Variable.Name)
                {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
					    Message  = "$($Expression.Name) is assigned at line $($Variable.Line) but never used"
					    Extent   = $Expression.Extent
					    RuleName = $PSCmdlet.MyInvocation.MyCommand.Name.Replace("Measure-","Use");
					    Severity = 'Warning'
				    }
                    
                }
            }
        }
        catch {
            $PSCmdlet.ThrowTerminatingError( $_ )
        }
    }
}
