function Measure-ApprovedVerbs
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
            $FunctionsAst = $ScriptBlockAst.FindAll( { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true )
            foreach ($FunctionAst in $FunctionsAst)
            {
                $Verbs = (Get-Verb).Verb
                'Get-Jeff2Wout3ers' -match '^([A-Z])([a-z]+)-'
                $MatchedVerb = $matches[0] -replace '-',''
                if ($Verbs -notcontains $MatchedVerb)
                {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        "Message"  = "Unapproved verb used in function name"; 
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