# beats/manifests/abeat.pp
#
# declaring an instance:
#
#   beats::abeat { 'metricbeat':
#     file_prefix => 'metricbeat-5.0.0',
#     pk_version  => '5.0.0-1',
#   }
#
define beats::abeat (
  # per https://docs.puppet.com/puppet/latest/reference/lang_defined_types.html
  $pk_name       = $title,
  $file_prefix   = undef,
  $pk_version    = 'installed',
  $sv_ensure     = 'running',
  $sv_enable     = true,
  $downloads_url = 'https://artifacts.elastic.co/downloads/beats/',

) {

  case $operatingsystem {
    /^(RedHat|CentOS|SLES)$/ : {
      $pkgr = 'rpm'
      $file_suffix = '-x86_64.rpm'
      $libcap = 'libpcap'
    }
    /^(Debian|Ubuntu)$/      : {
      $pkgr = 'dpkg'
      $file_suffix = '-amd64.deb'
      $libcap = 'libpcap0.8'
    }
    default                  : {
      fail("Unrecognized operating system ${operatingsystem}, please use it on a Linux host")
    }
  }

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    ensure => present,
  }

  Exec {
    path => '/bin:/usr/bin', }

  Package {
    ensure => installed, }

  exec { "get_${file_prefix}${file_suffix}":
    command => "curl -sL ${downloads_url}/${pk_name}/${file_prefix}${file_suffix} -o /var/tmp/${file_prefix}${file_suffix}",
    creates => "/var/tmp/${file_prefix}${file_suffix}",
  }
  
  if $pk_name =~ /packetbeat/ {
    package { $libcap: }
  }

  #if $pk_name =~ /metricbeat/ {
  #  package { 'topbeat': ensure => absent, }
  #}

  package { $pk_name:
    provider => $pkgr,
    ensure   => $pk_version,
    source   => "/var/tmp/${file_prefix}${file_suffix}",
    require  => Exec["get_${file_prefix}${file_suffix}"],
  }

  file { "/etc/${pk_name}/${pk_name}.yml":
    notify  => Service["${pk_name}"],
    content => template("beats/${file_prefix}.erb"),
  }

  service { $pk_name:
    ensure => $sv_ensure,
    enable => $sv_enable,
  }

}

