Vagrant.configure( "2" ) do |config|
	config.vm.define "dev" do |v|
		v.vm.box = "ubuntu/vivid64"
		v.vm.provider "virtualbox" do |vb|
			vb.name = "dev"
			vb.customize [
				"modifyvm", :id,
				"--memory", "1024",
				"--vram", "8",
				"--cpus", "1",
				"--cpuexecutioncap", "35"
			]
		end
		v.vm.provision "file", source: "nginx.conf", destination: "/tmp/nginx.conf"
		v.vm.provision "shell", path: "provision-dev.sh"
		v.vm.boot_timeout = 900
		v.vm.synced_folder ENV[ 'HOME' ] + "/sync", "/sync", type: "nfs", create: true
		v.vm.network "private_network", ip: "192.168.200.2"
		v.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
		v.vm.network "forwarded_port", guest: 3306, host: 3306
		v.vm.network "forwarded_port", guest: 6379, host: 6379
		v.vm.provision "shell", inline: "echo 'I am ready!' | /usr/games/cowsay -f tux", run: "always"
	end

	config.vm.define "solr" do |solr|
		solr.vm.box = "ubuntu/vivid64"
		v.vm.provider "virtualbox" do |vb2|
			vb2.name = "solr"
			vb.customize [
				"modifyvm", :id,
				"--memory", "1024",
				"--vram", "8",
				"--cpus", "1",
				"--cpuexecutioncap", "15"
			]
		end
		v.vm.provision "file", source: "nginx.conf", destination: "/tmp/nginx.conf"
		v.vm.provision "shell", path: "provision-solr.sh"
		v.vm.boot_timeout = 900
		v.vm.network "private_network", ip: "192.168.200.3"
		v.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
		v.vm.network "forwarded_port", guest: 8983, host: 8983, auto_correct: true
		v.vm.network "forwarded_port", guest: 7574, host: 7574, auto_correct: true
	end
end
