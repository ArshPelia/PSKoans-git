﻿using module PSKoans
[Koan(Position = 116)]
param()
<#
    Conditionals and Branching

    Conditionals operate with language keywords like if, else, and switch, and utilise
    boolean statements to determine program control flow.

    Due to how PowerShell handles output, its conditional statements can return output
    data, as is usually seen in functional programming languages.
#>
Describe 'If/Else' {

    Context 'Control Flow' {

        It 'is used to alter which code should be executed based on input' {
            function Assert-IsEven ($Number) {
                if ($Number % 2 -eq 0) {
                    <#
                        Values or objects dropped to output on conditionals will still
                        be used as output for the function.
                    #>
                    'EVEN'
                }
                else {
                    'ODD'
                }
            }

            $ExpectedResult = Assert-IsEven -Number 2
            'EVEN' | Should -Be $ExpectedResult

            Assert-IsEven -Number 3 | Should -Be 'ODD'
        }

        It 'can be used alone' {
            function Set-Number ($Number) {
                # What happens if the conditional completely skips the if statement?
                if ($Number -gt 5) {
                    $Number * 10
                }
            }
            $null | Should -Be (Set-Number -Number 4)
            Set-Number -Number 7 | Should -Be 70
        }
    }

    Context 'Assigning Values' {

        It 'can be used to select a value for a variable' {
            function Get-Thing {
                return (Get-ChildItem -Path $HOME -File | Select-Object -First 1).Length
            }
            $Thing = Get-Thing
            $Result = if ($Thing -gt 5) {
                # The item dropped to output is stored in the assigned variable
                $Thing
            }
            else {
                # but depending on the outcome of the conditional, either could end up stored!
                "$Thing is less than 5"
            }
            2820 | Should -Be $Result
        }

        It 'can also apply a condition to an else' {
            $Value = if (4 -lt 5) {
                10
            }
            elseif ("string" -is [string]) {
                'hi'
            }
            else {
                -1
            }
            $Value += 1
            11 | Should -Be $Value
        }
    }
}

Describe 'Switch' {
    <#
        Switches often replace stacks of if/elseif/../else conditionals
        If you have more than an if/else, you might find a switch useful.
    #>
    Context 'Control Flow' {

        It 'is used to create multiple possible branches' {
            $Folders = 4..9 | ForEach-Object {"$Folders" * 1}

            switch ($Folders.Count) {
                1 {
                    # Switch statements assign the current value being tested to $_
                    $Amount = 'one' + 1
                    break
                }
                5 {
                    $Amount = 'five'
                    # Usually we break out of the switch after one case matches
                    break
                }
                default {
                    # The default branch is taken when no other cases match
                    $Amount = "other $_"
                    break
                }
            }

            'other 6' | Should -Be $Amount
        }
    }
    Context 'Assigning Values' {

        It 'can also be used to conditionally assign values' {
            $Case = 1
            $Variable = switch ($Case) {
                45 {
                    'hello!'
                    break
                }
                47 {
                    4.5
                    break
                }
                57 {
                    -1
                    break
                }
                default {
                    [double]::PositiveInfinity
                }
            }

            [double]::PositiveInfinity | Should -Be $Variable
            $Variable | Should -BeOfType [double]
        }

        It 'can go through multiple branches' {
            # Omitting the break statement allows one condition to match several cases
            $Values = switch ('Condition') {
                # As with most PowerShell string matching logic, switches are not case sensitive
                'CONDITION' {
                    1
                }
                'condition' {
                    2
                }
            }
            @(1, 2) | Should -Be ($Values)
        }
    }

    Context 'Use With Arrays' {

        It 'will process each element of arrays' {
            $Array = @(
                4
                7
            )

            $Result = switch ($Array) {
                1 {
                    '-2'
                    <#
                        Even without a break or continue here, if any branch is taken,
                        the default case will be skipped!
                    #>
                }
                4 {
                    4 * 4
                    <#
                        The continue keyword is like break, except it only skips the rest
                        of the switch for the current value and goes back to test all the
                        other input values.

                        If there is only a single input value, it functions like break.
                    #>
                    continue
                }
                7 {
                    '15'
                    <#
                        Using break in an array-input situation means all the rest of
                        the items don't get tested in the switch. Be careful!
                    #>
                    break
                }
                default {
                    '-1'
                }
            }
            # Since the input is an array, both items must get the correct output
            $Result | Should -Be @(16, '15')
        }
    }

    Context 'Types of Switch' {

        It 'accepts wildcard conditions' {
            $Condition = 'Clarity'
            # ... but only if you ask nicely, that is!
            $Result = switch -Wildcard ($Condition) {
                # Wildcarded switches work with * for multiple characters
                'Harm*' {
                    'Safe'
                }
                'Clarity' {
                    'Vision'
                }
            }

            $Result | Should -Be 'Vision'
        }

        It 'accepts regex conditions' {
            # Enter a regex string that matches the pattern to pass the test.
            $Value = 'a.z.n'
            $Pattern = "a.*z.n"
            <#
                If you need a regex refresher, check out https://regexr.com/
                Remember that it doesn't need to match the entire string unless the match says so!
            #>
            switch -Regex ($Value) {
                $Pattern {
                    $Result = $true
                }
            }
            $true | Should -BeTrue
        }

        It 'allows use of conditional expressions' {
            $TestValue = 9
            <#
                Unlike many other languages, PowerShell allows you to customise switches immensely
                through the use of script blocks to create dynamic conditions
            #>
            switch ($TestValue) {
                # Condition blocks need a boolean outcome, or it will be coerced to boolean
                {$_ -gt 7} {
                    # Only one of these test cases needs to pass!
                    $_ | Should -Be 9
                }
                {$_ -is [decimal]} {
                    $_ | Should -Be 1.5
                }
                {$_.Length -gt 4} {
                    $_ | Should -BeOfType [string]
                }
                default {
                    Should -Fail -Because 'the value of $TestValue was invalid.'
                }
            }
        }
    }
}
