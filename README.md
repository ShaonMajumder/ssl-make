# SmCert - Simplifying Certificate Management

SmCert is a bash script that simplifies the management of certificates and certificate authorities (CAs) for your projects. It provides easy-to-use commands to generate CAs, certificates, install mkcert, list certificates, and more.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Usage](#usage)
   - [List Certificates](#list-certificates)
   - [Install mkcert](#install-mkcert)
   - [Uninstall mkcert](#uninstall-mkcert)
   - [Generate CA](#generate-ca)
   - [Install CA](#install-ca)
   - [Check Used Certificate](#check-used-certificate)
   - [Create Apache Virtual Host](#create-apache-virtual-host)
   - [Generate Certificate](#generate-certificate)
   - [View Certificate](#view-certificate)
   - [Clear Directories](#clear-directories)

## Prerequisites

- Bash environment
- Apache2 installed on your system (for Apache Virtual Host)
- OpenSSL

## Usage

### List Certificates

List certificates in a specified directory or the default OpenSSL certificates directory.

```bash
./smcert.sh -lc [<directory>]
```

### Install mkcert

Install the mkcert tool to simplify local certificate management.

```bash
./smcert.sh -mi
```

### Uninstall mkcert

Uninstall the mkcert tool from your system.

```bash
./smcert.sh -mu
```

### Generate CA

Generate CA files for your projects.

```bash
./smcert.sh -gca
```

### Install CA

Install the generated CA files to the system.

```bash
./smcert.sh -ica
```

### Check Used Certificate

Check which certificate is being used by a specified host and port.

```bash
./smcert.sh -cuc
```

### Create Apache Virtual Host

Create an Apache Virtual Host configuration file with SSL.

```bash
./smcert.sh -cvh
```

### Generate Certificate

Generate a certificate using the generated CA.

```bash
./smcert.sh -gcrt
```

### View Certificate

View the details of a specific certificate.

```bash
./smcert.sh -v <certificate_file>
```

### Clear Directories

Clear all generated directories.

```bash
./smcert.sh --clear
```

## Author
Shaon Majumder
smazoomder@gmail.com