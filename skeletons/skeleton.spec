#
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#

# norootforbuild

Name:            specRPM_CREATION_NAME
Version:
Release:
Summary:
Group:
License:
Url:
PreReq:
Provides:
BuildRequires:
Source:
Patch:
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
AutoReqProv:    on

%description

Authors:
--------
    Name Surname 
%prep
%setup

%build
%configure
make %{?jobs:-j%jobs}

%install
%makeinstall

%clean
rm -rf $RPM_BUILD_ROOT

%post
%postun

%files
%defattr(-,root,root,0755)
%doc ChangeLog README COPYING

%changelog
* specRPM_CREATION_DATE - specRPM_CREATION_AUTHOR_MAIL
