path = require 'path'
module.exports = (home, host) ->
  [
      src: path.join home, '.bashrc'
      dest: "#{host}/.bashrc"
    ,
      src: path.join home, '.docker'
      dest: "#{host}/.docker"
    ,
      src: '/etc/docker'
      dest: "#{host}/docker"
    ,
      src: '/etc/hosts'
      dest: "#{host}/hosts"
    ,
      src: '/etc/openvpn'
      dest: "#{host}/openvpn"
  ]