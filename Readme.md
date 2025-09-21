## Trial POC

### Description

This is trial project to implement Keycloak as your identity management provider.

### Requirements

Below are the dependencies that required for this project:

1. Keycloak
2. SQL Server
3. Docker

### Problem and Solution

During the trial process, I encountered several issues. Below are some of the issues identified so far and their respective solutions.

#### 1. Issue : Database driver could not establish a secure connection to SQL Server by using Secure Sockets Layer (SSL) encryption

##### Identified Root Cause:

This issue occurs because SQL Server requires TLS certificate validation by default.

##### Solution:

Add the use of TrustServerCertificate in the connection string configuration for the SQL Server database.

2. Issue :

### External References

External references that related to this project :

1. Keycloak official documentation
2. etc
