# PKCS11 Support for MicroMDM SCEP

## Prerequisites

You'll need to install a pkcs11 library which is the interface used to perform external cryptographic operations.

In the example we'll follow, we'll tack together some solutions to leverage the AWS KMS solution, via PKCS11.  While it's possible to talk to KMS directly using the AWS SDK, this would only leave us in a position to talk to AWS.  This solution *should* allow you to talk to *anything* which works with pkcs11, including full-fat HSM's.

The code here uses Thales' Crypto11 library, documentation at https://github.com/ThalesIgnite/crypto11

Their library (officially) supports AWS CloudHSM, Thales Luna HSM,  SoftHSM, nCipher nShield, but probably others too as long as there is a pkcs11 library for it.


### AWS KMS PKCS11 Implementation

For our backend crypto services provider, we'll use https://github.com/JackOfMostTrades/aws-kms-pkcs11 to allow us to talk, via pkcs11, to AWS KMS..  Follow the instructions on that page, the pre-requisite for this is the AWS C++ SDK.  

You'll end up (if successful) with a library object (aws_kms_pkcs11.so) which you'll reference in a config file later.  As crypto programming and debugging is more complicated than other things, it's a splendid idea to test as you go, e.g. by following the 'ssh' instructions on that page to make sure you can use keys.

### AWS KMS Keys

One challenge with hardware security modules in general is key usage - and KMS is no exception.  You can only (usually) generate keys which can be used to Sign/Verify *or* Encrypt/Decrypt.  For this solution we will use an RSA key which has Sign/Verify usage, at the expense of Enc/Dec.  Ordinarily this won't be an issue, but the SCEP protocol requires **both!**.

Once you've generated a key in KMS, you'll need to give this solution access to it, via key policy and IAM roles.  Out of scope for this, but https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html and https://docs.aws.amazon.com/kms/latest/developerguide/iam-policies-overview.html are the reference articles.

At this point, I'm assuming you've created an RSA key, and the policies, and have tested you have access to it via `openssl' or similar on the node you intend to run this on.

## Build/Confgure this Solution

Follow the instruction in the original [README](README.orig.md).

This solution extends the original via command line flags and envronment variables.  I've added a new flag to both the CA init step, and the main program flags.

```
...
  -pkcs11-config string
        location of json config for pkcs11 external signer
```

The flag takes in an argument of a filename, which should contain details that are used by PKCS11 to configure itself.  Example contents of this file are:

```
cat pkcs11-test.json 
{
  "Path": "/usr/lib64/pkcs11/aws_kms_pkcs11.so",
  "TokenLabel": "scep-scim-testing-kms-key",
  "Pin": ""
}
```

The path should be set to the aws_kms_pkcs11.so library you built earlier, or whatever other pkcs11 library you want to use, along with whatever other settings you need/want and are described [here](https://pkg.go.dev/github.com/ThalesIgnite/crypto11#Config), in JSON format.

## Creating the new CA

At this point, we can create our new CA.  Similar to the original usage, but referencing our pkcs11 config file:

```
[ec2-user@ip-172-31-29-213 scep-130323]$ ./scepserver-linux-amd64 ca -init -pkcs11-config pkcs11-test.json -depot somedirectory
Initializing new CA
[ec2-user@ip-172-31-29-213 scep-130323]$ 
```

In addition to the original `ca.pem` in `somedirectory` you should also find an `external-ca.pem` file.  This is the CA cert which is created and signed using the external RSA key.  To verify this, you can extract the public key, and compare it to the one available in the AWS KMS console.  Using OpenSSL:

```
[ec2-user@somewhere somedirectory]$ openssl x509 -pubkey -noout -in external-ca.pem 
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAsYArU9OWSXcVcLh7pGm5
...
5p10kFeZA3PpCTZZzZX0Hu0CAwEAAQ==
-----END PUBLIC KEY-----
```

If this matches the one in the console fantastic - it's working and we can talk to KMS successfully!

## Normal Operation

This is the same as described in the original solution, but again we tell it via flags to use pkcs11.

For example:

```
./scepserver-linux-amd64 -depot somedirectory -port 2016 -challenge=SOMESECRET  -debug -allowrenew 0 -pkcs11-config pkcs11-test.json
```

## Bugs/Todo

As part of the SCEP operation, the local CA is supplied and not the CA certificate used to sign the issued cert.  This is not currently an issue for me, but I need to investigate if that can be amended to replace that certificate with the 'real' one.
