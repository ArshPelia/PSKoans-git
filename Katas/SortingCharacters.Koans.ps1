using module PSKoans
using namespace System.Collections.Generic
using namespace System.Management.Automation.Language
[Koan(Position = 151)]
param()

<#
    Kata: Sorting Characters

    Sorting is a fairly common task in programming. In PowerShell, the Sort-Object cmdlet will typically
    be used to sort items.

    For the purposes of this kata, cmdlets will be removed from your toolkit.

    Using only native PowerShell expressions (values, operators, and keywords), implement a function that
    sorts all characters in a string alphabetically. Punctuation and spaces should be ignored entirely.
#>
Describe 'Kata - Sorting Characters' {

    BeforeAll {
        $Verification = {
            $Functions = [Hashset[string]]::new([StringComparer]::OrdinalIgnoreCase)
            $Ast = (Get-Command 'Get-SortedString' -CommandType Function).ScriptBlock.Ast
            $Ast.FindAll(
                {
                    param($node)
                    if ($node -is [CommandAst] -and ($name = $node.GetCommandName()) -and !$Functions.Contains($name)) {
                        throw 'Usage of external cmdlets and functions is not permitted.'
                    }

                    if ($node -is [FunctionDefinitionAst]) {
                        $Functions.Add($node.Name) > $null
                        return
                    }

                    if ($node.Left -is [VariableExpressionAst] -and $node.Left.VariablePath.DriveName -eq 'Function') {
                        $Functions.Add($node.Left.VariablePath.UserPath -replace '^function:') > $null
                    }
                }, $true
            )
        }

function Get-SortedString {
    param($String)

    # Step 1: Filter out non-alphabet characters
    $filteredChars = @()
    foreach ($char in $String.ToCharArray()) {
        if ($char -match '[a-zA-Z]') {
            $filteredChars += [string]::new($char).ToLower()  # Convert char to string and then to lowercase
        }
    }

    # Step 2: Manually sort the characters in $filteredChars array
    for ($i = 0; $i -lt $filteredChars.Length; $i++) {
        for ($j = $i + 1; $j -lt $filteredChars.Length; $j++) {
            if ($filteredChars[$i] -gt $filteredChars[$j]) {
                # Swap characters if they are out of order
                $temp = $filteredChars[$i]
                $filteredChars[$i] = $filteredChars[$j]
                $filteredChars[$j] = $temp
            }
        }
    }

    # Step 3: Join sorted characters into a single string
    return -join $filteredChars
}

    }

    <#
        Feel free to add extra It/Should tests here to write additional tests for yourself and
        experiment along the way!
    #>

    It 'should not use any cmdlets or external commands' {
        $Verification | Should -Not -Throw -Because 'You must rely on your own knowledge here.'
    }

    It 'should give the right result when inputting: <String>' {
        param( $String, $Result )

        Get-SortedString $String | Should -BeExactly $Result
    } -TestCases @(
        @{
            String = 'Mountains are merely mountains.'
            Result = 'aaaeeeiilmmmnnnnoorrssttuuy'
        }
        @{
            String = 'What do you call the world?'
            Result = 'aacddehhlllooorttuwwy'
        }
        @{
            String = 'Out of nowhere, the mind comes forth.'
            Result = 'cdeeeeffhhhimmnnooooorrstttuw'
        }
        @{
            String = 'Because it is so very clear, it takes longer to come to the realization.'
            Result = 'aaaaabccceeeeeeeeeghiiiiiklllmnnoooooorrrrsssstttttttuvyz'
        }
        @{
            String = 'The hands of the world are open.'
            Result = 'aaddeeeefhhhlnnoooprrsttw'
        }
        @{
            String = 'You are those huge waves sweeping everything before them, swallowing all in their path.'
            Result = 'aaaaabeeeeeeeeeeeefgggghhhhhhiiiiillllmnnnnoooopprrrrsssstttttuuvvwwwwyy'
        }
    )
}
