# VitruviusLabs local infrastructure

This repository will help you setup a local Docker infrastructure based on the Traefik reverse-proxy.

Here is a list of provided features:

- Custom domains usage.
- Works 💯% offline.
- Does not need any paid subscription, it is totally free.
- Does not make any unlisted change to your device.
- Works on ARM64 (Mac OS Mx) and AMD64 (x86-64).
- Easily customisable to your needs.
- Non-intrusive.

## Getting started

You will need to run several BASH scripts. **These scripts will not alter your device and will only create files instead.**

Since this repository aims to make you aware of any change made to your device, you will need to do some manual setup only once.

### Creating the local certification authority

There are multiple options to handle certificates locally.
One of them is using Let's Encrypt. This has two main drawbacks:
- It does not work offline: Considering one of our goal is to have a fully functioning offline infrastructure, this is not an option.
- It has a rate limit: If you manipulate it wrongly and generate too many certificates, too often, Let's Encrypt will ban you for some time. This is undesirable as it is likely we will make many changes in a development environment.

With all of the above said, we need to create a local certification authority. **This authority will only be recognised by your device. It will not be exposed to the internet nor to any other device. If you want other devices to recognise it (for example your smartphone), you will need to add the certification to those devices as well.**

The script is located in `development/scripts/create_authority.sh` if you want to inspect it prior to running it.

