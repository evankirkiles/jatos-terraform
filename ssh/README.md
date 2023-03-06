# SSH Folder

In this folder, you will find the .pem key you can use to SSH into your EC2 instance. To connect to your EC2 instance, simply run the following command from
this folder, replacing <jatos-eip-public-dns> with the public DNS outputted
from Terraform.

```
ssh -i ./jatos.pem ec2-user@<jatos-eip-public-dns>
```

You can also add the public key to your keychain to facilitate this process,
so you don't need to specify the `-i` flag and the `.pem` file every time:

```
ssh-add ./jatos.pem
```