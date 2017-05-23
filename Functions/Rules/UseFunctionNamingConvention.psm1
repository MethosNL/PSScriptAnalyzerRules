function Measure-FunctionNamingConvention
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
            $FunctionsAst = $ScriptBlock.FindAll( { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true )
            foreach ($FunctionAst in $FunctionsAst)
            {
                if ($FunctionAst.Name -match '^([A-Z])([a-z]+)-([A-Z]{1,1})([a-zA-Z0-9]+)')
                {}
                else
                {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                        "Message"  = "Incorrectly named function based on cmdlet naming conventions"; 
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