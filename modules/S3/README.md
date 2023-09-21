# Variable Samples

### 1. 'region' (Required)

### 2. 'app_environment' (Required)

### 3. 's3_bucket_name' (Required)

### 4. 'website' (Optional. Required if want to host a website)

```
website = {
  "index_document" = "index.html",
  "error_document" = "404.html"
   "redirect_all_requests_to" = "www.example.com"
}
```

```
For website variable:
1- 'index_document' is optional. Required if redirect_all_requests_to is not specified.

2- 'error_document' is optional. Conflicts with 'redirect_all_requests_to'

3- 'redirect_all_requests_to' is optional, Required if index_document is not specified, and it is conflicts with error_document, index_document'
```

### 5. 'cors_rules' (Optional.)

```
cors_rules = [
        {
            "allowed_headers" = ["Authorization","Content-Length"]
            "allowed_methods" = ["GET"]
            "allowed_origins" = ["*"]
            "max_age_seconds" = 3000
        },
        {
           "allowed_headers" = ["*"]
            "allowed_methods" = ["POST", "PUT", "DELETE"]
            "allowed_origins" = ["www.example.au", "example.au"]
            "max_age_seconds" = 3000
        }
     ]
```

```
1- You are allowed to set one or more rules as a map in the core_rules list.

2- "allowed_headers": (Optional) It is a list, you can choose "*", "Authorization" or "Content-Length".

3- "allowed_methods": (Required) It is a list, you can choose "*", "POST", "PUT", "DELETE", "GET"

4- "allowed_origins": (Required) It is list, you can choose "*", or your domain.

5- "max_age_seconds": (Optional) Time in seconds that your browser is to cache the preflight response for the specified resource.
```

### 5. 'versioning' (Required)

```
versioning = false
```

### 6. 'acl_access_type' (Required)

```
1- only "private" or "public-read" is allowed, and default value is "private"
```

---

# Usage of s3_policy.json

### 1- The s3_policy.json file is used for configuring s3 policy.

### 2- Please create a json file called 's3_policy.json' and put it into your application root folder where you also put your main.tf

### 3- the json file sample

```
${jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${s3_bucket_name}/*"
        }
    ]
})}
```

### 4- Add this part code below into your main.tf folder where you invoke s3 module

```
locals {
  s3_access_policy = templatefile("s3_policy.json", { s3_bucket_name = var.s3_bucket_name })
}
```

### 5- Please don't change the first 's3_bucket_name'

### 6- You are free to change the second 's3_bucket_name' which is a variable of your s3 bucket name. Please remember keep the same.

### 7- Sample

```
locals {
  s3_access_policy = templatefile("s3_policy.json", { s3_bucket_name = var.s3_bucket_name })
}
module "s3_bucket" {
  source           = "../../modules/S3"
  s3_bucket_name   = var.s3_bucket_name
  s3_access_policy = local.s3_access_policy

}
```

---

# Outputs from this S3 module

```
arn
website_endpoint
bucket_domain_name
```
