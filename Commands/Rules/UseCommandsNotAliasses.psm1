function Measure-CommandsNotAliasses
{
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )
    Process
    {
        $results = @()
        try
        {
            $Aliasses = Get-Alias
            $Commands = ($ScriptBlock.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandBaseAst] },$true))
            foreach ($Command in $Commands)
            {
                if ($Aliasses.Name -contains $Command.Extent.Text)
                {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        "Message"  = "Alias $($Command.extent.text) instead of command $($Aliasses | Where-Object {$_.name -eq $Command.extent.text}) is used"; 
                        "Extent"   = $Function.Extent;
                        "RuleName" = $PSCmdlet.MyInvocation.MyCommand.Name.Replace("Measure-","Use");
                        "Severity" = "Warning"
                    }
                }
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}