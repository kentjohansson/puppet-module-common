# == Define: common::module
#
# Includes a module depending on value of enable
#
# Parameters:
#   $enable              - Should the module be enabled
#   $name                - Name of the module to be included
#
# Sample Usage:
#   common::module{ 'ntp': enable => $enable_ntp }


define common::module (
  $enable = undef,
) {
  if $enable == undef {
    fail("Cant include module ${name} with enable set to undef")
  }
  if type($enable) == 'string' {
    $module_enable = str2bool($enable)
  } else {
    $module_enable = $enable
  }
  if $module_enable == true {
    include $name
  }
}

