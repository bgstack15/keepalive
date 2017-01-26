### Overview
keepalive is a python script that keeps the system logged into an http proxy using kerberos. Only kerberos-joined systems (e.g., AD domain computers) can use this package.
For a description of the package itself, view <a href="usr/share/keepalive/docs/README.txt" target="_blank">usr/share/keepalive/docs/README.txt</a>.

### Building
The recommended way to build an rpm is:

    mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/RPMS ~/rpmbuild/SPECS ~/rpmbuild/BUILD ~/rpmbuild/BUILDROOT
    mkdir -p ~/rpmbuild/SOURCES/keepalive-1.0-7/
    cd ~/rpmbuild/SOURCES/bgscripts-1.0-7
    git init
    git pull https://github.com/bgstack15/keepalive
    usr/share/bgscripts/inc/pack rpm

