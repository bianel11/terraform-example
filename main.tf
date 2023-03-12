provider "aws" {
  region     = "us-east-1"
  access_key = file("./access_key.txt")
  secret_key = file("./secret_key.txt")
}

resource "aws_instance" "example" {
  ami             = "ami-005f9685cb30f234b"
  instance_type   = "t2.micro"
  security_groups = ["default"]
  key_name        = "terra-example"
  tags = {
    Name = "example-instance-terraform"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> public_ip.txt"
  }

  provisioner "remote-exec" {

    connection {
      type     = "ssh"
      user     = "ec2-user"
      host     = self.public_ip
      private_key = file("./terra-example.pem")
    }

    inline = [
      "set -o errexit",
      "sudo yum update -y",
      "sudo yum install git -y",
      "sudo amazon-linux-extras install docker -y",
      "sudo service docker start",
      "sudo usermod -aG docker ec2-user",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "git clone https://github.com/bianel11/docker-example.git /home/ec2-user/docker-example",
      "cd /home/ec2-user/docker-example",
      "sudo systemctl enable docker.service",
      "sudo systemctl start docker",
      "sudo service docker start",
      "sudo chmod 666 /var/run/docker.sock",
      "docker-compose up -d"
    ]
  }
}
