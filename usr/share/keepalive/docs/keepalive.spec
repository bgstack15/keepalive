#
# spec file for keepalive compiled by hand
Summary:	Keepalive keeps you logged in to an http proxy via kerberos tickets
Name:		keepalive
Version:	1.0
Release:	7
License:	CC BY-SA 4.0
Group:		Applications/System
Source:		keepalive.tgz
URL:		https://bgstack15.wordpress.com/
#Distribution:
#Vendor:
Packager:	Bgstack15 <bgstack15@gmail.com>
Buildarch:	noarch
Requires(pre):	bgscripts-core >= 1.1-31
Requires(pre):	python34
Requires:	curl

%description
Keepalive uses a system kerberos ticket (generating one if necessary) to stay authenticated to the http proxy.
The user defines http_proxy and https_proxy. Keepalive assumes the system joined to an AD domain.

%prep
%setup

%build

%install
rsync -a . %{buildroot}/

%clean
rm -rf ${buildroot}

%pre
# rpm pre 2017-01-26
thisservice=%{name}.service
{
case "${1}" in
   2)
      # Upgrade.
      systemctl stop ${thisservice}
      ;;
   1)
      # New install.
      :
      ;;
esac
} 1>/dev/null 2>&1
exit 0

%post
# rpm post 2017-01-26
thisservice=%{name}.service
{
systemctl daemon-reload
systemctl enable ${thisservice}
systemctl start ${thisservice}
} 1>/dev/null 2>&1
exit 0

%preun
# rpm preun 2017-01-26
thisservice=%{name}.service
{
case "${1}" in
   0)
      # Final removal.
      systemctl stop ${thisservice}
      systemctl disable ${thisservice}
      ;;
   1)
      # Upgrade.
      :
      ;;
esac
} 1>/dev/null 2>&1
exit 0

%postun
# rpm postun 2017-01-26
systemctl daemon-reload 1>/dev/null 2>&1
exit 0

%files
%dir /etc/keepalive
%dir /usr/share/keepalive
%dir /usr/share/keepalive/docs
%dir /usr/share/keepalive/docs/debian
%dir /usr/share/keepalive/inc
/etc/logrotate.d/keepalive
%config /etc/rsyslog.d/keepalivelog.conf
%config /etc/keepalive/keepalive.conf
/usr/share/keepalive/keepalive.sh
/usr/share/keepalive/docs/keepalive.spec
/usr/share/keepalive/docs/debian/postinst
/usr/share/keepalive/docs/debian/conffiles
/usr/share/keepalive/docs/debian/md5sums
/usr/share/keepalive/docs/debian/prerm
/usr/share/keepalive/docs/debian/postrm
/usr/share/keepalive/docs/debian/control
/usr/share/keepalive/docs/debian/preinst
%doc %attr(444, -, -) /usr/share/keepalive/docs/README.txt
%doc %attr(444, -, -) /usr/share/keepalive/docs/packaging.txt
%doc %attr(444, -, -) /usr/share/keepalive/docs/files-for-versioning.txt
/usr/share/keepalive/inc/get-files
/usr/share/keepalive/inc/pack
/usr/share/keepalive/inc/localize_git.sh
%doc %attr(444, -, -) /usr/share/keepalive/inc/scrub.txt
/usr/share/keepalive/keepalive
/usr/lib/systemd/system/keepalive.service
%verify(link) /usr/bin/keepalive

%changelog
* Thu Jan 26 2017 B Stack <bgstack15@gmail.com> 1.0-7
- Rearranged package to be compliant with FHS 3.0
- Updated dependency to bgscripts-core
- Added ./pack script
- Added changelog to spec file
