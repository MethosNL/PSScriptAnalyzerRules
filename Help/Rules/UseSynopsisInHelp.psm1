function Test-SynopsisInHelp
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
                [System.Management.Automation.Language.CommentHelpInfo]$Help = $Function.GetHelpContent()
                # test for synopsis
                if ($Help.synopsis -eq $null)
                {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        "Message"  = "Synopsis missing from help"; 
                        "Extent"   = $Function.Extent;
                        "RuleName" = "SynopsisInHelp"
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