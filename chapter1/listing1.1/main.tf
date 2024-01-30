resource "aws_instance" "helloworld" {
  ami           = "ami-048ac6bc3c08c2f04"
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld"
  }
}
