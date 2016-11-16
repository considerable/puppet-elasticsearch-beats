# beats/manifests/init.pp
#
class beats () {
  $beats = {
    'metricbeat' => {
      file_prefix => 'metricbeat-5.0.0',
      pk_version  => '5.0.0-1',
    }
    ,
    'filebeat'   => {
      file_prefix => 'filebeat-5.0.0',
      pk_version  => '5.0.0-1',
    }
    ,
    'packetbeat' => {
      file_prefix => 'packetbeat-5.0.0',
      pk_version  => '5.0.0-1',
    }
  }

  create_resources('skywalk::abeat', $beats)

}
