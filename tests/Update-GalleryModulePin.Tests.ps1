#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

<#
    .SYNOPSIS
    Prove that the Gallery pin updater raises a pin when it should and leaves it alone otherwise.

    .DESCRIPTION
    Update-GalleryModulePin.ps1 exists to open a pull request when a newer module version is
    published and to do nothing when one is not, so those two outcomes are what these tests
    assert - directly, and without waiting for the real Pester to release.

    The Gallery is served from an in-process HttpListener bound to a loopback port, driven from a
    background runspace. That keeps every case deterministic and runnable offline, and it exercises
    the script's real HTTP path rather than mocking it away. The '-GalleryUri' parameter is the
    seam; it is a real parameter that points the script at a Gallery mirror, and pointing it at a
    stub is a side effect of that rather than a reason for it.
#>

Describe 'Update-GalleryModulePin' {
    BeforeAll {
        $script:sourceScript = Join-Path $PSScriptRoot '../.github/scripts/Update-GalleryModulePin.ps1'

        # Serves the OData v2 shape the script reads: an Atom feed whose entries carry a
        # 'm:properties/d:Version'. Honours '$skip' so paging is real, and '$filter' so the
        # prerelease exclusion is proven to be sent rather than assumed.
        $script:serve = {
            param($Listener, $Version, $PageSize)

            while ($Listener.IsListening) {
                try {
                    $context = $Listener.GetContext()
                } catch {
                    break
                }
                try {
                    $query = $context.Request.QueryString
                    $skip = 0
                    if ($query['$skip']) { $skip = [int] $query['$skip'] }

                    $selected = @($Version)
                    if ([string] $query['$filter'] -like '*IsPrerelease eq false*') {
                        $selected = @($selected | Where-Object { $_ -notmatch '-' })
                    }
                    $page = @($selected | Select-Object -Skip $skip | Select-Object -First $PageSize)

                    $builder = [System.Text.StringBuilder]::new()
                    $null = $builder.Append('<?xml version="1.0" encoding="utf-8"?>')
                    $null = $builder.Append('<feed xml:base="http://localhost/" xmlns="http://www.w3.org/2005/Atom" ')
                    $null = $builder.Append('xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" ')
                    $null = $builder.Append('xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata">')
                    foreach ($entry in $page) {
                        $null = $builder.Append('<entry><title type="text">Stub</title>')
                        $null = $builder.Append("<m:properties><d:Version>$entry</d:Version></m:properties></entry>")
                    }
                    $null = $builder.Append('</feed>')

                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($builder.ToString())
                    $context.Response.StatusCode = 200
                    $context.Response.ContentType = 'application/atom+xml;charset=utf-8'
                    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
                } catch {
                    # A stub failure must not kill the server and hang every remaining test.
                    try { $context.Response.StatusCode = 500 } catch { $null = $_ }
                } finally {
                    try { $context.Response.OutputStream.Close() } catch { $null = $_ }
                }
            }
        }

        function Start-GalleryStub {
            <#
                .SYNOPSIS
                Serve a canned set of module versions over loopback HTTP.

                .DESCRIPTION
                Bind an HttpListener to a free loopback port and answer the script's feed queries
                from the supplied version list, paging at the requested size. 'localhost' is used
                deliberately: that prefix binds without elevation, where a '+' or hostname prefix
                does not.

                .EXAMPLE
                Start-GalleryStub -Version '6.0.0', '6.0.1'
                Returns the stub's base URI and the handles needed to stop it.

                .OUTPUTS
                [pscustomobject]
            #>
            [CmdletBinding(SupportsShouldProcess)]
            param(
                # Versions the stub reports as published, newest order irrelevant.
                [Parameter(Mandatory)]
                [string[]] $Version,

                # How many entries a single feed page returns, so paging can be exercised.
                [Parameter()]
                [int] $PageSize = 100
            )

            $probe = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
            $probe.Start()
            $port = $probe.LocalEndpoint.Port
            $probe.Stop()

            if (-not $PSCmdlet.ShouldProcess("http://localhost:$port/", 'Start Gallery stub')) {
                return
            }

            $listener = [System.Net.HttpListener]::new()
            $listener.Prefixes.Add("http://localhost:$port/")
            $listener.Start()

            $shell = [powershell]::Create()
            $shell.Runspace = [runspacefactory]::CreateRunspace()
            $shell.Runspace.Open()
            $null = $shell.AddScript($script:serve).AddArgument($listener).AddArgument($Version).AddArgument($PageSize)
            $null = $shell.BeginInvoke()

            return [pscustomobject]@{
                Uri = "http://localhost:$port"
                Listener = $listener
                Shell = $shell
            }
        }

        function Stop-GalleryStub {
            <#
                .SYNOPSIS
                Tear down a stub started by Start-GalleryStub.

                .DESCRIPTION
                Stop the listener, which makes the blocked GetContext() throw and ends the serving
                loop, then dispose the runspace and the shell driving it.

                .EXAMPLE
                Stop-GalleryStub -Stub $stub
                Releases the port and the background runspace.

                .OUTPUTS
                None
            #>
            [CmdletBinding(SupportsShouldProcess)]
            param(
                # The object returned by Start-GalleryStub.
                [Parameter(Mandatory)]
                [psobject] $Stub
            )
            if (-not $PSCmdlet.ShouldProcess($Stub.Uri, 'Stop Gallery stub')) {
                return
            }
            try { $Stub.Listener.Stop() } catch { $null = $_ }
            try { $Stub.Listener.Close() } catch { $null = $_ }
            try { $Stub.Shell.Runspace.Dispose() } catch { $null = $_ }
            try { $Stub.Shell.Dispose() } catch { $null = $_ }
        }

        function New-PinFixture {
            <#
                .SYNOPSIS
                Write a throwaway file carrying a pinned version and a module GUID.

                .DESCRIPTION
                Mirror the shape of the real pin in Invoke-PesterSuite.ps1 - a '$RequiredVersion'
                parameter default alongside a '$ModuleGuid' identity pin - and write it with a
                byte-order mark and CRLF endings, so the tests can prove the rewrite preserves
                both instead of restyling the file around the version.

                .EXAMPLE
                New-PinFixture -Version 6.0.1
                Returns the path of the fixture file.

                .OUTPUTS
                [string]
            #>
            [CmdletBinding(SupportsShouldProcess)]
            param(
                # The version the fixture starts out pinned to.
                [Parameter(Mandatory)]
                [string] $Version
            )

            $path = Join-Path ([System.IO.Path]::GetTempPath()) "pin-$([guid]::NewGuid().ToString('N')).ps1"
            if (-not $PSCmdlet.ShouldProcess($path, 'Create pin fixture')) {
                return
            }
            $lines = @(
                'param('
                "    [string] `$RequiredVersion = '$Version',"
                "    [guid] `$ModuleGuid = 'a699dea5-2c73-4616-a270-1f7abb777e71'"
                ')'
            )
            [System.IO.File]::WriteAllText($path, ($lines -join "`r`n"), [System.Text.UTF8Encoding]::new($true))
            return $path
        }
    }

    Context 'When a newer version exists' {
        It 'Raises the pin and reports the update' {
            $stub = Start-GalleryStub -Version '6.0.0', '6.0.1', '6.0.2'
            $pin = New-PinFixture -Version 6.0.1
            try {
                # The script logs to stdout as well as returning its result, so the pipeline
                # carries workflow-command strings ahead of the object. Take the object rather
                # than relying on member enumeration over the whole array.
                $result = & $script:sourceScript -Name Pester -Path $pin -MinimumVersion 6.0.0 -MaximumVersion '6.*' -GalleryUri $stub.Uri | Select-Object -Last 1

                $result.Updated | Should -BeTrue
                $result.CurrentVersion | Should -Be ([version] '6.0.1')
                $result.LatestVersion | Should -Be ([version] '6.0.2')
                $result.Level | Should -Be 'patch'
                [System.IO.File]::ReadAllText($pin) | Should -Match "RequiredVersion = '6\.0\.2'"
            } finally {
                Stop-GalleryStub -Stub $stub
                Remove-Item -LiteralPath $pin -Force -ErrorAction SilentlyContinue
            }
        }

        It 'Changes the version and nothing else — identity, byte-order mark, and line endings survive' {
            $stub = Start-GalleryStub -Version '6.0.1', '6.1.0'
            $pin = New-PinFixture -Version 6.0.1
            try {
                $before = [System.IO.File]::ReadAllText($pin)
                $result = & $script:sourceScript -Name Pester -Path $pin -MinimumVersion 6.0.0 -MaximumVersion '6.*' -GalleryUri $stub.Uri | Select-Object -Last 1
                $after = [System.IO.File]::ReadAllText($pin)
                $bytes = [System.IO.File]::ReadAllBytes($pin)

                $result.Level | Should -Be 'minor'
                # The only textual difference is the version itself.
                $after | Should -Be ($before -replace "6\.0\.1", '6.1.0')
                $after | Should -Match "ModuleGuid = 'a699dea5-2c73-4616-a270-1f7abb777e71'"
                $after | Should -Match "`r`n"
                $bytes[0..2] | Should -Be @(0xEF, 0xBB, 0xBF)
            } finally {
                Stop-GalleryStub -Stub $stub
                Remove-Item -LiteralPath $pin -Force -ErrorAction SilentlyContinue
            }
        }

        It 'Writes the outputs a workflow step branches on' {
            $stub = Start-GalleryStub -Version '6.0.1', '6.0.2'
            $pin = New-PinFixture -Version 6.0.1
            $outputFile = Join-Path ([System.IO.Path]::GetTempPath()) "out-$([guid]::NewGuid().ToString('N')).txt"
            try {
                $env:GITHUB_OUTPUT = $outputFile
                $null = & $script:sourceScript -Name Pester -Path $pin -MinimumVersion 6.0.0 -MaximumVersion '6.*' -GalleryUri $stub.Uri | Select-Object -Last 1

                $written = [System.IO.File]::ReadAllText($outputFile)
                $written | Should -Match 'updated=true'
                $written | Should -Match 'latest=6\.0\.2'
                $written | Should -Match 'level=patch'
            } finally {
                Remove-Item -Path Env:\GITHUB_OUTPUT -ErrorAction SilentlyContinue
                Stop-GalleryStub -Stub $stub
                Remove-Item -LiteralPath $pin -Force -ErrorAction SilentlyContinue
                Remove-Item -LiteralPath $outputFile -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context 'When nothing newer is available' {
        It 'Leaves the file byte-identical and reports no update' {
            $stub = Start-GalleryStub -Version '6.0.0', '6.0.1'
            $pin = New-PinFixture -Version 6.0.1
            try {
                $before = [System.IO.File]::ReadAllBytes($pin)
                $result = & $script:sourceScript -Name Pester -Path $pin -MinimumVersion 6.0.0 -MaximumVersion '6.*' -GalleryUri $stub.Uri | Select-Object -Last 1
                $after = [System.IO.File]::ReadAllBytes($pin)

                $result.Updated | Should -BeFalse
                $result.Level | Should -Be 'none'
                $after | Should -Be $before
            } finally {
                Stop-GalleryStub -Stub $stub
                Remove-Item -LiteralPath $pin -Force -ErrorAction SilentlyContinue
            }
        }

        It 'Does not cross the ceiling the test suites declare' {
            $stub = Start-GalleryStub -Version '6.0.1', '7.0.0'
            $pin = New-PinFixture -Version 6.0.1
            try {
                $result = & $script:sourceScript -Name Pester -Path $pin -MinimumVersion 6.0.0 -MaximumVersion '6.*' -GalleryUri $stub.Uri | Select-Object -Last 1

                $result.Updated | Should -BeFalse
                $result.LatestVersion | Should -Be ([version] '6.0.1')
            } finally {
                Stop-GalleryStub -Stub $stub
                Remove-Item -LiteralPath $pin -Force -ErrorAction SilentlyContinue
            }
        }

        It 'Does not move a CI pin onto a prerelease' {
            $stub = Start-GalleryStub -Version '6.0.1', '6.1.0-alpha2'
            $pin = New-PinFixture -Version 6.0.1
            try {
                $result = & $script:sourceScript -Name Pester -Path $pin -MinimumVersion 6.0.0 -MaximumVersion '6.*' -GalleryUri $stub.Uri | Select-Object -Last 1

                $result.Updated | Should -BeFalse
                $result.LatestVersion | Should -Be ([version] '6.0.1')
            } finally {
                Stop-GalleryStub -Stub $stub
                Remove-Item -LiteralPath $pin -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context 'Feed paging' {
        It 'Finds the newest version even when it is on a later page' {
            $stub = Start-GalleryStub -Version '6.0.0', '6.0.1', '6.0.2', '6.1.0' -PageSize 2
            $pin = New-PinFixture -Version 6.0.1
            try {
                $result = & $script:sourceScript -Name Pester -Path $pin -MinimumVersion 6.0.0 -MaximumVersion '6.*' -GalleryUri $stub.Uri | Select-Object -Last 1

                $result.Updated | Should -BeTrue
                $result.LatestVersion | Should -Be ([version] '6.1.0')
            } finally {
                Stop-GalleryStub -Stub $stub
                Remove-Item -LiteralPath $pin -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context 'When the check cannot be performed, it fails instead of passing' {
        It 'Refuses to guess when the pin pattern matches nothing' {
            $stub = Start-GalleryStub -Version '6.0.1', '6.0.2'
            $pin = New-PinFixture -Version 6.0.1
            try {
                {
                    & $script:sourceScript -Name Pester -Path $pin -PinPattern "NotThePin\s*=\s*'(?<version>[^']+)'" -GalleryUri $stub.Uri
                } | Should -Throw '*matched nothing*'
            } finally {
                Stop-GalleryStub -Stub $stub
                Remove-Item -LiteralPath $pin -Force -ErrorAction SilentlyContinue
            }
        }

        It 'Refuses to guess when the pin pattern matches more than one place' {
            $stub = Start-GalleryStub -Version '6.0.1', '6.0.2'
            $pin = New-PinFixture -Version 6.0.1
            try {
                {
                    & $script:sourceScript -Name Pester -Path $pin -PinPattern "'(?<version>[^']+)'" -GalleryUri $stub.Uri
                } | Should -Throw '*matched 2 places*'
            } finally {
                Stop-GalleryStub -Stub $stub
                Remove-Item -LiteralPath $pin -Force -ErrorAction SilentlyContinue
            }
        }

        It 'Treats an unreachable Gallery as a failure, never as "already up to date"' {
            $stub = Start-GalleryStub -Version '6.0.1'
            $deadUri = $stub.Uri
            Stop-GalleryStub -Stub $stub
            $pin = New-PinFixture -Version 6.0.1
            try {
                $before = [System.IO.File]::ReadAllBytes($pin)
                { & $script:sourceScript -Name Pester -Path $pin -GalleryUri $deadUri } | Should -Throw
                [System.IO.File]::ReadAllBytes($pin) | Should -Be $before
            } finally {
                Remove-Item -LiteralPath $pin -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