You can either run it directly by typing (from this repository's root directory):

```shell
./development/scripts/create_authority.sh
```

Or you can simply use the provided `Makefile` by typing (from this repository's root directory):

```shell
make development.docker.create-authority
```

Running this script will create two files within the directory `development/docker/services/traefik/authority`:

- `certification_authority.key` is the key used to generate the root certificate. It has no concrete use after the root certificate has been generated but we keep it in case we need it for debugging purposes.
- `certification_authority.pem` is the root certificate that we will use to declare the certification authority. 

### Installing the local certification authority or your device (See credits to Brad Touesnard for this section)

**As mentioned before, this needs to be done on every device you want these certificate to work on. This means if you are a frontend developer looking to connect to this development environment with your smartphone, you will need to install the authority on your smartphone as well. You do NOT need to regenerate the authority nor the certificates for every device, only INSTALL it.**

The authority needs to be installed on the device on which you are running your web browser or the request that needs SSL validation.

For example, if Traefik is running within a Debian virtual machine hosted on a Windows OS, you'll need to install the certificate on Windows and not on Debian. 

#### MacOS

MacOS offers two ways to install the root certificate (authority).
This OS tends to be temperamental with this step and most of the time, only one of those two options will work.
If the option you tried did not work, try the other one. If both do not work, please open an issue on this repository detailing **_precisely_** the problem.

##### The CLI method (recommended)

This method relies on the MacOS command line interface (CLI).
It is the recommended method as it offers less room for user error.
The provided command assumes you have made no modification to this repository and are running it from the repository root directory.

The command to run:

```zsh
sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" development/docker/services/traefik/authority/certification_authority.pem
```

This is all you need to do to install the authority if you decided to use the CLI method.

##### The GUI method (Mac OS Monterey)

This method will use the Mac OS GUI to add the root certificate.
It offers more room for user error and thus is not recommended.
Use it only if the CLI method failed.
It also has a tendency to fail if you already made changes to your keychain, unlike the previous method.

Steps to follow:

* Open the macOS Keychain app
* If required, make sure you’ve selected the System Keychain (older macOS versions default to this keychain)
* Go to File > Import Items…
* Select your private key file (developmentCA.pem)
* Search for "VitruviusLabs Local CA" (Or the authority common name if you have changed it)
* Double-click on your root certificate in the list
* Expand the Trust section
* Change the “When using this certificate:” select box to Always Trust
* Close the certificate window
* During the process it may ask you to enter your password (or scan your finger), do that

#### Linux

This process is relatively simple on Linux distributions.

**Warning: As there are many Linux distributions, this has only been tested on Debian and Ubuntu. Please adapt this step to your own Linux distribution.**

Pre-requisites:

- Install the `ca-certificates` packages: This package is mandatory to manipulate certification authorities.

```shell
sudo apt-get install -y --no-install-recommends ca-certificates
```

Steps to follow:

- Copy the file `development/docker/services/traefik/authority/certification_authority.pem` to the directory `/usr/local/share/ca-certificates` as `local_ca.crt`.

```shell
sudo cp ./development/docker/services/traefik/authority/certification_authority.pem /usr/local/share/ca-certificates/local_ca.crt
```

- Update the certification store.

```shell
sudo update-ca-certificates
```
- Check that the root certificate has been installed properly. (If you changed the root certificate common name, then replace "VitruviusLabs" in the following command with whatever you used)

```shell
awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt | grep VitruviusLabs
```

#### Windows 10/11

On Windows, there are multiple ways to install a root certificate.

With that in mind, the GUI method has had a 100% success rate on every machine this infrastructure has been tested on. Only the GUI method will be detailed as running PowerShell commands can have dramatic consequences on your system and considering PowerShell is much less understood by developers in general.

* Open the “Microsoft Management Console” by using the Windows + R keyboard combination, typing `mmc` and clicking Open
* Go to File > Add/Remove Snap-in
* Click Certificates and Add
* Select Computer Account and click Next
* Select Local Computer then click Finish
* Click OK to go back to the MMC window
* Double-click Certificates (local computer) to expand the view
* Select Trusted Root Certification Authorities, right-click on Certificates in the middle column under “Object Type” and select All Tasks then Import
* Click Next then Browse. Change the certificate extension dropdown next to the filename field to All Files (*.*) and locate the `certification_authority.pem` file (`./development/docker/services/traefik/authority/certification_authority.pem`), click Open, then Next
* Select Place all certificates in the following store. “Trusted Root Certification Authorities store” is the default. Click Next then click Finish to complete the wizard.

If everything went according to plan, you should see your CA certificate listed under Trusted Root Certification Authorities > Certificates.

### Handling Firefox

If you are using Firefox as a web browser, you need to do a few more manipulations.
This is because Firefox does not trust the OS certification store and uses it's own.

#### Windows and MacOS

You'll need to tell Firefox to use the OS certification authority by following a few steps.
**Warning: This will make Firefox TRUST THE OS CERTIFICATION STORE**. If you are not inclined to do this, then you will need to look up yourself how to add a custom certification authority on Firefox. If you are no inclined to do this, DO NOT follow the next steps.

* Open Firefox
* In the search/address bar type `about:config`.
* Accept the risk warning (after reading and understanding it of course) otherwise you won't be able to access the configuration.
* In the search bar at the top of the screen, type `security.enterprise_roots.enabled`. This is the parameter we need to change.
* By default it should be set to `false`. Set it to `true`.
* You will now need to restart Firefox for the changes to be applied. Then you are all done.

#### Linux (possibly broken on RedHat)

You'll need to tell Firefox to use the OS certification authority by following a few steps.
**Warning: This will make Firefox TRUST THE OS CERTIFICATION STORE**. If you are not inclined to do this, then you will need to look up yourself how to add a custom certification authority on Firefox. If you are no inclined to do this, DO NOT follow the next steps.

The option `security.enterprise_roots.enabled` is currently (2023-04-15) broken on Firefox Linux.
To authorize the authority, you will need to manually add the certificate to Firefox.

* Open Firefox
* Hit the ALT key
* On the top bar go to Edit > Settings
* Go to "Privacy & Security"
* Scroll down to "Certificates"
* Click on "View Certificates"
* Go to the "Authorities" tab
* Click on "Import..." on the bottom part of the window
* Import the `certification_authority.pem` (`./development/docker/services/traefik/authority/certification_authority.pem`) file previously created by the `create_authority.sh` script
* Restart Firefox

**/!\\ Warning /!\\ RedHat is a specific case as it does not redistribute Firefox directly but instead re-packages it. This solution may not work for RedHat.**
### Generating certificates

### Initialisation script

Now that you have done all the manual setup and added your root certificate, you only need to initialise this infrastructure.

The script that we are going to run next is located here: `development/scripts/initialise.sh`. Inspect it to your convenience for your own peace of mind.

#### Script actions

This script will create many files.

First, it will copy the `example.env` (`development/docker/example.env`) file as `.env` (`development/docker/.env`).
This allows you to customise the content of this file without having it tracked by `Git`.

It will then copy the `traefik.example.toml` (`development/docker/services/traefik/traefik.example.toml`) file as `traefik.toml` (`development/docker/services/traefik/traefik.toml`).

**DO NOT ADD ANYTHING UNDER THE COMMENT TELLING YOU NOT TO ADD ANYTHING IN THE `traefik.toml` FILE!**

The script will next copy the `domains.example.txt`(`development/docker/services/traefik/domains.example.txt`) file as `domains.txt` (`development/docker/services/traefik/domains.txt`).

It will only copy it if the `domains.txt` file does not already exist. This allows you add any number of custom domains you would like to use locally. You do not need to actively own them as this infrastructure is strictly local. Add only ONE domain per line. Always leave an empty line at the end of the file as is usual with any file.

#### How to run it

You have two ways of running it.

Using a `Make` command:

```shell
make development.docker.initialise
```

Or running the script manually:

```shell
./development/scripts/initialise.sh
```

#### Manually generating a certificate

If you so wish, you can manually generate a certificate for a given domain.

By default, it will use the generate certification authority. If you wish to use a different authority, then you can specify it by adding the parameters.

Command:

```shell
./development/scripts/create_certificate.sh --domain my-custom-domain.dev
```

Using a custom certification authority:

```shell
./development/scripts/create_certificate.sh --domain my-custom-domain.dev --CAKeyPath ./my/ca.key --CAPemPath ./my/ca.pem
```

Using a custom certificate directory as output:

```shell
./development/scripts/create_certificate.sh --domain my-custom-domain.dev --certificatesDir ./my/output/directory
```

### Edit your hosts file

Since this infrastructure aims to be fully functional offline, you will need to change your hosts file to redirect your domains to your local machine.

You will need to add every domain you added to your `domains.txt` file.

The syntax is as follows:

```
127.0.0.1 my-custom-domain.dev
```

**Warning: If you are running your infrastructure within a Virtual Machine (VMWare, Hyper-V, VirtualBox, etc), then you need to specify the virtual machine IP.** Note: Setting up a Virtual Machine and it's complex networking is out of the scope of this `README.md`. Please refer to another guide on that matter to set a fixed IP to your VM.

#### Linux and MacOS

Open your hosts file with the following command (use whatever file editor you prefer if you don't like `nano`):
```shell
sudo nano /etc/hosts
```

It will ask for your device password since this is a `sudo` command.

Add every domain as explained in the previous section.

You can close `nano` by using `CTRL + O` to write the file and `CTRL + X` to exit `nano`.

#### Windows

* Open the file `C:\Windows\System32\drivers\etc\hosts` with a elevated (as administrator) text editor.
* Add every domain as explained in the previous section.
* Save the file and reopen it to check that the changes were properly made.

### Launch Traefik

Now you need to launch Traefik for it to work.

You have multiple ways to do so.

Here are the involved scripts:
- `development/docker/scripts/up.sh`: It is a wrapper to start your infrastructure as a `Docker Compose` project.
- `development/docker/scripts/down.sh`: It is a wrapper to stop your infrastructure as a `Docker Compose` project.
- `development/docker/scripts/restart.sh`: This is the script that does both `up` and `down`. You can use exclusively this one as it will not crash if the infrastructure was not already started.

Using `Make`:

* Starting the infrastructure

```shell
make development.docker.start
```

* Stopping the infrastructure

```shell
make development.docker.stop
```

* (Re)starting the infrastructure

```shell
make development.docker.restart
```

Using the scripts:

* Starting the infrastructure

```shell
./development/docker/scripts/up.sh
```

* Stopping the infrastructure

```shell
./development/docker/scripts/down.sh
```

* (Re)starting the infrastructure

```shell
./development/docker/scripts/restart.sh
```


Check that `Traefik` is running by typing `docker container ls -a`. The status should be "Up XXX ago".

### Checking that Traefik works

Here are some ways to check your infrastructure.

1) Check that the `traefik` container is healthy.

```shell
docker container ls -a
```

You should see the container as running and not restarting.

2) Check the logs of the `traefik` container for errors.

Note: If you changed `COMPANY_NAME` in the `.env` file, then you need to change `vitruvius-labs` to whatever you put.

```shell
docker logs -f vitruvius-labs-traefik
```

3) Check the `traefik` dashboard

Open your web browser and access the address: https://traefik.vitruvius-labs.dev
If you have changed the `COMPANY_NAME` variable in the `.env` file, then replace `vitruvius-labs` by whatever you put.

You should be accessing the `traefik` dashboard without error nor warning.
Refer to the `traefik` documentation for more information.

Tip: `traefik` offers a dark mode on it's dashboard.

You are all done for setting up the base of the infrastructure!

## Credits

Thanks to [Brad Touesnard](https://bradt.ca) (deliciousbrains.com) for his guide about installing the root certificate on various platform. You made life much easier!
