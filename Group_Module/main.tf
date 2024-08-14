resource "aws_iam_group" "name" {
 name = "developers"
}

resource "aws_iam_policy" "policy" {
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_group_policy_attachment" "test-attach" {
  group      = aws_iam_group.name.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_user" "user1" {
  name = "bhargav"
}


resource "aws_iam_user_group_membership" "name" {
  user = aws_iam_user.user1.name
  

  groups = [
    aws_iam_group.name.name,
    
  ]
}
