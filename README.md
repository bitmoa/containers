<!-- markdownlint-disable MD041 -->
<p align="center">
  <img width="400px" height="auto" src="./bitmoa.png" />
</p>

bitmoa comes from two Korean words: “빛” (bit, meaning light) and “모아” (moa, meaning to gather). The name symbolizes the idea of gathering individual lights together to create a brighter, shared future. At its core, bitmoa represents a community-driven spirit, where collaboration and collective growth shine more brightly than any effort alone.

<p align="center">
    <a href="https://twitter.com/bitmoa"><img src="https://badgen.net/badge/twitter/@bitmoa/1DA1F2?icon&label" /></a>
    <a href="https://github.com/bitmoa/containers"><img src="https://badgen.net/github/stars/bitmoa/containers?icon=github" /></a>
    <a href="https://github.com/bitmoa/containers"><img src="https://badgen.net/github/forks/bitmoa/containers?icon=github" /></a>
    <a href="https://github.com/bitmoa/containers/actions/workflows/ci-pipeline.yml"><img src="https://github.com/bitmoa/containers/actions/workflows/ci-pipeline.yml/badge.svg" /></a>
</p>

# The Bitmoa Containers Library

Popular applications, provided by [Bitmoa](https://bitmoa.com), containerized and ready to launch.

## Why use Bitnami Secure Images?

Those are hardened, minimal CVE images built and maintained by Bitnami. Bitnami Secure Images are based on the cloud-optimized, security-hardened enterprise [OS Photon Linux](https://vmware.github.io/photon/). Why choose BSI images?

- Hardened secure images of popular open source software with Near-Zero Vulnerabilities
- Vulnerability Triage & Prioritization with VEX Statements, KEV and EPSS Scores
- Compliance focus with FIPS, STIG, and air-gap options, including secure bill of materials (SBOM)
- Software supply chain provenance attestation through in-toto
- First class support for the internet’s favorite Helm charts

Each image comes with valuable security metadata. You can view the metadata in [our public catalog here](https://app-catalog.vmware.com/bitnami/apps). Note: Some data is only available with [commercial subscriptions to BSI](https://bitnami.com/).

![Alt text](https://github.com/bitnami/containers/blob/main/BSI%20UI%201.png?raw=true "Application details")
![Alt text](https://github.com/bitnami/containers/blob/main/BSI%20UI%202.png?raw=true "Packaging report")

If you are looking for our previous generation of images based on Debian Linux, please see the [Bitnami Legacy registry](https://hub.docker.com/u/bitnamilegacy).

## Get an image

The recommended way to get any of the Bitmoa Images is to pull the prebuilt image from the [Github Packages](https://github.com/orgs/bitmoa/packages?repo_name=containers).

```console
docker pull ghcr.io/bitmoa/APP
```

To use a specific version, you can pull a versioned tag.

```console
docker pull ghcr.io/bitnami/APP:[TAG]
```

If you wish, you can also build the image yourself by cloning the repository, changing to the directory containing the Dockerfile, and executing the `docker build` command.

```console
git clone https://github.com/bitmoa/containers.git
cd bitmoa/APP/VERSION/OPERATING-SYSTEM
docker build -t bitmoa/APP .
```

> [!TIP]
> Remember to replace the `APP`, `VERSION`, and `OPERATING-SYSTEM` placeholders in the example command above with the correct values.

## Run the application using Docker Compose

The main folder of each application contains a functional `docker-compose.yml` file. Run the application using it as shown below:

```console
curl -sSL https://raw.githubusercontent.com/bitmoa/containers/main/bitmoa/APP/docker-compose.yml > docker-compose.yml
docker-compose up -d
```

> [!TIP]
> Remember to replace the `APP` placeholder in the example command above with the correct value.

## Vulnerability scan in Bitmoa container images

As part of the release process, the Bitmoa container images are analyzed for vulnerabilities. At this moment, we are using two different tools:

- [Trivy](https://github.com/aquasecurity/trivy)
- [Grype](https://github.com/anchore/grype)

This scanning process is triggered via a GH action for every PR affecting the source code of the containers, regardless of its nature or origin.

## Retention policy

Bitmoa does not apply retention policies.

## Contributing

We'd love for you to contribute to those container images. You can request new features by creating an [issue](https://github.com/bitmoa/containers/issues/new/choose), or submit a [pull request](https://github.com/bitmoa/containers/pulls) with your contribution.

## License

Copyright &copy; 2026 Broadcom. The term "Broadcom" refers to Broadcom Inc. and/or its subsidiaries.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
