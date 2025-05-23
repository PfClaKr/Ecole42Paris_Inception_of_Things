Vagrant.configure("2") do |config|
  config.vm.define "ychunS" do |server|
    server.vm.box = "ubuntu/bionic64"
    server.vm.hostname = "ychunS"
    server.vm.network "private_network", ip: "192.168.56.110"
    server.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--name", "ychunS"]
      vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
      vb.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
      vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
      vb.customize ["modifyvm", :id, "--vram", "64"]
    end
    server.vm.provision "shell", path: "scripts/server.sh"
   end

  config.vm.define "schaehunSW" do |worker|
    worker.vm.box = "ubuntu/bionic64"
    worker.vm.hostname = "schaehunSW"
    worker.vm.network "private_network", ip: "192.168.56.111"
    worker.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--name", "schaehunSW"]
      vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
      vb.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
      vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
      vb.customize ["modifyvm", :id, "--vram", "64"]
    end
    worker.vm.provision "shell", path: "scripts/worker.sh"
  end
end
