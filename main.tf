#creating secret manager
resource "aws_secretsmanager_secret" "my_secret" {
  name = "my_secret"
  description = "to store  db secret"
}
  
#creating secrets value to store secrets value

resource "aws_secretsmanager_secret_version" "my_secret_value" {
  secret_id = aws_secretsmanager_secret.my_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = "SuperSecret123!"
  })
}

#creating trust policy of iam
data "aws_iam_policy_document" "assume_role_policy1" {
   statement {
      effect = "Allow"

      principals {
         type = "Service"
         identifiers = ["ec2.amazonaws.com"]
     }

    actions = ["sts:AssumeRole"]
  }
}

#creating role

resource "aws_iam_role" "assume_role" {
    name = "assue_role"
    assume_role_policy = data.aws_iam_policy_document.assume_role_policy1.json
}

#creating policy and attaching it to role to get secrets

resource "aws_iam_policy" "ec2_policy" {
    policy = jsonencode({
       Version = "2012-10-17",
       Statement = [
          {
            Effect   = "Allow",
            Action   = ["secretsmanager:GetSecretValue"],
            Resource = aws_secretsmanager_secret.my_secret.arn
      }
    ]
  })
}

#attaching policy to role

resource "aws_iam_role_policy_attachment" "attach" {
   policy_arn = aws_iam_policy.ec2_policy.arn
   role   = aws_iam_role.assume_role.name
}

#creating instance profile(because role doesn't directly attach to ec2 -- instance profile will bind atttach to ec2)
    resource "aws_iam_instance_profile" "instance_profile" {
       name = "ec2toreadsecretsfromscretsmanager"
       role = aws_iam_role.assume_role.name
  }      
#creating instance 
resource "aws_instance" "EC2secrets" {
  ami = var.ami_id
  key_name = var.key_name
  instance_type = var.instance_type

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

    tags = {
    Name = "EC2WithSecretAccess"
    }
}

