function Measure-ParameterDocumentation
{
<#
.SYNOPSIS
    Finds functions missing parameter documentation for any of their parameters
.EXAMPLE
    Measure-MissingParameterDocumentation -ScriptBlockAst $ScriptBlockAst
.PARAMETER ScriptBlockAst
    ScriptBlockAst to analyze
.INPUTS
    [System.Management.Automation.Language.ScriptBlockAst]
.OUTPUTS
    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
.NOTES
    None
#>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScriptBlockAst
    )

    begin 
    {
    }

    Process
    {
        $results = @()
        try
        {
            # Finds param block
            [ScriptBlock]$ParamBlockPredicate = {
                param 
                (
                    [System.Management.Automation.Language.Ast]$Ast
                )
                [bool]$ReturnValue = $false

                if ($Ast -is [System.Management.Automation.Language.ParamBlockAst])
                {

                    $ReturnValue = $true;

                }
                return $ReturnValue
            }

            # Finds dynamicparam block
            [ScriptBlock]$DynamicParamBlockPredicate = {
                param 
                (
                    [System.Management.Automation.Language.Ast]$Ast
                )
                [bool]$ReturnValue = $false

                if ($Ast -is [System.Management.Automation.Language.NamedBlockAst])
                {
                    [System.Management.Automation.Language.NamedBlockAst]$NamedBlockAst = $Ast

                    if ($NamedBlockAst.BlockKind -eq [System.Management.Automation.Language.TokenKind]::Dynamicparam)
                    {
                        $ReturnValue = $true;
                    }

                }
                return $ReturnValue
            }

            # Finds command element block
            [ScriptBlock]$PipelineAstPredicate = {
                param 
                (
                    [System.Management.Automation.Language.Ast]$Ast
                )
                [bool]$ReturnValue = $false

                if ($Ast -is [System.Management.Automation.Language.PipelineAst])
                {
                    $ReturnValue = $true;
                }
                return $ReturnValue
            }

            # Finds function block
            [ScriptBlock]$FunctionPredicate = {
                param 
                (
                    [System.Management.Automation.Language.Ast]$Ast
                )
                [bool]$ReturnValue = $false

                if ($Ast -is [System.Management.Automation.Language.FunctionDefinitionAst])
                {
                    $ReturnValue = $true;
                }
                return $ReturnValue
            }


            [System.Management.Automation.Language.Ast[]]$FunctionBlockAsts = $ScriptBlockAst.FindAll($FunctionPredicate, $true)

            foreach ($Ast in $FunctionBlockAsts)
            {
                [System.Management.Automation.Language.FunctionDefinitionAst]$FunctionAst = $Ast;

                # get parameters in help already
                [System.Management.Automation.Language.CommentHelpInfo]$Help = $FunctionAst.GetHelpContent()
                $ParametersInHelp = $Help.Parameters.Keys


                $ParametersInFunction = @()

                # get static params
                [System.Management.Automation.Language.Ast[]]$ParamBlockAsts = $FunctionAst.FindAll($ParamBlockPredicate,$true)

                foreach ($Ast2 in $ParamBlockAsts)
                {
                    [System.Management.Automation.Language.ParamBlockAst]$ParamBlockAst = $Ast2

                    foreach ($ParamAst in $ParamBlockAst.Parameters)
                    {
                        $ParametersInFunction += $ParamAst.Name.VariablePath.UserPath
                    }
                }

                # get dynamic params
                [System.Management.Automation.Language.Ast[]]$DynamicParamBlockAsts = $FunctionAst.FindAll($DynamicParamBlockPredicate,$true)

                foreach ($Ast3 in $DynamicParamBlockAsts)
                {
                    $Script = $Ast3.statements -join "`n"
                    $DynamicParamBlockScriptBlock = [ScriptBlock]::Create($script)
                    $RuntimeDictionary = Invoke-Command -Scriptblock $DynamicParamBlockScriptBlock
                    foreach ($Param in $RuntimeDictionary.Keys)
                    {
                        $ParametersInFunction += $Param
                    }

                }

                # check params against help params              
                foreach ($FunctionParam in $ParametersInFunction)
                {
                    if ($null -eq $ParametersInHelp -or $ParametersInHelp -inotcontains $FunctionParam)
                    {
                        $Result = [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{"Message"  = "Function missing .PARAMETER documentation for parameter '$FunctionParam'"; 
                                                    "Extent"   = $Ast.Extent;
                                                    "RuleName" = $PSCmdlet.MyInvocation.MyCommand.Name.Replace("Measure-","Use");
                                                    "Severity" = "Warning"}
                        $Results += $Result    
                    }
                }
            }

            return $results
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
}