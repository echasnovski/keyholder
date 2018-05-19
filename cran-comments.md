## Submission details

This submission is reaction to changes in 'dplyr' 0.7.5.

## Test environments
* Ubuntu 16.04 LTS (local install), R 3.4.4
* macOS 10.11 El Capitan (64-bit) (on R-hub), R 3.5.0 (2018-04-23)
* Windows Server 2008 R2 SP1 (32/64 bit) (on R-hub), R-devel (2018-05-17 r74740)
* Debian Linux (on R-hub), R-devel (2018-05-13 r74714), GCC
* win-builder, R Under development (unstable) (2018-05-15 r74727)

## R CMD check results

0 errors | 0 warnings | 0 notes

---

On some Linux platforms on R-hub (Windows Server 2008 R2 SP1, R-release) there was WARNING:

* checking top-level files ... WARNING
Conversion of ‘README.md’ failed:
pandoc: Could not fetch https://travis-ci.org/echasnovski/keyholder.svg?branch=master

  This seems like pandoc issue on particular platforms. Local Ubuntu check doesn't have that.

## Reverse dependencies

There are no reverse dependencies.
