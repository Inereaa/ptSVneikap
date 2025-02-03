
resource "aws_instance" "mi_instancia" {
  ami                        = "ami-0866a3c8686eaeeba"
  instance_type              = "t2.micro"
  key_name                   = aws_key_pair.apache_server_ssh.key_name
  subnet_id                  = aws_subnet.mi_subred_publica.id
  vpc_security_group_ids     = [aws_security_group.sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash

    # Actualizo e instalo Docker y Git
    sudo apt-get update -y
    sudo apt-get install -y docker.io git

    # Inicio Docker
    sudo systemctl start docker
    sudo systemctl enable docker

    # Clono el repositorio
    sudo git clone https://github.com/Inereaa/ptSVneikap.git /var/www/html

    # Construyo la imagen de Docker
    cd /var/www/html
    sudo docker build -t apache-server .

    # Creo usuarios y sus directorios públicos
    sudo useradd -m usuario1
    sudo mkdir -p /home/usuario1/public_html
    echo "<h1>Hola desde usuario1</h1>" | sudo tee /home/usuario1/public_html/index.html
    sudo chown -R usuario1:usuario1 /home/usuario1/public_html

    sudo useradd -m usuario2
    sudo mkdir -p /home/usuario2/public_html
    echo "<h1>Hola desde usuario2</h1>" | sudo tee /home/usuario2/public_html/index.html
    sudo chown -R usuario2:usuario2 /home/usuario2/public_html

    # Ejecuto el contenedor
    sudo docker run -d -p ${var.http_port}:80 -p ${var.https_port}:443 --name neikap \
      -v /home:/home \
      apache-server
  EOF

  tags = {
    Name = "MiInstanciaEC2"
  }
}
