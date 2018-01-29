module.exports =
[
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