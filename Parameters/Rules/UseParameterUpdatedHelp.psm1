function Measure-ParameterUpdatedHelp
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
                $ParametersAst = $FunctionAst.FindAll( {$args[0] -is [System.Management.Automation.Language.ParamBlockAst]}, $true)
                $Parameters = $ParametersAst.parameters.name.ToString() | ForEach-Object { $_.replace('$','')}
                $HelpParameters = $ScriptBlockAst.GetHelpContent().Parameters.Keys
                foreach ($Parameter in $Parameters)
                {
                    if ($HelpParameters -notcontains $Parameter)
                    {
                        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                            "Message"  = "Parameter $HelpParameter not documented in help"; 
                            "Extent"   = $Function.Extent;
                            "RuleName" = $PSCmdlet.MyInvocation.MyCommand.Name.Replace("Measure-","Use");
                            "Severity" = "Warning"
                        }
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