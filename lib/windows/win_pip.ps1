#!powershell
#
#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module Ansible.ModuleUtils.CommandUtil
$ErrorActionPreference = "Stop"

$params = Parse-Args -arguments $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false
$diff_mode = Get-AnsibleParam -obj $params -name "_ansible_diff" -type "bool" -default $false

$name = Get-AnsibleParam -obj $params -name "name" -type "str" -failifempty $true

$result = @{
    changed = $false
    version = ""
    stdout = ""
    stderr = ""
    rc = 0
}

# TODO: add pip executable lookup
$pip = "pip"

Function Is-Installed {
    param(
        [String]$name
    )

    $installed = $false

    $res = Run-Command -command "$pip show $name"
    if ($res.rc -eq 0) {
        $installed = $true
    }

    return $installed
}

Function Create-Virtualenv {

}
# check if pip is available
$res = Run-Command -command "$pip --version"

if ($res.rc -eq 0) {
    $result.version = $res.stdout
}

# install module

if (-not (Is-Installed -name $name) ) {
    $result.changed = $true
    if (-not $check_mode) {
        $res = Run-Command -command "$pip install $name"
        if ($res.rc -ne 0) {
            $result.stdout = $res.stdout
            $result.stderr = $res.stderr
            $result.rc = $res.rc
            Fail-Json -obj $result -msg "pip install failed"
        }
    }
}

Exit-Json -obj $result
