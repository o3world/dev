Vagrant.configure( "2" ) do |config|
	config.vm.define "dev" do |v|
		v.vm.box = "ubuntu/wily64"
		v.vm.provider "virtualbox" do |vb|
			vb.name = "dev"
			vb.customize [
				"modifyvm", :id,
				"--memory", "1024",
				"--vram", "8",
				"--cpus", "1",
				"--cpuexecutioncap", "50"
			]
		end
		v.vm.hostname = "vagrant.local.dev"
		v.vm.provision "file", source: "nginx.conf", destination: "/tmp/nginx.conf"
		v.vm.provision "shell", path: "provision.sh"
		v.vm.boot_timeout = 900
		v.vm.synced_folder ENV[ 'HOME' ] + "/sync", "/sync", type: "nfs", create: true
		v.vm.network "private_network", ip: "192.168.200.2"
		v.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
		v.vm.network "forwarded_port", guest: 443, host: 8443, auto_correct: true
		v.vm.network "forwarded_port", guest: 3306, host: 3306  #mysql
		v.vm.network "forwarded_port", guest: 5432, host: 5432  #postgres
		v.vm.network "forwarded_port", guest: 6379, host: 6379  #redis
		v.vm.provision "shell", inline: "echo 'I am ready!' | /usr/games/cowsay -f tux", run: "always"
	end
end
