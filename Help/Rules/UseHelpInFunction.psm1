function Test-HelpInFunction
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
            $Functions = $ScriptBlockAst.FindAll( { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true )

            foreach ($Function in $Functions)
            {
                # get help
                $Help = $Function.GetHelpContent()
                # test for help
                if ($Help -eq $null)
                {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        "Message"  = "Help missing in function"; 
                        "Extent"   = $Function.Extent;
                        "RuleName" = "HelpInFunction"
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