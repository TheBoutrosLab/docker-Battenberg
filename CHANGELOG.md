# Changelog
All notable changes to the tool_name Docker file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---
## Unreleased
### Chanded
- Use the official `r-base:4.4.1` docker image
- Replace GitHub package installation with `pkgdepends`

### Added
- Add installer.R that uses `pkgdepends`

---

## [2.2.9-bl-parametrize-max-rho] - 2024-10-29
### Added
- Add `renv.lock` file containing R packages and their version
- Add `battenberg_bl_custom.R`, a customized `battenberg.R` script that allows parameterization of `max_rho`
- Add `battenberg_wgs_bl_custom.R`, a customized `battenberg_wgs.R` wrapper that allows parameterization of options

### Changed
- Reproduce R packages environment using `renv.lock` file
- Install ASCAT and Battenberg using `R CMD INSTALL`

### Removed
- Remove `modify_reference_path.sh`

## [2.2.9] - 2023-06-27
### Added
- Add `modify_reference_path.sh`
- Add GRCh37 and GRCh38 resource paths to `README.md`

### Changed
- Release `docker-Battenberg v2.2.9`
- Update Battenberg `v2.2.9` in Dockerfile
- Reconfigure Dockerfile
- Standardize Battenberg resource files
- Standardize the `docker-Battenberg` repo
- Rename `master` to `main` branch

### Removed
- Remove redundant files

---

## [aa14170714] - 2023-02-18
### Added
- Dockerfile based on `Wedge-lab/battenberg@aa14170714` dev branch

### Changed
- Modify version of `battenberg_wgs.R` to allow mounting of the GRCh38 reference files for Battenberg
