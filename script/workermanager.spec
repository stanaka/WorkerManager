Summary: Worker Manager
Name: perl-Worker-Manager
Version: 0.1
Release: 1
License: GPL
Group: Development/Libraries
URL: http://d.hatena.ne.jp/stanaka/
#Source0: %{name}-%{version}.tar.gz
Source0: Worker-Manager-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArch: noarch
Requires: perl(Parallel::ForkManager)
Requires: perl(Getopt::Std)
Requires: perl(Proc::Daemon)
Requires: perl(File::Pid)

%description

%prep
%setup -q -n workermanager

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/bin
mkdir -p $RPM_BUILD_ROOT/etc/sysconfig
mkdir -p $RPM_BUILD_ROOT/etc/init.d
cp bin/workermanager.pl $RPM_BUILD_ROOT/usr/bin/
cp config/workermanager $RPM_BUILD_ROOT/etc/sysconfig
cp script/workermanager.init $RPM_BUILD_ROOT/etc/init.d/workermanager

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
/etc/sysconfig/workermanager
%attr(755,root,root) /usr/bin/workermanager.pl
%attr(755,root,root) /etc/init.d/workermanager

%doc


%changelog
* Fri Mar 21 2008 Shinji Tanaka <stanaka@hatena.ne.jp> - 
- Initial build.

