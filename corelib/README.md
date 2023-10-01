# House Rental Library

## Description

This Rust library enables the generation of data necessary for renting a house. It facilitates communication between the renter and the homeowner to obtain the required permissions.

## External Libraries

The library utilizes the following external libraries:

- [KERI (Key Event Receipt Infrastructure)](https://weboftrust.github.io/ietf-keri/draft-ssmith-keri.html): KERI allows the generation of electronic keys (eKeys) that are portable and platform-independent. These keys are used for user authentication in the house rental process.

- [OCA (Ownership and Communication Authorization)](http://oca.colossi.network/): OCA allows the definition of the semantics of permissions and information gathered during the use of the rented house. This is essential in the context of access management to the house and communication between parties.

- [ACDC (Authentic Chain Data Container)](https://trustoverip.github.io/tswg-acdc-specification/draft-ssmith-acdc.html): ACDC enables the proof of authenticity of data contained within a container. This allows tracking the origin of data and ensuring its credibility.

## Backend for House Rental Application

The repository also contains a backend for a house rental application. This backend provides the following endpoints:

-  `/register_code`: This endpoint generates the data necessary to establish contact with the homeowner and submit a rental request. Using KERI and OCA, the library ensures a secure registration and communication process between parties.

- `/authorize`: The endpoint generates data that allows the confirmation of rights to open and access the rented house. ACDC is used to prove the authenticity of this data.
