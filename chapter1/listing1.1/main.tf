resource "aws_instance" "helloworld" {
  ami           = "ami-0d118c6e63bcb554e"
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld"
  }
}
