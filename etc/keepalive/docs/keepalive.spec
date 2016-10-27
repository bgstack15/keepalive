#
# spec file for keepalive compiled by hand
Summary: Keepalive
Name: keepalive
Version: 1.0
Release: 6
License: CC BY-SA 4.0
Group: Applications/System
Source: keepalive.tgz
URL: bgstack15@gmail.com
#Distribution:
#Vendor:
Packager: Bgstack15 <bgstack15@gmail.com>
Buildarch: noarch
PreReq: bgscripts >= 1.1-17
PreReq: python34

%description
Keepalive uses a system kerbors ticket (generating one if necessary) to stay authenticated to the http proxy.
The user defines http_proxy and https_proxy. Keepalive assumes the system joined to an AD domain.

%prep
%setup

%build

%install
rsync -a . %{buildroot}/

%clean
rm -rf ${buildroot}

%pre
if [ $1 = "1" ];
then
   # first version being installed
   find /tmp/foo >/dev/null 2>&1
else
   # not the first version being installed
   systemctl stop keepalive >/dev/null 2>&1
fi
exit 0

%post
systemctl enable keepalive
systemctl start keepalive

%preun
if [[ "$1" = "0" ]];
then
   # last version of package is being erased
   systemctl disable keepalive >/dev/null 2>&1
   systemctl stop keepalive >/dev/null 2>&1
else
   # not last version being erased
   find /tmp/foo >/dev/null 2>&1
fi
exit 0

%files
/etc/logrotate.d/keepalive
%config /etc/rsyslog.d/keepalivelog.conf
%doc %attr(444, -, -) /etc/keepalive/README.txt
%verify(link) /etc/keepalive/bin/keepalive.sh
%verify(link) /etc/keepalive/bin/keepalive
/etc/keepalive/docs/keepalive.spec
/etc/keepalive/docs/debian/postinst
/etc/keepalive/docs/debian/conffiles
/etc/keepalive/docs/debian/md5sums
/etc/keepalive/docs/debian/prerm
/etc/keepalive/docs/debian/postrm
/etc/keepalive/docs/debian/control
/etc/keepalive/docs/debian/preinst
%config /etc/keepalive/keepalive.conf
/etc/keepalive/inc/scrub.py
/etc/keepalive/inc/scrub.pyc
/etc/keepalive/inc/scrub.pyo
/etc/keepalive/inc/localize_git.sh
%doc %attr(444, -, -) /etc/keepalive/inc/scrub.txt
%doc %attr(444, -, -) /etc/keepalive/packaging.txt
/usr/lib/systemd/system/keepalive.service
%verify(link) /usr/bin/keepalive
