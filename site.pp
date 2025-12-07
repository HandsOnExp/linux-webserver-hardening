node default {
  # 1) Create group and deploy user with limited sudo
  group { 'deployers':
    ensure => present,
  }

  user { 'deploy':
    ensure     => present,
    managehome => true,
    groups     => ['deployers'],
    require    => Group['deployers'],
  }

  file { '/etc/sudoers.d/deployers':
    ensure  => file,
    content => "%deployers ALL=(root) NOPASSWD: /usr/bin/test -s /var/www/html/index.html, /usr/bin/systemctl restart apache2, /usr/bin/nc -z localhost 80",
    mode    => '0440',
    require => Group['deployers'],
  }

  # 2) Create admin user and generate SSH keypair
  user { 'admin':
    ensure     => present,
    managehome => true,
  }

  file { '/home/admin/.ssh':
    ensure  => directory,
    owner   => 'admin',
    group   => 'admin',
    mode    => '0700',
    require => User['admin'],
  }

  exec { 'generate_admin_ssh_key':
    command => '/usr/bin/ssh-keygen -t rsa -b 4096 -f /home/admin/.ssh/id_rsa -N ""',
    creates => '/home/admin/.ssh/id_rsa',
    user    => 'admin',
    require => File['/home/admin/.ssh'],
  }

  # 3) Install and start Apache
  package { 'apache2':
    ensure => installed,
  }

  service { 'apache2':
    ensure    => running,
    enable    => true,
    require => Package['apache2'],
  }

  # 4) Create index.html with name and current date
  file { '/var/www/html/index.html':
    ensure  => file,
    content => inline_template('<html>
  <head><title>Welcome</title></head>
  <body>
    <h1>Hello, I\'m Daniel Ohana</h1>
    <p>Today\'s date is <%= Time.now.strftime("%Y-%m-%d") %></p>
  </body>
</html>'),
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    require => Package['apache2'],
    notify  => Service['apache2'],
  }
}
