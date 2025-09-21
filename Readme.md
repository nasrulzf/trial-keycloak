## Trial POC

### Description

This project demonstrates the implementation of Keycloak as an identity management provider.

### Requirements

The following dependencies are required for this project:

1. **Keycloak**
2. **SQL Server**
3. **Docker**

### Problems and Solutions

During the trial process, several issues were encountered. Below are the identified issues along with their solutions:

#### 1. **Issue**: Database driver could not establish a secure connection to SQL Server using Secure Sockets Layer (SSL) encryption.

- **Root Cause**:  
   SQL Server requires TLS certificate validation by default.

- **Solution**:  
   Add `TrustServerCertificate=true` to the connection string configuration for the SQL Server database.

#### 2. **Issue**: [Provide a brief description of the second issue here]

- **Root Cause**:  
   [Explain the root cause of the second issue]

- **Solution**:  
   [Provide the solution for the second issue]

### External References

Below are some useful references related to this project:

1. [Keycloak Official Documentation](https://www.keycloak.org/documentation)
2. [Add other relevant references here]

### Notes

Feel free to contribute or raise issues in this repository to improve the project further.
