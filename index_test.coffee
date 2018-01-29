{ copy } = require './index'
{ expect } = require 'chai'
_ = require 'lodash'
fsExtra = require 'fs-extra'
path = require 'path'
HOME = '/home/tiramizu/'
Promise = require 'bluebird'
backupList = [
		src: path.join HOME, '.bashrc'
		dest: 'tmp/.bashrc'
	,
		src: path.join HOME, '.docker'
		dest: 'tmp/.docker'
	,
		src: '/etc/docker'
		dest: 'tmp/docker'
	,
		src: '/etc/hosts'
		dest: 'tmp/hosts'
	,
		src: '/etc/openvpn'
		dest: 'tmp/openvpn'
]
describe "Copy File", ->
  beforeEach ->
    fsExtra.remove 'tmp'
  it 'should copy .bashrc', ->
    await copy backupList
    exists = await Promise.map backupList, (e) ->
      fsExtra.pathExists path.join(__dirname, e.dest)
    existTrueLength = (_.filter exists, (e) -> _.isBoolean(e) and e).length
    expect(existTrueLength).to.eq backupList.length